const { app, BrowserWindow, shell } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');
const express = require('express');

// Handle creating/removing shortcuts on Windows when installing/uninstalling
if (require('electron-squirrel-startup')) {
  app.quit();
}

let mainWindow;
let backendProcess;
let frontendUrl = '';

// --- Servidor de Frontend (Express) ---
const startFrontendServer = () => {
  return new Promise((resolve, reject) => {
    const frontendApp = express();
    const buildPath = path.join(__dirname, 'build');
    
    // Check if build directory exists
    if (!fs.existsSync(buildPath)) {
      console.error('Build directory not found:', buildPath);
      reject(new Error('Build directory not found. Please build the frontend first.'));
      return;
    }
    
    frontendApp.use(express.static(buildPath));

    const server = frontendApp.listen(0, '127.0.0.1', () => {
      const port = server.address().port;
      frontendUrl = `http://127.0.0.1:${port}`;
      console.log(`Frontend server listening on ${frontendUrl}`);
      resolve(frontendUrl);
    });

    server.on('error', (error) => {
      console.error('Frontend server error:', error);
      reject(error);
    });
    
    // Add a timeout to reject the promise if server doesn't start in time
    setTimeout(() => {
      reject(new Error('Frontend server failed to start within timeout period'));
    }, 10000); // 10 seconds timeout
  });
};

const createWindow = (urlToLoad) => {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
    },
    icon: path.join(__dirname, 'icon.ico')
  });

  console.log(`Loading URL: ${urlToLoad}`);
  mainWindow.loadURL(urlToLoad);

  // Open external links in default browser
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // Handle navigation to external URLs
  mainWindow.webContents.on('will-navigate', (event, url) => {
    if (!url.startsWith(frontendUrl)) {
      event.preventDefault();
      shell.openExternal(url);
    }
  });
};

// --- Servidor de Backend (Python) ---
const startBackend = () => {
  const isDev = !app.isPackaged;

  if (isDev) {
    // Development: Run Python script directly
    const backendPath = path.join(__dirname, 'backend');
    const pythonPath = path.join(backendPath, 'venv', 'Scripts', 'python.exe');
    const scriptPath = path.join(backendPath, 'main.py');

    // Check if the backend script exists
    if (!fs.existsSync(scriptPath)) {
      console.error('Backend script not found:', scriptPath);
      return;
    }

    // Check if Python executable exists
    if (!fs.existsSync(pythonPath)) {
      console.warn('Python virtual environment not found, trying system Python');
      // Try system Python
      backendProcess = spawn('python', [scriptPath], {
        cwd: backendPath,
        env: { ...process.env, PYTHONPATH: backendPath, PYTHONUNBUFFERED: '1' }
      });
    } else {
      console.log('Starting backend script with:', { pythonPath, scriptPath });
      backendProcess = spawn(pythonPath, [scriptPath], {
        cwd: backendPath,
        env: { ...process.env, PYTHONPATH: backendPath, PYTHONUNBUFFERED: '1' }
      });
    }

  } else {
    // Production: Run packaged executable
    const backendExePath = path.join(process.resourcesPath, 'lylyreader-backend.exe');

    if (!fs.existsSync(backendExePath)) {
      console.error('Backend executable not found:', backendExePath);
      return;
    }

    console.log('Starting backend executable from:', backendExePath);
    backendProcess = spawn(backendExePath);
  }

  // Common process handlers
  backendProcess.stdout.on('data', (data) => {
    console.log(`Backend stdout: ${data}`);
  });

  backendProcess.stderr.on('data', (data) => {
    console.error(`Backend stderr: ${data}`);
  });

  backendProcess.on('close', (code) => {
    console.log(`Backend process exited with code ${code}`);
  });

  backendProcess.on('error', (error) => {
    console.error('Failed to start backend:', error);
  });
};

const killBackend = () => {
  if (backendProcess) {
    backendProcess.kill();
    // Add a timeout to force kill if the process doesn't terminate gracefully
    setTimeout(() => {
      try {
        if (backendProcess && !backendProcess.killed) {
          backendProcess.kill('SIGKILL');
        }
      } catch (error) {
        console.error('Error force killing backend process:', error);
      }
    }, 5000); // Force kill after 5 seconds if not terminated
  }
};

// --- Ciclo de Vida do App ---
app.whenReady().then(async () => {
  startBackend();

  const isDev = !app.isPackaged;
  let urlToLoad;

  if (isDev) {
    // Em desenvolvimento, o servidor do Next.js já está rodando
    urlToLoad = 'http://localhost:3000';
  } else {
    // Em produção, iniciamos nosso próprio servidor para os arquivos estáticos
    try {
      urlToLoad = await startFrontendServer();
    } catch (error) {
      console.error('Could not start frontend server, quitting app.');
      // Show error dialog to user
      const { dialog } = require('electron');
      dialog.showErrorBox('Application Error', 
        'Failed to start the application server. Please check the logs for more details.\n\nError: ' + error.message);
      app.quit();
      return;
    }
  }
  
  createWindow(urlToLoad);

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow(urlToLoad);
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    killBackend();
    app.quit();
  }
});

app.on('before-quit', () => {
  killBackend();
});

const { app, BrowserWindow, shell } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');
const express = require('express');
const http = require('http');

// Handle creating/removing shortcuts on Windows when installing/uninstalling
try {
  if (require('electron-squirrel-startup')) {
    app.quit();
  }
} catch (error) {
  console.log('electron-squirrel-startup not found, continuing...');
}

let mainWindow;
let backendProcess;
let server;

const createWindow = () => {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    },
    icon: path.join(__dirname, 'icon.ico'),
    show: false // Initially hide the window
  });

  // Wait for the server to start before loading the URL
  mainWindow.webContents.on('did-finish-load', () => {
    mainWindow.show();
  });

  // Load the static files
  mainWindow.loadURL(`http://localhost:3000`);

  // Open external links in default browser
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // Handle navigation to external URLs
  mainWindow.webContents.on('will-navigate', (event, url) => {
    if (!url.startsWith('http://localhost:3000')) {
      event.preventDefault();
      shell.openExternal(url);
    }
  });

  // Handle errors
  mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    console.error('Failed to load:', errorCode, errorDescription);
  });
};

// Start the backend server
const startBackend = () => {
  const backendPath = path.join(__dirname, 'backend');
  
  // Check if we're in a packaged app or development
  const pythonPath = process.platform === 'win32' ? 
    path.join(process.resourcesPath, 'backend', 'venv', 'Scripts', 'python.exe') :
    path.join(process.resourcesPath, 'backend', 'venv', 'bin', 'python');
    
  const scriptPath = path.join(process.resourcesPath, 'backend', 'main.py');

  // For development, use local paths
  const devPythonPath = path.join(backendPath, 'venv', process.platform === 'win32' ? 'Scripts' : 'bin', 'python.exe');
  const devScriptPath = path.join(backendPath, 'main.py');
  
  // Check if we're running in a packaged app
  const isPackaged = app.isPackaged;
  const useDevPaths = !isPackaged && fs.existsSync(backendPath);
  
  const finalPythonPath = useDevPaths ? devPythonPath : pythonPath;
  const finalScriptPath = useDevPaths ? devScriptPath : scriptPath;

  // Set the working directory and PYTHONPATH
  const cwd = useDevPaths ? backendPath : path.join(process.resourcesPath, 'backend');
  const pythonPathEnv = useDevPaths ? backendPath : path.join(process.resourcesPath, 'backend');

  // Verify that the Python executable exists
  if (!fs.existsSync(finalPythonPath)) {
    console.error('Python executable not found at:', finalPythonPath);
    // Try alternative paths
    const alternativePaths = [
      path.join(process.resourcesPath, 'backend', 'venv', 'Scripts', 'python.exe'),
      path.join(process.resourcesPath, 'backend', 'venv', 'bin', 'python.exe')
    ];
    
    for (const altPath of alternativePaths) {
      if (fs.existsSync(altPath)) {
        console.log('Found Python executable at alternative path:', altPath);
        finalPythonPath = altPath;
        break;
      }
    }
    
    // If still not found, show an error
    if (!fs.existsSync(finalPythonPath)) {
      console.error('Python executable not found. Backend will not start.');
      return;
    }
  }

  // Verify that the script exists
  if (!fs.existsSync(finalScriptPath)) {
    console.error('Script not found at:', finalScriptPath);
    return;
  }

  console.log('Starting backend with Python path:', finalPythonPath);
  console.log('Script path:', finalScriptPath);
  console.log('Working directory:', cwd);
  console.log('PYTHONPATH:', pythonPathEnv);

  backendProcess = spawn(finalPythonPath, [finalScriptPath], {
    cwd: cwd,
    env: { ...process.env, PYTHONPATH: pythonPathEnv }
  });

  backendProcess.stdout.on('data', (data) => {
    console.log(`Backend stdout: ${data}`);
  });

  backendProcess.stderr.on('data', (data) => {
    console.error(`Backend stderr: ${data}`);
  });

  backendProcess.on('close', (code) => {
    console.log(`Backend process exited with code ${code}`);
  });
};

// Start a simple Express server to serve static files
const startStaticServer = () => {
  const app = express();
  const staticPath = path.join(__dirname, 'build');
  
  // Verificar se o diretório de build existe
  if (!fs.existsSync(staticPath)) {
    console.error('Build directory not found at:', staticPath);
    return;
  }
  
  app.use(express.static(staticPath));
  
  // Serve index.html for all routes (for client-side routing)
  app.get('*', (req, res) => {
    res.sendFile(path.join(staticPath, 'server', 'app', 'index.html'));
  });
  
  server = http.createServer(app);
  
  // Adicionar tratamento de erros ao servidor
  server.on('error', (error) => {
    console.error('Server error:', error);
  });
  
  server.listen(3000, () => {
    console.log('Static server running on http://localhost:3000');
    
    // Garantir que a janela seja criada após o servidor estar pronto
    if (mainWindow) {
      mainWindow.loadURL(`http://localhost:3000`);
      mainWindow.show();
    }
  });
  
  // Timeout para mostrar a janela mesmo se o servidor demorar
  setTimeout(() => {
    if (mainWindow && !mainWindow.isVisible()) {
      mainWindow.loadURL(`http://localhost:3000`);
      mainWindow.show();
    }
  }, 5000);
};

// Kill backend process when app quits
const killBackend = () => {
  if (backendProcess) {
    backendProcess.kill();
  }
  if (server) {
    server.close();
  }
};

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
  createWindow();
  startBackend();
  startStaticServer();

  app.on('activate', () => {
    // On OS X it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    killBackend();
    app.quit();
  }
});

app.on('before-quit', () => {
  killBackend();
});
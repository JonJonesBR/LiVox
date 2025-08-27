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

  // Wait for the page to finish loading before showing the window
  mainWindow.webContents.on('did-finish-load', () => {
    mainWindow.show();
  });

  // Load the static files directly from the file system
  const indexPath = path.join(__dirname, 'build', 'server', 'app', 'index.html');
  console.log('Loading index.html from:', indexPath);
  
  if (fs.existsSync(indexPath)) {
    mainWindow.loadFile(indexPath);
  } else {
    console.error('index.html not found at:', indexPath);
    // Tentar carregar o arquivo _not-found.html como fallback
    const notFoundPath = path.join(__dirname, 'build', 'server', 'app', '_not-found.html');
    if (fs.existsSync(notFoundPath)) {
      mainWindow.loadFile(notFoundPath);
    } else {
      // Mostrar uma página de erro simples
      mainWindow.loadURL('data:text/html,<h1>Error: index.html not found</h1>');
    }
  }

  // Open external links in default browser
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // Handle navigation to external URLs
  mainWindow.webContents.on('will-navigate', (event, url) => {
    // Permitir navegação para URLs relativas (para client-side routing)
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return;
    }
    
    // Abrir links externos no navegador padrão
    if (!url.startsWith('file://')) {
      event.preventDefault();
      shell.openExternal(url);
    }
  });

  // Handle errors
  mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription, validatedURL) => {
    console.error('Failed to load:', validatedURL, errorCode, errorDescription);
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
  
  let finalPythonPath = useDevPaths ? devPythonPath : pythonPath;
  const finalScriptPath = useDevPaths ? devScriptPath : scriptPath;

  // Set the working directory and PYTHONPATH
  const cwd = useDevPaths ? backendPath : path.join(process.resourcesPath, 'backend');
  const pythonPathEnv = useDevPaths ? backendPath : path.join(process.resourcesPath, 'backend');

  console.log('App is packaged:', isPackaged);
  console.log('Using dev paths:', useDevPaths);
  console.log('Backend path:', backendPath);
  console.log('Python path:', finalPythonPath);
  console.log('Script path:', finalScriptPath);
  console.log('Working directory:', cwd);
  console.log('PYTHONPATH:', pythonPathEnv);

  // Verify that the Python executable exists
  if (!fs.existsSync(finalPythonPath)) {
    console.error('Python executable not found at:', finalPythonPath);
    // Try alternative paths
    const alternativePaths = [
      path.join(process.resourcesPath, 'backend', 'venv', 'Scripts', 'python.exe'),
      path.join(process.resourcesPath, 'backend', 'venv', 'bin', 'python')
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
      // Tentar usar python do sistema
      finalPythonPath = 'python';
      console.log('Trying to use system python');
    }
  }

  // Verify that the script exists
  if (!fs.existsSync(finalScriptPath)) {
    console.error('Script not found at:', finalScriptPath);
    // Tentar caminho alternativo para apps empacotados
    const altScriptPath = path.join(process.resourcesPath, 'app', 'backend', 'main.py');
    if (fs.existsSync(altScriptPath)) {
      console.log('Found script at alternative path:', altScriptPath);
      finalScriptPath = altScriptPath;
    } else {
      console.error('Script not found at alternative path either');
      return;
    }
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
  
  backendProcess.on('error', (error) => {
    console.error('Failed to start backend process:', error);
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
  
  console.log('Serving static files from:', staticPath);
  
  // Listar o conteúdo do diretório de build para depuração
  console.log('Build directory contents:');
  try {
    const buildContents = fs.readdirSync(staticPath);
    console.log(buildContents);
    
    // Listar o conteúdo da pasta static se existir
    const staticAssetsPath = path.join(staticPath, 'static');
    if (fs.existsSync(staticAssetsPath)) {
      console.log('Static assets directory contents:');
      const staticContents = fs.readdirSync(staticAssetsPath);
      console.log(staticContents);
      
      // Listar o conteúdo da pasta _next dentro de static
      const nextAssetsPath = path.join(staticAssetsPath, '_next');
      if (fs.existsSync(nextAssetsPath)) {
        console.log('_next directory contents:');
        const nextContents = fs.readdirSync(nextAssetsPath);
        console.log(nextContents);
      }
    }
  } catch (err) {
    console.error('Error reading directory contents:', err);
  }
  
  // Adicionar middleware para log de todas as requisições
  app.use((req, res, next) => {
    console.log('Request:', req.method, req.url);
    next();
  });
  
  // Servir arquivos estáticos da pasta static primeiro
  const staticAssetsPath = path.join(staticPath, 'static');
  if (fs.existsSync(staticAssetsPath)) {
    console.log('Serving static assets from:', staticAssetsPath);
    app.use('/_next/static', express.static(staticAssetsPath, {
      maxAge: '1y',
      etag: false
    }));
  }
  
  // Servir arquivos estáticos com cabeçalhos corretos
  app.use(express.static(staticPath, {
    setHeaders: (res, filePath) => {
      if (filePath.endsWith('.html')) {
        res.setHeader('Content-Type', 'text/html; charset=UTF-8');
      }
    },
    maxAge: '1y',
    etag: false
  }));
  
  // Serve index.html for all routes (for client-side routing)
  app.get('*', (req, res) => {
    console.log('Handling request for:', req.url);
    
    // Primeiro verificar se é um arquivo estático
    const staticFilePath = path.join(staticPath, req.url);
    console.log('Checking static file path:', staticFilePath);
    
    if (fs.existsSync(staticFilePath) && fs.statSync(staticFilePath).isFile()) {
      console.log('Serving static file:', staticFilePath);
      // Servir o arquivo estático diretamente
      res.sendFile(staticFilePath);
      return;
    }
    
    // Se não for um arquivo estático, servir o index.html para client-side routing
    const indexPath = path.join(staticPath, 'server', 'app', 'index.html');
    console.log('Serving index.html from:', indexPath);
    
    // Verificar se o arquivo index.html existe
    if (fs.existsSync(indexPath)) {
      // Ler o conteúdo do arquivo e enviá-lo com o tipo de conteúdo correto
      fs.readFile(indexPath, 'utf8', (err, data) => {
        if (err) {
          console.error('Error reading index.html:', err);
          res.status(500).send('Error reading index.html');
          return;
        }
        
        console.log('index.html content length:', data.length);
        // Verificar se o conteúdo é válido
        if (data.length === 0) {
          console.error('index.html is empty');
          res.status(500).send('index.html is empty');
          return;
        }
        
        res.setHeader('Content-Type', 'text/html; charset=UTF-8');
        res.send(data);
      });
    } else {
      console.error('index.html not found at:', indexPath);
      // Tentar servir o arquivo _not-found.html como fallback
      const notFoundPath = path.join(staticPath, 'server', 'app', '_not-found.html');
      if (fs.existsSync(notFoundPath)) {
        res.sendFile(notFoundPath);
      } else {
        res.status(404).send('index.html not found');
      }
    }
  });
  
  server = http.createServer(app);
  
  // Adicionar tratamento de erros ao servidor
  server.on('error', (error) => {
    console.error('Server error:', error);
  });
  
  // Verificar se a porta está disponível
  server.on('listening', () => {
    const addr = server.address();
    console.log('Static server listening on port', addr.port);
  });
  
  server.listen(3000, '127.0.0.1', () => {
    console.log('Static server running on http://127.0.0.1:3000');
    
    // Testar se o servidor está respondendo
    setTimeout(() => {
      const http = require('http');
      const testReq = http.get('http://127.0.0.1:3000', (res) => {
        console.log('Test request status code:', res.statusCode);
        res.on('data', (chunk) => {
          console.log('Test request response length:', chunk.length);
        });
      }).on('error', (err) => {
        console.error('Test request error:', err.message);
      });
      
      testReq.setTimeout(5000, () => {
        testReq.abort();
        console.log('Test request timeout');
      });
    }, 1000);
    
    // Garantir que a janela seja criada após o servidor estar pronto
    if (mainWindow) {
      mainWindow.loadURL(`http://127.0.0.1:3000`);
      mainWindow.show();
      
      // Adicionar listener para erros de carregamento
      mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription, validatedURL) => {
        console.error('Failed to load URL:', validatedURL, 'Error:', errorCode, errorDescription);
      });
      
      // Adicionar listener para quando a página terminar de carregar
      mainWindow.webContents.on('did-finish-load', () => {
        console.log('Page finished loading');
        mainWindow.webContents.executeJavaScript(`
          console.log('Document title:', document.title);
          console.log('Document body length:', document.body ? document.body.innerHTML.length : 0);
        `);
      });
      
      // Adicionar listener para erros na console do navegador
      mainWindow.webContents.on('console-message', (event, level, message, line, sourceId) => {
        console.log('Console message:', level, message, 'at line', line, 'in', sourceId);
      });
    }
  });
  
  // Timeout para mostrar a janela mesmo se o servidor demorar
  setTimeout(() => {
    if (mainWindow && !mainWindow.isVisible()) {
      mainWindow.loadURL(`http://127.0.0.1:3000`);
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
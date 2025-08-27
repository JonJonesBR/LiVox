const { app, BrowserWindow, shell } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');

// Handle creating/removing shortcuts on Windows when installing/uninstalling
if (require('electron-squirrel-startup')) {
  app.quit();
}

let mainWindow;
let backendProcess;

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
    icon: path.join(__dirname, 'icon.ico')
  });

  // Load the Next.js app
  mainWindow.loadURL('http://localhost:3000');

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
};

// Start the backend server
const startBackend = () => {
  const backendPath = path.join(__dirname, 'backend');
  
  // Check if we're in a packaged app or development
  const pythonPath = process.platform === 'win32' ? 
    path.join(process.resourcesPath, 'backend', 'venv', 'Scripts', 'python.exe') :
    path.join(process.resourcesPath, 'backend', 'venv', 'bin', 'python');
    
  const scriptPath = process.platform === 'win32' ?
    path.join(process.resourcesPath, 'backend', 'main.py') :
    path.join(process.resourcesPath, 'backend', 'main.py');

  // For development, use local paths
  const devPythonPath = path.join(backendPath, 'venv', process.platform === 'win32' ? 'Scripts' : 'bin', 'python.exe');
  const devScriptPath = path.join(backendPath, 'main.py');
  
  const useDevPaths = fs.existsSync(backendPath);
  const finalPythonPath = useDevPaths ? devPythonPath : pythonPath;
  const finalScriptPath = useDevPaths ? devScriptPath : scriptPath;

  backendProcess = spawn(finalPythonPath, [finalScriptPath], {
    cwd: useDevPaths ? backendPath : path.join(process.resourcesPath, 'backend'),
    env: { ...process.env, PYTHONPATH: useDevPaths ? backendPath : path.join(process.resourcesPath, 'backend') }
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

// Kill backend process when app quits
const killBackend = () => {
  if (backendProcess) {
    backendProcess.kill();
  }
};

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
  startBackend();
  
  createWindow();

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
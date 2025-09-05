const { spawn, exec } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🛑 Stopping LylyReader...');

// Create shutdown flag file
const shutdownFlagPath = path.join(__dirname, 'shutdown.flag');
try {
  fs.writeFileSync(shutdownFlagPath, 'shutdown');
  console.log('✅ Shutdown flag created');
} catch (err) {
  console.error('❌ Error creating shutdown flag:', err.message);
}

// Try to stop processes on ports 8000 and 3000
const platform = process.platform;

if (platform === 'win32') {
  // Windows
  console.log('🔍 Checking for processes on ports 8000 and 3000 (Windows)...');
  
  exec('netstat -ano', (error, stdout, stderr) => {
    if (error) {
      console.error('❌ Error running netstat:', error.message);
      return;
    }
    
    const lines = stdout.split('\n');
    const ports = [8000, 3000];
    
    ports.forEach(port => {
      lines.forEach(line => {
        if (line.includes(`:${port} `) || line.includes(`:${port}\t`)) {
          const parts = line.trim().split(/\s+/);
          if (parts.length > 0) {
            const pid = parts[parts.length - 1];
            if (pid && /^\d+$/.test(pid)) {
              console.log(`🔄 Terminating process ${pid} on port ${port}...`);
              exec(`taskkill /PID ${pid} /F`, (killError, killStdout, killStderr) => {
                if (killError) {
                  console.error(`❌ Error terminating PID ${pid}:`, killError.message);
                } else {
                  console.log(`✅ Process ${pid} terminated`);
                }
              });
            }
          }
        }
      });
    });
  });
} else {
  // Unix-like systems (macOS, Linux)
  console.log('🔍 Checking for processes on ports 8000 and 3000 (Unix)...');
  
  const ports = [8000, 3000];
  
  ports.forEach(port => {
    const lsof = spawn('lsof', [`-i:${port}`, '-t']);
    
    lsof.stdout.on('data', (data) => {
      const pids = data.toString().trim().split('\n').filter(pid => pid);
      pids.forEach(pid => {
        if (pid && /^\d+$/.test(pid)) {
          console.log(`🔄 Terminating process ${pid} on port ${port}...`);
          const kill = spawn('kill', ['-9', pid]);
          
          kill.on('close', (code) => {
            if (code === 0) {
              console.log(`✅ Process ${pid} terminated`);
            } else {
              console.error(`❌ Error terminating PID ${pid}`);
            }
          });
        }
      });
    });
    
    lsof.on('error', (error) => {
      if (error.code === 'ENOENT') {
        console.error('❌ lsof command not found. Please install lsof to use this script.');
      } else {
        console.error(`❌ Error running lsof: ${error.message}`);
      }
    });
  });
}

// Wait a bit for processes to terminate
setTimeout(() => {
  console.log('✅ Stop script completed. Please verify that processes have terminated.');
}, 3000);
@echo off
setlocal enabledelayedexpansion

rem Arquivo de log para ações de parada
set LOG_FILE=%cd%\stop-local.log
echo %date% %time% - Iniciando stop-local.bat > "%LOG_FILE%"

echo PARANDO AUDIOBOOK GENERATOR (MODO LOCAL)
echo ==========================================

set PROCESSES_FOUND=0
set BACKEND_STOPPED=0
set FRONTEND_STOPPED=0
set PROJECT_ROOT=%cd%

:get_last_token
rem Recebe uma linha como argumento e define a variavel LAST com o ultimo token
rem Uso: call :get_last_token "%%L"
setlocal ENABLEDELAYEDEXPANSION
set "last="
set "line=%~1"
for %%T in (%line%) do set "last=%%T"
endlocal & set "LAST=%last%"
goto :eof

REM === PARAR PROCESSOS POR PORTA ===

echo Procurando processos nas portas 8000 e 3000...

rem Tentativa rápida via PowerShell (Get-NetTCPConnection) para listar e finalizar processos que escutam nas portas 3000 e 8000
echo %date% %time% - PowerShell: listando conexoes para portas 3000 e 8000 >> "%LOG_FILE%"
powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 3000,8000 -ErrorAction SilentlyContinue | Select-Object LocalAddress,LocalPort,State,OwningProcess | Format-Table -AutoSize | Out-String" >> "%LOG_FILE%" 2>&1
echo %date% %time% - PowerShell: tentando finalizar processos que atendem nas portas 3000 e 8000 >> "%LOG_FILE%"
powershell -NoProfile -Command "$ports=@(3000,8000); foreach($p in $ports){ $conns=Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue; foreach($c in $conns){ $pid=$c.OwningProcess; if($pid -and $pid -ne 0){ try{ Stop-Process -Id $pid -Force -ErrorAction Stop; Write-Output \"Killed PID $pid for port $p\" } catch { Write-Output \"Failed to kill PID $pid for port $p: $_\" } } } }" >> "%LOG_FILE%" 2>&1
echo %date% %time% - PowerShell exit code: %ERRORLEVEL% >> "%LOG_FILE%"

echo %date% %time% - PowerShell: enumerando processos candidatas (Node/Next) por CommandLine e tentando finalizar >> "%LOG_FILE%"
powershell -NoProfile -Command "try { 
    $candidates = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { 
        ($_.CommandLine -and ($_.CommandLine -match 'next' -or $_.CommandLine -match 'node' -or $_.CommandLine -match 'npm')) -and 
        ($_.CommandLine -match 'frontend' -or $_.CommandLine -match 'audiobook' -or $_.CommandLine -match 'next dev' -or $_.CommandLine -match 'next start')
    } 
    if(-not $candidates){ Write-Output 'No candidate Node/Next processes found' } 
    foreach($p in $candidates){ 
        $pid=$p.ProcessId; 
        Write-Output "Found candidate PID=$pid CommandLine=$($p.CommandLine)"; 
        try{ Stop-Process -Id $pid -Force -ErrorAction Stop; Write-Output "Stopped PID $pid via Stop-Process" } 
        catch { 
            Write-Output "Stop-Process failed for PID $pid: $_"; 
            Write-Output "Attempting fallback taskkill for PID $pid"; 
            cmd /c "taskkill /F /PID $pid" | Out-String | Write-Output; 
        } 
    } 
} catch { Write-Output "PowerShell enumeration failed: $_" } | Out-String" >> "%LOG_FILE%" 2>&1
echo %date% %time% - PowerShell Node enumeration exit code: %ERRORLEVEL% >> "%LOG_FILE%"

echo %date% %time% - PowerShell: buscando processos Node/Next especificamente no path do frontend (%PROJECT_ROOT%\frontend) >> "%LOG_FILE%"
powershell -NoProfile -Command "try { 
    $frontendPath = '%PROJECT_ROOT%\\frontend' ; Write-Output \"Frontend path filter: $frontendPath\"; 
    $procs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -and ($_.CommandLine -match $frontendPath -or $_.CommandLine -match 'start-server.js' -or $_.CommandLine -match 'next') } ;
    if(-not $procs) { Write-Output 'No frontend candidate processes found' } 
    foreach($p in $procs) { 
        $pid = $p.ProcessId; $cmd = $p.CommandLine; Write-Output "Candidate PID=$pid CMD=$cmd"; 
        try { Stop-Process -Id $pid -Force -ErrorAction Stop; Write-Output "Stopped PID $pid via Stop-Process" } 
        catch { Write-Output "Stop-Process failed for PID $pid: $_"; Write-Output "Attempting taskkill for PID $pid"; cmd /c "taskkill /F /PID $pid" | Write-Output } 
    }
} catch { Write-Output "PowerShell frontend enumeration failed: $_" } | Out-String" >> "%LOG_FILE%" 2>&1
echo %date% %time% - PowerShell frontend enumeration exit code: %ERRORLEVEL% >> "%LOG_FILE%"

REM Parar processos na porta 8000 (Backend)
echo.
echo Verificando backend na porta 8000...
for /f "usebackq delims=" %%L in (`netstat -ano 2^>nul ^| findstr ":8000"`) do (
    rem extrai o ultimo token da linha (PID)
    call :get_last_token "%%L"
    set PID=!LAST!
    if defined PID (
        if "!PID!" neq "0" (
            echo Processo encontrado na porta 8000 (PID: !PID!)
            echo %date% %time% - Processo encontrado na porta 8000 (PID: !PID!) >> "%LOG_FILE%"
            tasklist /FI "PID eq !PID!" 2>nul | findstr !PID! >nul
            if !errorlevel! == 0 (
                echo Encerrando processo backend (PID: !PID!)...
                echo %date% %time% - Encerrando processo backend (PID: !PID!) >> "%LOG_FILE%"
                taskkill /PID !PID! /F >nul 2>&1
                if !errorlevel! == 0 (
                    echo [OK] Processo backend encerrado com sucesso
                    echo %date% %time% - [OK] Processo backend encerrado com sucesso (PID: !PID!) >> "%LOG_FILE%"
                    set BACKEND_STOPPED=1
                ) else (
                    echo [AVISO] Falha ao encerrar processo backend (PID: !PID!)
                    echo %date% %time% - [AVISO] Falha ao encerrar processo backend (PID: !PID!) >> "%LOG_FILE%"
                )
                set PROCESSES_FOUND=1
            )
        )
    )
)

if %BACKEND_STOPPED%==0 (
    echo Nenhum processo backend encontrado na porta 8000
    echo %date% %time% - Nenhum processo backend encontrado na porta 8000 >> "%LOG_FILE%"
)

REM Parar processos na porta 3000 (Frontend)
echo.
echo Verificando frontend na porta 3000...
for /f "usebackq delims=" %%L in (`netstat -ano 2^>nul ^| findstr ":3000"`) do (
    rem extrai o ultimo token da linha (PID)
    call :get_last_token "%%L"
    set PID=!LAST!
    if defined PID (
        if "!PID!" neq "0" (
            echo Processo encontrado na porta 3000 (PID: !PID!)
            echo %date% %time% - Processo encontrado na porta 3000 (PID: !PID!) >> "%LOG_FILE%"
            tasklist /FI "PID eq !PID!" 2>nul | findstr !PID! >nul
            if !errorlevel! == 0 (
                echo Encerrando processo frontend (PID: !PID!)...
                echo %date% %time% - Encerrando processo frontend (PID: !PID!) >> "%LOG_FILE%"
                taskkill /PID !PID! /F >nul 2>&1
                if !errorlevel! == 0 (
                    echo [OK] Processo frontend encerrado com sucesso
                    echo %date% %time% - [OK] Processo frontend encerrado com sucesso (PID: !PID!) >> "%LOG_FILE%"
                    set FRONTEND_STOPPED=1
                ) else (
                    echo [AVISO] Falha ao encerrar processo frontend (PID: !PID!)
                    echo %date% %time% - [AVISO] Falha ao encerrar processo frontend (PID: !PID!) >> "%LOG_FILE%"
                )
                set PROCESSES_FOUND=1
            )
        )
    )
)

if %FRONTEND_STOPPED%==0 (
    echo Nenhum processo frontend encontrado na porta 3000
    echo %date% %time% - Nenhum processo frontend encontrado na porta 3000 >> "%LOG_FILE%"
)

REM === PARAR PROCESSOS POR NOME (BACKUP) ===

echo.
echo Verificando processos por nome (backup)...

REM Procurar processos Python relacionados ao projeto
echo Procurando processos Python do audiobook generator...
tasklist /FI "IMAGENAME eq python.exe" 2>nul | findstr python.exe >nul
if %errorlevel% == 0 (
    for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq python.exe" /FO CSV 2^>nul ^| findstr python.exe') do (
        set PID=%%~a
    echo Verificando processo Python (PID: !PID!)...
    echo %date% %time% - Verificando processo Python (PID: !PID!) >> "%LOG_FILE%"
        
        REM Verificar se e o processo do nosso backend (verificacao simples)
        wmic process where "ProcessId=!PID!" get CommandLine 2>nul | findstr "main.py" >nul
        if !errorlevel! == 0 (
            echo Encerrando processo Python do backend (PID: !PID!)...
            echo %date% %time% - Encerrando processo Python do backend (PID: !PID!) >> "%LOG_FILE%"
            taskkill /PID !PID! /F >nul 2>&1
            if !errorlevel! == 0 (
                echo [OK] Processo Python encerrado
                echo %date% %time% - [OK] Processo Python encerrado (PID: !PID!) >> "%LOG_FILE%"
                set PROCESSES_FOUND=1
            )
        )
    )
)

REM Procurar processos Node.js relacionados ao projeto
echo Procurando processos Node.js do audiobook generator...
tasklist /FI "IMAGENAME eq node.exe" 2>nul | findstr node.exe >nul
if %errorlevel% == 0 (
    for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq node.exe" /FO CSV 2^>nul ^| findstr node.exe') do (
        set PID=%%~a
    echo Verificando processo Node.js (PID: !PID!)...
        echo %date% %time% - Verificando processo Node.js (PID: !PID!) >> "%LOG_FILE%"

        REM Obter a linha de comando do processo e verificar se associa ao frontend
        for /f "usebackq tokens=*" %%L in (`wmic process where "ProcessId=!PID!" get CommandLine /VALUE 2^>nul ^| findstr /I "CommandLine"`) do (
            set "cmdline=%%L"
            set "cmdline=!cmdline:CommandLine=!"
        )

        set "IS_FRONTEND=0"
        if defined cmdline (
            echo %date% %time% - Linha de comando: !cmdline! >> "%LOG_FILE%"
            echo !cmdline! | findstr /I "%PROJECT_ROOT%\\frontend" >nul
            if !errorlevel! == 0 set "IS_FRONTEND=1"
            echo !cmdline! | findstr /I "next" >nul
            if !errorlevel! == 0 set "IS_FRONTEND=1"
            echo !cmdline! | findstr /I "npm" >nul
            if !errorlevel! == 0 set "IS_FRONTEND=1"
        )

        if !IS_FRONTEND! == 1 (
            echo Encerrando processo Node.js do frontend (PID: !PID!)...
            echo %date% %time% - Encerrando processo Node.js do frontend (PID: !PID!) >> "%LOG_FILE%"
            taskkill /PID !PID! /F >nul 2>&1
            if !errorlevel! == 0 (
                echo [OK] Processo Node.js encerrado
                echo %date% %time% - [OK] Processo Node.js encerrado (PID: !PID!) >> "%LOG_FILE%"
                set PROCESSES_FOUND=1
                set FRONTEND_STOPPED=1
            ) else (
                echo [AVISO] Falha ao encerrar processo Node.js (PID: !PID!)
                echo %date% %time% - [AVISO] Falha ao encerrar processo Node.js (PID: !PID!) >> "%LOG_FILE%"
            )
        )
    )
)

REM === VERIFICAR E LIMPAR RECURSOS ===

echo.
echo Limpando recursos...

REM Verificar se as portas foram liberadas
echo Verificando se as portas foram liberadas...
echo %date% %time% - Verificando se as portas foram liberadas... >> "%LOG_FILE%"
timeout /t 2 /nobreak >nul

netstat -an 2>nul | findstr ":8000" >nul
if %errorlevel% == 0 (
    echo [AVISO] Porta 8000 ainda em uso
    echo %date% %time% - [AVISO] Porta 8000 ainda em uso >> "%LOG_FILE%"
) else (
    echo [OK] Porta 8000 liberada
    echo %date% %time% - [OK] Porta 8000 liberada >> "%LOG_FILE%"
)

netstat -an 2>nul | findstr ":3000" >nul
if %errorlevel% == 0 (
    echo [AVISO] Porta 3000 ainda em uso
    echo %date% %time% - [AVISO] Porta 3000 ainda em uso >> "%LOG_FILE%"
) else (
    echo [OK] Porta 3000 liberada
    echo %date% %time% - [OK] Porta 3000 liberada >> "%LOG_FILE%"
)

REM === LIMPEZA DE ARQUIVOS TEMPORARIOS ===

echo.
echo Limpando arquivos temporarios...

REM Limpar arquivos de lock do npm (se existirem)
if exist "frontend\.next" (
    echo Limpando cache do Next.js...
    echo %date% %time% - Limpando cache do Next.js... >> "%LOG_FILE%"
    rmdir /s /q "frontend\.next" 2>nul
    if %errorlevel% == 0 (
        echo [OK] Cache do Next.js limpo
        echo %date% %time% - [OK] Cache do Next.js limpo >> "%LOG_FILE%"
    )
)

REM Limpar arquivos de PID (se existirem)
if exist "*.pid" (
    echo Removendo arquivos PID...
    echo %date% %time% - Removendo arquivos PID... >> "%LOG_FILE%"
    del *.pid 2>nul
)

if exist "backend\*.pid" (
    del backend\*.pid 2>nul
    echo %date% %time% - Removidos backend\*.pid (se existiam) >> "%LOG_FILE%"
)

REM === RELATORIO FINAL ===

echo.
echo ==========================================
echo RELATORIO DE ENCERRAMENTO:
echo ==========================================

if %PROCESSES_FOUND%==1 (
    echo [OK] Processos encontrados e encerrados
    echo %date% %time% - [OK] Processos encontrados e encerrados >> "%LOG_FILE%"
    if %BACKEND_STOPPED%==1 (
        echo   Backend: Encerrado
    )
    if %FRONTEND_STOPPED%==1 (
        echo   Frontend: Encerrado
    )
else (
    echo Nenhum processo ativo encontrado
)

echo.
echo INSTRUCOES ADICIONAIS:
echo   Se algum processo ainda estiver rodando, feche manualmente as janelas do terminal
echo   Para reiniciar o sistema, execute start-local.bat
echo   Use o Gerenciador de Tarefas se necessario para verificar processos restantes

echo.
echo [OK] Procedimento de parada concluido!
echo ==========================================
echo %date% %time% - [OK] Procedimento de parada concluido! >> "%LOG_FILE%"
pause
@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo  LYLIREADER - LOCAL MODE
echo ==========================================
echo Versao: 2.0 - Inicializacao Aprimorada
echo Modo: Desenvolvimento Local
echo ==========================================

REM === VERIFICACOES INICIAIS DE DEPENDENCIAS ===

echo.
echo VERIFICANDO DEPENDENCIAS DO SISTEMA...
echo ==========================================

set ALL_DEPS_OK=1

REM Verificar Python
echo Verificando Python...
python --version >nul 2>&1
if %errorlevel% == 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do echo [OK] Python %%i encontrado
) else (
    echo [ERRO] Python nao encontrado!
    echo Instale Python 3.8+ de: https://python.org/downloads/
    set ALL_DEPS_OK=0
)

REM Verificar Node.js
echo Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% == 0 (
    for /f "tokens=1" %%i in ('node --version 2^>^&1') do echo [OK] Node.js %%i encontrado
) else (
    echo [ERRO] Node.js nao encontrado!
    echo Instale Node.js 18+ de: https://nodejs.org/
    set ALL_DEPS_OK=0
)

REM Verificar se as portas estao livres
echo Verificando portas...
netstat -an 2>nul | findstr ":8000" >nul
if %errorlevel% == 0 (
    echo [AVISO] Porta 8000 em uso! Tentando liberar...
    for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr :8000') do (
        taskkill /PID %%a /F >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
) else (
    echo [OK] Porta 8000 livre
)

netstat -an 2>nul | findstr ":3000" >nul
if %errorlevel% == 0 (
    echo [AVISO] Porta 3000 em uso! Tentando liberar...
    for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr :3000') do (
        taskkill /PID %%a /F >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
) else (
    echo [OK] Porta 3000 livre
)

REM Verificar estrutura do projeto
echo Verificando estrutura do projeto...
if not exist "backend" (
    echo [ERRO] Diretorio 'backend' nao encontrado!
    set ALL_DEPS_OK=0
) else (
    echo [OK] Diretorio backend encontrado
)

if not exist "frontend" (
    echo [ERRO] Diretorio 'frontend' nao encontrado!
    set ALL_DEPS_OK=0
) else (
    echo [OK] Diretorio frontend encontrado
)

if %ALL_DEPS_OK%==0 (
    echo.
    echo [ERRO] Dependencias faltando! Corrija os problemas acima antes de continuar.
    pause
    exit /b 1
)

REM === VERIFICACAO E INSTALACAO DO FFMPEG ===

echo.
echo VERIFICANDO FFMPEG...
echo ==========================================

ffmpeg -version >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] FFmpeg ja esta instalado!
    for /f "tokens=1,2,3" %%a in ('ffmpeg -version 2^>^&1 ^| findstr "ffmpeg version"') do (
        echo Versao: %%a %%b %%c
    )
) else (
    echo [AVISO] FFmpeg nao encontrado!
    echo.
    echo Iniciando instalacao automatica do FFmpeg...
    echo Este processo pode demorar alguns minutos...
    
    REM Tentar instalar via winget primeiro
    winget --version >nul 2>&1
    if !errorlevel! == 0 (
        echo Tentando instalar via winget...
        winget install --id=Gyan.FFmpeg -e --silent --accept-package-agreements --accept-source-agreements
        if !errorlevel! == 0 (
            echo [OK] FFmpeg instalado via winget!
        ) else (
            echo [AVISO] Instalacao via winget falhou
        )
    ) else (
        echo [AVISO] winget nao disponivel
    )
    
    REM Verificar se funcionou
    ffmpeg -version >nul 2>&1
    if !errorlevel! == 0 (
        echo [OK] FFmpeg agora esta funcionando!
    ) else (
        echo [AVISO] FFmpeg ainda nao esta funcionando
        echo O sistema continuara, mas podera haver problemas na geracao de audio
        echo.
        echo INSTRUCOES PARA INSTALACAO MANUAL:
        echo    1. Execute: winget install --id=Gyan.FFmpeg -e
        echo    2. Ou baixe de: https://github.com/BtbN/FFmpeg-Builds/releases/
        echo    3. Reinicie este script apos a instalacao
        timeout /t 5 /nobreak >nul
    )
)

REM === INICIALIZACAO DOS SERVICOS ===

echo.
echo INICIANDO SERVICOS...
echo ==========================================

REM Criar arquivo de log para acompanhar a inicializacao
set LOG_FILE=%cd%\startup.log
echo %date% %time% - Iniciando LylyReader > "%LOG_FILE%"

echo Passo 1/3: Iniciando Backend (Python/FastAPI)...
echo %date% %time% - Iniciando backend >> "%LOG_FILE%"

REM Iniciar backend em uma nova janela
start "LylyReader - Backend" /D "%cd%" cmd /c "start-backend.bat"

echo [OK] Backend iniciando em janela separada...
echo Aguardando inicializacao do backend (10 segundos)...
timeout /t 10 /nobreak >nul

REM Verificar se o backend esta respondendo
echo Verificando se o backend esta ativo...
curl -s -f http://localhost:8000/health >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] Backend esta respondendo!
    echo %date% %time% - Backend ativo >> "%LOG_FILE%"
) else (
    echo [AVISO] Backend ainda nao respondeu (pode estar inicializando)
    echo %date% %time% - Backend nao respondeu no teste >> "%LOG_FILE%"
)

echo.
echo Passo 2/3: Iniciando Frontend (Next.js)...
echo %date% %time% - Iniciando frontend >> "%LOG_FILE%"

REM Verificar se o diretorio frontend existe
if not exist "frontend" (
    echo [ERRO] Diretorio frontend nao encontrado!
    echo %date% %time% - Erro: Diretorio frontend nao encontrado >> "%LOG_FILE%"
    pause
    exit /b 1
)

REM Verificar se package.json existe
if not exist "frontend\package.json" (
    echo [ERRO] package.json nao encontrado no frontend!
    echo %date% %time% - Erro: package.json nao encontrado >> "%LOG_FILE%"
    pause
    exit /b 1
)

REM Verificar se node_modules existe
if not exist "frontend\node_modules" (
    echo [AVISO] node_modules nao encontrado. Instalando dependencias primeiro...
    echo %date% %time% - Instalando dependencias do frontend >> "%LOG_FILE%"
    cd frontend
    npm install
    if !errorlevel! neq 0 (
        echo [ERRO] Falha ao instalar dependencias do frontend!
        echo %date% %time% - Erro na instalacao de dependencias >> "%LOG_FILE%"
        cd ..
        pause
        exit /b 1
    )
    cd ..
    echo [OK] Dependencias instaladas com sucesso
)

REM Iniciar frontend em uma nova janela
start "LylyReader - Frontend" /D "%cd%" cmd /c "start-frontend.bat && echo Frontend encerrado && pause"

echo [OK] Frontend iniciando em janela separada...
echo Aguardando inicializacao do frontend (20 segundos)...
timeout /t 20 /nobreak >nul

REM Verificar se o frontend esta respondendo
echo Verificando se o frontend esta ativo...
curl -s -f http://localhost:3000/ >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] Frontend esta respondendo!
    echo %date% %time% - Frontend ativo >> "%LOG_FILE%"
) else (
    echo [AVISO] Frontend ainda nao respondeu (pode estar compilando)
    echo %date% %time% - Frontend nao respondeu no teste >> "%LOG_FILE%"
)

REM === VERIFICACAO FINAL E ABERTURA DO NAVEGADOR ===

echo.
echo Passo 3/3: Abrindo aplicacao no navegador...
echo %date% %time% - Abrindo navegador >> "%LOG_FILE%"

echo Abrindo aplicativo no navegador...
start http://localhost:3000/

echo.
echo ==========================================
echo SISTEMA INICIALIZADO COM SUCESSO!
echo ==========================================
echo.
echo INFORMACOES DE ACESSO:
echo   Frontend: http://localhost:3000
echo   Backend API: http://localhost:8000
echo   Documentacao API: http://localhost:8000/docs
echo   Saude da API: http://localhost:8000/health
echo.
echo JANELAS ABERTAS:
echo   Backend: Janela "LylyReader - Backend"
echo   Frontend: Janela "LylyReader - Frontend"
echo.
echo PARA PARAR O SISTEMA:
echo   Execute: stop-local.bat
echo   Ou feche as janelas do backend e frontend
echo   Ou pressione Ctrl+C nas janelas dos servicos
echo.
echo STATUS FINAL:
echo %date% %time% - Sistema inicializado >> "%LOG_FILE%"

REM Verificar status final
echo Status final dos servicos:
timeout /t 2 /nobreak >nul

curl -s -f http://localhost:8000/health >nul 2>&1
if %errorlevel% == 0 (
    echo   [OK] Backend: Ativo
) else (
    echo   [AVISO] Backend: Verificar janela do backend
)

curl -s -f http://localhost:3000/ >nul 2>&1
if %errorlevel% == 0 (
    echo   [OK] Frontend: Ativo
) else (
    echo   [AVISO] Frontend: Verificar janela do frontend
)

echo.

echo Aproveite o LylyReader!
echo ==========================================

REM === MONITORAMENTO DE SHUTDOWN ===
set SHUTDOWN_FLAG=%cd%\shutdown.flag
set MONITOR_INTERVAL=5

echo.
echo Monitorando sinal de encerramento...
:monitor_shutdown
if exist "%SHUTDOWN_FLAG%" (
    echo Sinal de encerramento detectado!
    echo Encerrando todos os serviços...
    call stop-local.bat
    del "%SHUTDOWN_FLAG%"
    echo Todos os serviços foram encerrados.
    goto end_script
)
timeout /t %MONITOR_INTERVAL% /nobreak >nul
goto monitor_shutdown

:end_script
echo.
echo Sistema encerrado automaticamente.
timeout /t 2 /nobreak >nul
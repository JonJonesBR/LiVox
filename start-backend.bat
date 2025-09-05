@echo off
setlocal enabledelayedexpansion

echo INICIANDO BACKEND DO LYLIREADER (LOCAL)
echo ==========================================

REM === VERIFICACOES DE DEPENDENCIAS ===

REM Verificar se Python esta instalado
echo Verificando Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Python nao encontrado!
    echo Por favor, instale Python 3.8 ou superior de: https://python.org/downloads/
    echo Certifique-se de marcar "Add Python to PATH" durante a instalacao
    pause
    exit /b 1
)
echo [OK] Python encontrado

REM Verificar se pip esta funcionando
echo Verificando pip...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] pip nao encontrado!
    echo Reinstale Python com pip incluido
    pause
    exit /b 1
)
echo [OK] pip encontrado

REM === VERIFICACAO E INSTALACAO DO FFMPEG ===

echo.
echo VERIFICANDO FFMPEG...
echo ==========================================

ffmpeg -version >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] FFmpeg encontrado
) else (
    echo [AVISO] FFmpeg nao encontrado!
    echo.
    echo Tentando instalar FFmpeg automaticamente...
    
    REM Tentar instalar via winget primeiro
    winget --version >nul 2>&1
    if !errorlevel! == 0 (
        echo Instalando FFmpeg via winget...
        winget install --id=Gyan.FFmpeg -e --silent --accept-package-agreements --accept-source-agreements
        
        REM Verificar se a instalacao foi bem-sucedida
        ffmpeg -version >nul 2>&1
        if !errorlevel! == 0 (
            echo [OK] FFmpeg instalado com sucesso!
        ) else (
            echo [AVISO] Instalacao via winget falhou ou requer reinicializacao do terminal
            echo INSTRUCOES DE INSTALACAO MANUAL:
            echo    1. Execute: winget install --id=Gyan.FFmpeg -e
            echo    2. Ou acesse: https://github.com/BtbN/FFmpeg-Builds/releases/
            echo    3. Baixe "ffmpeg-master-latest-win64-gpl.zip"
            echo    4. Extraia para C:\ffmpeg
            echo    5. Adicione C:\ffmpeg\bin ao PATH do sistema
            echo    6. Reinicie este terminal
            echo.
            echo [AVISO] O backend sera iniciado, mas a geracao de audiobooks pode falhar sem o FFmpeg.
            timeout /t 5 /nobreak >nul
        )
    ) else (
        echo [ERRO] winget nao esta disponivel. Instalacao manual necessaria.
        echo INSTRUCOES DE INSTALACAO MANUAL:
        echo    1. Acesse: https://github.com/BtbN/FFmpeg-Builds/releases/
        echo    2. Baixe "ffmpeg-master-latest-win64-gpl.zip"
        echo    3. Extraia para C:\ffmpeg
        echo    4. Adicione C:\ffmpeg\bin ao PATH do sistema
        echo    5. Reinicie este terminal
        echo.
        echo [AVISO] O backend sera iniciado, mas a geracao de audiobooks falhara sem o FFmpeg.
        timeout /t 5 /nobreak >nul
    )
)

REM === CONFIGURACAO DO AMBIENTE VIRTUAL ===

echo.
echo Configurando ambiente virtual Python...

REM Verificar se o diretorio backend existe
if not exist "backend" (
    echo [ERRO] Diretorio 'backend' nao encontrado!
    echo Certifique-se de estar executando este script na raiz do projeto
    pause
    exit /b 1
)

REM Criar ambiente virtual se nao existir
if not exist "backend\venv" (
    echo Criando ambiente virtual...
    cd backend
    python -m venv venv
    if !errorlevel! neq 0 (
        echo [ERRO] Falha ao criar ambiente virtual!
        echo Verifique se Python esta instalado corretamente
        cd ..
        pause
        exit /b 1
    )
    cd ..
    echo [OK] Ambiente virtual criado
) else (
    echo [OK] Ambiente virtual ja existe
)

REM Ativar ambiente virtual
echo Ativando ambiente virtual...
if not exist "backend\venv\Scripts\activate.bat" (
    echo [ERRO] Arquivo de ativacao do ambiente virtual nao encontrado!
    echo Recriando ambiente virtual...
    rmdir /s /q "backend\venv" 2>nul
    cd backend
    python -m venv venv
    if !errorlevel! neq 0 (
        echo [ERRO] Falha ao recriar ambiente virtual!
        cd ..
        pause
        exit /b 1
    )
    cd ..
)

call backend\venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao ativar ambiente virtual!
    pause
    exit /b 1
)
echo [OK] Ambiente virtual ativado

REM === INSTALACAO E ATUALIZACAO DE DEPENDENCIAS ===

echo.
echo Verificando e instalando dependencias...
cd backend

REM Verificar se requirements.txt existe
if not exist "requirements.txt" (
    echo [ERRO] Arquivo requirements.txt nao encontrado!
    echo Certifique-se de que o arquivo requirements.txt esta no diretorio backend
    cd ..
    pause
    exit /b 1
)

REM Atualizar pip para a versao mais recente
echo Atualizando pip...
pip install --upgrade pip
if %errorlevel% neq 0 (
    echo [AVISO] Falha ao atualizar pip, continuando...
)

REM Instalar dependencias
echo Instalando dependencias do Python...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao instalar dependencias!
    echo Verifique sua conexao com a internet e tente novamente
    cd ..
    pause
    exit /b 1
)
echo [OK] Dependencias instaladas com sucesso

REM === VERIFICACOES FINAIS ===

echo.
echo Realizando verificacoes finais...

REM Verificar se main.py existe
if not exist "main.py" (
    echo [ERRO] Arquivo main.py nao encontrado no diretorio backend!
    cd ..
    pause
    exit /b 1
)
echo [OK] Arquivo main.py encontrado

REM Verificar se as pastas necessarias existem
if not exist "uploads" mkdir uploads
if not exist "audiobooks" mkdir audiobooks
if not exist "static" mkdir static
echo [OK] Diretorios necessarios verificados

REM === INICIALIZACAO DO SERVIDOR ===

echo.
echo ==========================================
echo INICIANDO SERVIDOR BACKEND
echo Endereco: http://localhost:8000
echo Documentacao da API: http://localhost:8000/docs
echo Interface administrativa: http://localhost:8000/admin (se disponivel)
echo ==========================================
echo.
echo Para parar o servidor, pressione Ctrl+C
echo Logs do servidor serao exibidos abaixo:
echo.

REM Executar o servidor
python main.py

REM Se chegou aqui, o servidor foi encerrado
echo.
echo Servidor backend encerrado.
cd ..
pause
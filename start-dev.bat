@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo  AUDIOBOOK GENERATOR - MODO DOCKER
echo ==========================================
echo Versao: 1.0
echo Modo: Docker Compose
echo ==========================================

REM === VERIFICACOES INICIAIS ===

echo.
echo VERIFICANDO DEPENDENCIAS DO SISTEMA...
echo ==========================================

set ALL_DEPS_OK=1

REM Verificar Docker
echo Verificando Docker...
docker --version >nul 2>&1
if %errorlevel% == 0 (
    for /f "tokens=1,2,3" %%i in ('docker --version 2^>^&1') do echo [OK] Docker %%i %%j %%k encontrado
) else (
    echo [ERRO] Docker nao encontrado!
    echo Instale o Docker Desktop de: https://www.docker.com/products/docker-desktop
    set ALL_DEPS_OK=0
)

REM Verificar Docker Compose
echo Verificando Docker Compose...
docker-compose --version >nul 2>&1
if %errorlevel% == 0 (
    for /f "tokens=1,2,3,4" %%i in ('docker-compose --version 2^>^&1') do echo [OK] Docker Compose %%i %%j %%k %%l encontrado
) else (
    echo [ERRO] Docker Compose nao encontrado!
    echo O Docker Compose geralmente vem com o Docker Desktop
    set ALL_DEPS_OK=0
)

if %ALL_DEPS_OK%==0 (
    echo.
    echo [ERRO] Dependencias faltando! Corrija os problemas acima antes de continuar.
    pause
    exit /b 1
)

REM === VERIFICAR E PARAR CONTAINERS EXISTENTES ===

echo.
echo VERIFICANDO CONTAINERS EXISTENTES...
echo ==========================================

echo Verificando se ha containers rodando nas portas necessarias...
docker ps --filter "publish=3000" -q >nul 2>&1
set PORT_3000_CONTAINER=
for /f "delims=" %%i in ('docker ps --filter "publish=3000" -q 2^>nul') do set PORT_3000_CONTAINER=%%i

docker ps --filter "publish=8000" -q >nul 2>&1
set PORT_8000_CONTAINER=
for /f "delims=" %%i in ('docker ps --filter "publish=8000" -q 2^>nul') do set PORT_8000_CONTAINER=%%i

if defined PORT_3000_CONTAINER (
    echo [AVISO] Container encontrado na porta 3000. Parando...
    docker stop %PORT_3000_CONTAINER% >nul
    docker rm %PORT_3000_CONTAINER% >nul
)

if defined PORT_8000_CONTAINER (
    echo [AVISO] Container encontrado na porta 8000. Parando...
    docker stop %PORT_8000_CONTAINER% >nul
    docker rm %PORT_8000_CONTAINER% >nul
)

if defined PORT_3000_CONTAINER (
    echo [OK] Containers antigos na porta 3000 removidos!
)

if defined PORT_8000_CONTAINER (
    echo [OK] Containers antigos na porta 8000 removidos!
)

REM === CONSTRUIR E INICIAR OS CONTAINERS ===

echo.
echo CONSTRUINDO E INICIANDO CONTAINERS...
echo ==========================================

echo Construindo e iniciando containers com Docker Compose...
docker-compose up --build -d

if %errorlevel% neq 0 (
    echo [ERRO] Falha ao construir ou iniciar os containers!
    echo Verifique os logs acima para mais detalhes.
    pause
    exit /b 1
)

REM Aguardar um pouco para os containers iniciarem
echo Aguardando containers iniciarem (10 segundos)...
timeout /t 10 /nobreak >nul

REM === VERIFICAR STATUS DOS CONTAINERS ===

echo.
echo VERIFICANDO STATUS DOS CONTAINERS...
echo ==========================================

set BACKEND_RUNNING=
for /f "delims=" %%i in ('docker ps --filter "publish=8000" -q 2^>nul') do set BACKEND_RUNNING=%%i

set FRONTEND_RUNNING=
for /f "delims=" %%i in ('docker ps --filter "publish=3000" -q 2^>nul') do set FRONTEND_RUNNING=%%i

if defined BACKEND_RUNNING (
    echo [OK] Container do Backend esta rodando
) else (
    echo [ERRO] Container do Backend nao esta rodando
)

if defined FRONTEND_RUNNING (
    echo [OK] Container do Frontend esta rodando
) else (
    echo [ERRO] Container do Frontend nao esta rodando
)

if defined BACKEND_RUNNING if defined FRONTEND_RUNNING (
    echo.
    echo ==========================================
    echo  AMBIENTE INICIADO COM SUCESSO!
    echo ==========================================
    echo.
    echo Acesse o aplicativo em: http://localhost:3000
    echo Documentacao da API: http://localhost:8000/docs
    echo.
    echo Para parar o ambiente, execute: stop.sh
    echo.
    echo Abrindo navegador...
    start http://localhost:3000
) else (
    echo.
    echo ==========================================
    echo  ERRO AO INICIAR AMBIENTE!
    echo ==========================================
    echo.
    echo Nem todos os containers iniciaram corretamente.
    echo Verificando status dos containers:
    docker ps
    echo.
    echo Verificando logs dos containers:
    docker-compose logs --tail=20
    echo.
)

echo.
echo Processo concluido!
pause
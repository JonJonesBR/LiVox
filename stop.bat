@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo  PARANDO AUDIOBOOK GENERATOR - MODO DOCKER
echo ==========================================

REM === PARAR CONTAINERS DOCKER ===

echo.
echo PARANDO E REMOVENDO CONTAINERS...
echo ==========================================

echo Parando containers do Audiobook Generator...
docker-compose down

if %errorlevel% neq 0 (
    echo [AVISO] Erro ao parar containers ou containers ja estavam parados
) else (
    echo [OK] Containers parados e removidos com sucesso!
)

REM === VERIFICAR SE AINDA HA CONTAINERS RODANDO ===

echo.
echo VERIFICANDO SE AINDA HA CONTAINERS ATIVOS...
echo ==========================================

set ACTIVE_CONTAINERS=
for /f "delims=" %%i in ('docker ps --filter "name=audiobook" -q 2^>nul') do set ACTIVE_CONTAINERS=%%i

if defined ACTIVE_CONTAINERS (
    echo [AVISO] Ainda ha containers ativos do Audiobook Generator
    echo Listando containers ativos:
    docker ps --filter "name=audiobook"
    echo.
    echo Parando containers manualmente...
    for /f "delims=" %%i in ('docker ps --filter "name=audiobook" -q 2^>nul') do (
        echo Parando container %%i
        docker stop %%i >nul
        docker rm %%i >nul
    )
    echo [OK] Containers parados manualmente
) else (
    echo [OK] Nenhum container ativo encontrado
)

echo.
echo ==========================================
echo  AMBIENTE DOCKER PARADO COM SUCESSO!
echo ==========================================
echo.
echo O ambiente Docker foi completamente parado.
echo.
pause
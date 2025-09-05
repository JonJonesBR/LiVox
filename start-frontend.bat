@echo off
setlocal enabledelayedexpansion

echo INICIANDO FRONTEND DO LYLIREADER (LOCAL)
echo ==========================================

REM === VERIFICACOES DE DEPENDENCIAS ===

REM Verificar se Node.js esta instalado
echo Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Node.js nao encontrado!
    echo Por favor, instale Node.js 18 ou superior de: https://nodejs.org/
    echo Certifique-se de reiniciar o terminal apos a instalacao
    pause
    exit /b 1
)

REM Verificar versao do Node.js
for /f "tokens=1" %%i in ('node --version 2^>nul') do set NODE_VERSION=%%i
echo [OK] Node.js encontrado: %NODE_VERSION%

REM Verificar se npm esta disponivel
echo Verificando npm...
call npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] npm nao encontrado!
    echo npm deve ser instalado junto com Node.js. Reinstale Node.js
    pause
    exit /b 1
)

for /f "tokens=1" %%i in ('npm --version') do set NPM_VERSION=%%i
echo [OK] npm encontrado: %NPM_VERSION%

REM === CONFIGURACAO DO PROJETO FRONTEND ===

echo.
echo Configurando projeto frontend...

REM Verificar se o diretorio frontend existe
if not exist "frontend" (
    echo [ERRO] Diretorio 'frontend' nao encontrado!
    echo Certifique-se de estar executando este script na raiz do projeto
    pause
    exit /b 1
)

REM Navegar para o diretorio frontend
cd frontend

REM Verificar se package.json existe
if not exist "package.json" (
    echo [ERRO] Arquivo package.json nao encontrado no diretorio frontend!
    echo Verifique se o projeto Next.js esta configurado corretamente
    cd ..
    pause
    exit /b 1
)
echo [OK] Arquivo package.json encontrado

REM === INSTALACAO DE DEPENDENCIAS ===

echo.
echo Verificando e instalando dependencias do Node.js...

REM Verificar se node_modules existe
if not exist "node_modules" (
    echo [AVISO] node_modules nao encontrado. Instalando dependencias...
    npm install
    if !errorlevel! neq 0 (
        echo [ERRO] Falha ao instalar dependencias do Node.js!
        cd ..
        pause
        exit /b 1
    )
    echo [OK] Dependencias instaladas com sucesso.
) else (
    echo [OK] Diretorio node_modules encontrado.
)

REM === VERIFICACOES FINAIS ===

echo.
echo Realizando verificacoes finais...

REM Verificar se Next.js esta disponivel
echo Verificando Next.js...
call npx next --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Next.js nao esta disponivel!
    echo Tentando reinstalar dependencias...
    npm install
    if !errorlevel! neq 0 (
        echo [ERRO] Falha ao reinstalar dependencias!
        cd ..
        pause
        exit /b 1
    )
    
    REM Verificar novamente
    npx next --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo [ERRO] Next.js ainda nao esta disponivel apos reinstalacao!
        cd ..
        pause
        exit /b 1
    )
)
echo [OK] Next.js verificado

REM Verificar se os scripts necessarios existem
echo Verificando scripts no package.json...
findstr /C:"\"dev\":" package.json >nul
if %errorlevel% neq 0 (
    echo [ERRO] Script 'dev' nao encontrado no package.json!
    echo Verifique se o package.json tem o script dev configurado
    cd ..
    pause
    exit /b 1
)
echo [OK] Script 'dev' encontrado

REM Verificar se a porta 3000 esta livre
echo Verificando se a porta 3000 esta livre...
netstat -an | findstr ":3000" >nul 2>&1
if %errorlevel% == 0 (
    echo [AVISO] A porta 3000 ja esta em uso!
    echo O Next.js tentara usar a proxima porta disponivel
) else (
    echo [OK] Porta 3000 esta livre
)

REM Tentar compilar o projeto primeiro para detectar erros
echo.
echo Verificando compilacao do projeto...
call npx next build --dry-run >nul 2>&1
if %errorlevel% neq 0 (
    echo [AVISO] Podem haver erros de compilacao. Tentando iniciar mesmo assim...
) else (
    echo [OK] Projeto parece estar compilando corretamente
)

REM === INICIALIZACAO DO SERVIDOR ===

echo.
echo ==========================================
echo INICIANDO SERVIDOR DE DESENVOLVIMENTO NEXT.JS
echo Endereco padrao: http://localhost:3000
echo Hot reload ativado (atualizacao automatica)
echo ==========================================
echo.
echo Para parar o servidor, pressione Ctrl+C
echo Logs do servidor serao exibidos abaixo:
echo.

REM Executar o servidor de desenvolvimento
echo Executando: call npm run dev
echo Diretorio atual: %cd%
echo.
call npm run dev

REM Se chegou aqui, o servidor foi encerrado
echo.
echo [INFO] Servidor frontend encerrado.
echo [INFO] Codigo de saida: %errorlevel%
cd ..
echo Pressione qualquer tecla para fechar esta janela...
pause
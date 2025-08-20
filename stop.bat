@echo off
echo 🛑 Parando Audiobook Generator...

echo 📋 Parando todos os containers do projeto...
docker-compose down

echo 🔄 Verificando containers nas portas 3000 e 8000...
for /f %%i in ('docker ps -q --filter "publish=3000" 2^>nul') do (
    echo Parando container na porta 3000...
    docker stop %%i
)

for /f %%i in ('docker ps -q --filter "publish=8000" 2^>nul') do (
    echo Parando container na porta 8000...
    docker stop %%i
)

echo ✅ Todos os containers foram parados!

pause
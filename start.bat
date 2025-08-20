@echo off
echo 🚀 Iniciando Audiobook Generator...

echo 📦 Construindo e iniciando containers...
docker-compose up --build -d

echo ✅ Ambiente iniciado com sucesso!
echo 🌐 Backend disponível em: http://localhost:8000
echo 📚 Documentação da API: http://localhost:8000/docs
echo 🎉 Frontend disponível em: http://localhost:3000

echo ⏳ Aguardando containers iniciarem...
timeout /t 8 /nobreak >nul

echo 🌐 Abrindo aplicação no navegador...
start http://localhost:3000

echo ✅ Aplicação iniciada! Fechando terminal...
timeout /t 2 /nobreak >nul
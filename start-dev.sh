#!/bin/bash

# Script para iniciar o ambiente de desenvolvimento do Audiobook Generator

echo "🚀 Iniciando Audiobook Generator..."


# Construir e iniciar os containers
echo "📦 Construindo e iniciando containers..."
docker-compose up --build -d

echo "✅ Ambiente iniciado com sucesso!"
echo "🌐 Backend disponível em: http://localhost:8000"
echo "📚 Documentação da API: http://localhost:8000/docs"
echo "🎉 O aplicativo estará disponível em: http://localhost:3000"

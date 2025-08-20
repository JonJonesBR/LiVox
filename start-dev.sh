#!/bin/bash

# Script para iniciar o ambiente de desenvolvimento do Audiobook Generator

echo "🚀 Iniciando Audiobook Generator..."

# Verificar se há containers rodando nas portas 3000 e 8000
echo "🔍 Verificando se as portas estão livres..."
PORT_3000_CONTAINER=$(docker ps --filter "publish=3000" -q)
PORT_8000_CONTAINER=$(docker ps --filter "publish=8000" -q)

if [ ! -z "$PORT_3000_CONTAINER" ] || [ ! -z "$PORT_8000_CONTAINER" ]; then
    echo "⚠️  Containers já estão rodando nas portas necessárias."
    echo "🛑 Parando containers existentes..."
    
    if [ ! -z "$PORT_3000_CONTAINER" ]; then
        docker stop $PORT_3000_CONTAINER
        docker rm $PORT_3000_CONTAINER
    fi
    
    if [ ! -z "$PORT_8000_CONTAINER" ]; then
        docker stop $PORT_8000_CONTAINER  
        docker rm $PORT_8000_CONTAINER
    fi
    
    echo "✅ Containers antigos removidos!"
fi

# Construir e iniciar os containers
echo "📦 Construindo e iniciando containers..."
docker-compose up --build -d

# Aguardar um pouco para os containers iniciarem
echo "⏳ Aguardando containers iniciarem..."
sleep 5

# Verificar se os containers estão rodando
echo "🔍 Verificando status dos containers..."
BACKEND_RUNNING=$(docker ps --filter "publish=8000" -q)
FRONTEND_RUNNING=$(docker ps --filter "publish=3000" -q)

if [ ! -z "$BACKEND_RUNNING" ] && [ ! -z "$FRONTEND_RUNNING" ]; then
    echo "✅ Ambiente iniciado com sucesso!"
    echo "🌐 Backend disponível em: http://localhost:8000"
    echo "📚 Documentação da API: http://localhost:8000/docs"
    echo "🎉 Frontend disponível em: http://localhost:3000"
    echo ""
    echo "📋 Status dos containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "publish=3000"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "publish=8000"
else
    echo "❌ Erro: Nem todos os containers iniciaram corretamente"
    echo "📋 Containers rodando:"
    docker ps
    echo ""
    echo "📋 Logs dos containers:"
    docker-compose logs --tail=20
fi

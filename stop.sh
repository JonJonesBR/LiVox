#!/bin/bash

# Script para parar o ambiente do LylyReader

echo "🛑 Parando LylyReader..."

# Primeiro, tentar parar com docker-compose
echo "📋 Tentando parar com docker-compose..."
docker-compose down

# Verificar containers específicos do audiobook
echo "🔍 Verificando containers do audiobook..."
AUDIOBOOK_CONTAINERS=$(docker ps -q --filter "name=audiobook")

if [ ! -z "$AUDIOBOOK_CONTAINERS" ]; then
    echo "🔄 Forçando parada de containers do audiobook..."
    docker stop $AUDIOBOOK_CONTAINERS
    docker rm $AUDIOBOOK_CONTAINERS
fi

# Verificar containers nas portas 3000 e 8000
echo "🔍 Verificando containers nas portas 3000 e 8000..."
PORT_3000_CONTAINER=$(docker ps --filter "publish=3000" -q)
PORT_8000_CONTAINER=$(docker ps --filter "publish=8000" -q)

if [ ! -z "$PORT_3000_CONTAINER" ]; then
    echo "🔄 Parando container na porta 3000..."
    docker stop $PORT_3000_CONTAINER
    docker rm $PORT_3000_CONTAINER
fi

if [ ! -z "$PORT_8000_CONTAINER" ]; then
    echo "🔄 Parando container na porta 8000..."
    docker stop $PORT_8000_CONTAINER
    docker rm $PORT_8000_CONTAINER
fi

# Verificar se ainda há containers rodando
REMAINING=$(docker ps -q)
if [ ! -z "$REMAINING" ]; then
    echo "⚠️  Ainda há containers rodando:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "✅ Todos os containers foram parados!"
fi

echo "✅ Script de parada concluído!"

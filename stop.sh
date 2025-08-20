#!/bin/bash

# Script para parar o ambiente do Audiobook Generator

echo "🛑 Parando Audiobook Generator..."

# Parar os containers
docker-compose stop audiobook-frontend audiobook-backend

# Remover volumes (opcional - descomente se quiser limpar tudo)
# docker-compose down -v

echo "✅ Ambiente parado com sucesso!"

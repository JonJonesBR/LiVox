FROM python:3.11-slim

# Instalar dependências do sistema incluindo Docker CLI
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    && curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && rm get-docker.sh \
    && rm -rf /var/lib/apt/lists/*

# Configurar diretório de trabalho
WORKDIR /app

# Copiar requirements e instalar dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código do aplicativo
COPY main.py .

# Criar diretórios necessários
RUN mkdir -p uploads audiobooks static

# Expor porta
EXPOSE 8000

# Comando para executar o aplicativo
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
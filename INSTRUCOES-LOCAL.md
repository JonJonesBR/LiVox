# 📋 Guia de Execução Local do Audiobook Generator

Este guia explica como executar o Audiobook Generator localmente sem depender do Docker.

## 🚀 Iniciando o Sistema

### Opção 1: Iniciar Tudo Automaticamente (Recomendado)
Execute o script principal que inicia ambos os serviços:

```
start-local.bat
```

Este script irá:
1. Verificar e instalar automaticamente o FFmpeg se necessário
2. Criar e configurar um ambiente virtual Python
3. Instalar todas as dependências necessárias
4. Iniciar o backend (API) em uma janela separada
5. Iniciar o frontend (Next.js) nesta janela
6. Abrir automaticamente o navegador no endereço correto

### Opção 2: Iniciar Serviços Separadamente

Se preferir ter mais controle sobre cada serviço:

**Iniciar o Backend (API):**
```
start-backend.bat
```

**Iniciar o Frontend (Interface):**
```
start-frontend.bat
```

> **Nota**: O script `start-backend.bat` verificará automaticamente se o FFmpeg está instalado e tentará instalá-lo automaticamente caso não esteja.

## 🛑 Parando o Sistema

### Opção 1: Parar Tudo
Execute o script de parada:

```
stop-local.bat
```

Este script irá orientá-lo sobre como fechar as janelas dos terminais.

### Opção 2: Parar Manualmente
Basta fechar as janelas dos terminais onde os serviços estão rodando.

## 📝 Notas Importantes

1. **Portas**: Certifique-se de que as portas 8000 (backend) e 3000 (frontend) estejam disponíveis.
2. **Dependências**: Os scripts irão instalar automaticamente todas as dependências necessárias na primeira execução.
3. **FFmpeg**: O script verificará automaticamente se o FFmpeg está instalado e tentará instalá-lo. Se preferir instalar manualmente, veja `FFMPEG-INSTALL.md`.
4. **Python**: É necessário ter o Python 3.11+ instalado.
5. **Node.js**: É necessário ter o Node.js 18+ instalado.

## 🔧 Solução de Problemas

### Backend não inicia
- Verifique se a porta 8000 está disponível
- Confira se todas as dependências estão instaladas corretamente
- Verifique se há erros no terminal do backend

### Frontend não inicia
- Verifique se a porta 3000 está disponível
- Confira se o Node.js está instalado corretamente
- Verifique se há erros no terminal do frontend

### Áudio não é gerado
- Verifique se o FFmpeg foi instalado corretamente
- Confirme se há espaço em disco suficiente
- Verifique os logs do backend para erros

### Instalação automática do FFmpeg falha
- Tente instalar manualmente seguindo as instruções em `FFMPEG-INSTALL.md`
- Verifique se tem permissões de administrador
- Confirme se há conexão com a internet
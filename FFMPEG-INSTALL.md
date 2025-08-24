# 🛠️ Instruções para Instalar o FFmpeg

O FFmpeg é uma ferramenta essencial para o funcionamento correto do Audiobook Generator, pois é responsável por unificar as partes do áudio geradas durante o processo de criação do audiobook.

## 📋 Por que o FFmpeg é necessário?

Durante o processo de geração do audiobook, o sistema cria várias partes de áudio que precisam ser unificadas em um único arquivo final. O FFmpeg é a ferramenta utilizada para essa tarefa.

## 🚀 Como instalar o FFmpeg no Windows

### Opção 1: Download direto (Recomendado)

1. Acesse o site oficial: https://github.com/BtbN/FFmpeg-Builds/releases/
2. Baixe a versão "ffmpeg-master-latest-win64-gpl.zip" (é a mais completa)
3. Extraia o arquivo ZIP para uma pasta de sua escolha (ex: `C:\ffmpeg`)
4. Adicione o caminho ao PATH do sistema:
   - Clique com o botão direito em "Este Computador" → "Propriedades"
   - Clique em "Configurações avançadas do sistema"
   - Clique em "Variáveis de Ambiente"
   - Na seção "Variáveis do sistema", selecione "Path" e clique "Editar"
   - Clique "Novo" e adicione o caminho: `C:\ffmpeg\bin` (ou o caminho onde você extraiu o FFmpeg)
   - Clique "OK" para confirmar todas as janelas

### Opção 2: Usando Chocolatey (se tiver instalado)

```bash
choco install ffmpeg
```

### Opção 3: Usando Scoop (se tiver instalado)

```bash
scoop install ffmpeg
```

## ✅ Verificando a instalação

Após a instalação, abra um novo prompt de comando e execute:

```bash
ffmpeg -version
```

Você deve ver informações sobre a versão do FFmpeg instalada.

## 🔄 Reiniciando o Audiobook Generator

Após instalar o FFmpeg:
1. Feche todos os terminais do Audiobook Generator
2. Reinicie o sistema (recomendado)
3. Execute novamente o Audiobook Generator usando `start-local.bat`

## ❓ Problemas Comuns

Se mesmo após a instalação você continuar vendo o erro:
- Verifique se o caminho foi adicionado corretamente ao PATH
- Tente reiniciar o computador após a instalação
- Certifique-se de que está usando a versão mais recente do FFmpeg

Se precisar de ajuda adicional, você pode verificar o guia completo em: https://www.youtube.com/watch?v=YTnDYki4J6Y
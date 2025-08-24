# 🔊 Audiobook Generator

Transforme seus documentos e e-books em audiobooks com vozes naturais e de alta qualidade usando tecnologia de ponta.

> 🎯 **Modo Fácil para Iniciantes**: Basta clicar duas vezes no arquivo `start-local.bat` e o programa faz todo o resto!

## 🌟 Recursos Principais

- **Múltiplos Formatos**: Suporte para PDF, TXT, EPUB, DOC e DOCX
- **Vozes Naturais**: Utiliza Microsoft Edge TTS para vozes realistas
- **Otimização com IA**: Opção de usar Google Gemini para melhorar o texto
- **Interface Moderna**: Frontend responsivo com Next.js e shadcn/ui
- **Fácil Implantação**: Suporte a Docker para ambiente consistente
- **Progresso em Tempo Real**: Acompanhe o status da conversão

## 🚀 Como Executar (Modo Fácil)

### Requisitos Mínimos do Sistema

- **Windows**: Windows 10 ou superior
- **Memória**: 4GB de RAM (recomendado 8GB)
- **Espaço em disco**: 500MB livres
- **Conexão com internet**: Para download de dependências

### Opção 1: Executar com Um Clique (Recomendado para Iniciantes)

Se você estiver no Windows, basta executar o arquivo `start-local.bat` e o programa irá:

1. Verificar se todos os programas necessários estão instalados
2. Instalar automaticamente o que for preciso (como FFmpeg)
3. Configurar tudo sozinho
4. Abrir o navegador automaticamente quando estiver pronto

**Passos:**
1. Dê um clique duplo no arquivo `start-local.bat`
2. Aguarde alguns minutos enquanto o sistema se configura
3. O navegador abrirá automaticamente com o programa pronto para uso

> **Dica**: Se for a primeira vez que você executa o programa, pode demorar alguns minutos para baixar e instalar todas as dependências.

### Opção 2: Executar com Docker (Para Usuários Avançados)

Se você tem o Docker instalado:

1. Execute `start-dev.sh` (Linux/Mac) ou `start-dev.bat` (Windows)
2. Aguarde a inicialização
3. Acesse http://localhost:3000 no navegador

## 📖 Como Usar

1. **Acesse o Aplicativo**: Abra http://localhost:3000 no navegador (abre automaticamente)
2. **Selecione um Arquivo**: Clique em "Escolher arquivo" e selecione seu documento
3. **Escolha uma Voz**: Selecione uma das vozes disponíveis em português
4. **Configure Opções**:
   - Adicione um título para o audiobook (opcional)
   - Ative a IA Gemini para melhorar o texto (opcional)
5. **Gere o Audiobook**: Clique em "Gerar Audiobook"
6. **Acompanhe o Progresso**: Veja o status em tempo real
7. **Baixe o Resultado**: Quando pronto, o download começará automaticamente

## 🛑 Como Parar o Programa

- **No Windows**: Execute o arquivo `stop-local.bat` ou feche as janelas do terminal que apareceram
- **No Linux/Mac**: Pressione Ctrl+C nas janelas do terminal

## 📁 Scripts Disponíveis

### Scripts para Iniciar o Programa

- `start-local.bat`: Script principal que inicia todo o sistema (recomendado)
- `start-backend.bat`: Inicia apenas o backend (serviço que processa os arquivos)
- `start-frontend.bat`: Inicia apenas o frontend (interface do usuário)
- `start-dev.sh`: Script para desenvolvedores usando Docker

### Scripts para Parar o Programa

- `stop-local.bat`: Para todos os serviços do programa
- `stop.sh`: Script para parar serviços em ambiente Docker

## ❓ Problemas Comuns e Soluções

### O programa não abre ou trava na primeira execução

- **Causa**: Na primeira vez, o sistema precisa baixar e instalar várias dependências, o que pode levar alguns minutos.
- **Solução**: Aguarde até 10 minutos na primeira execução. Verifique se há janelas do terminal abertas mostrando o progresso.

### Mensagem "Porta já em uso"

- **Causa**: Outro programa está usando as portas 3000 ou 8000.
- **Solução**: Execute o arquivo `stop-local.bat` para liberar as portas. Se ainda persistir, reinicie o computador.

### Mensagem "Python não encontrado" ou "Node.js não encontrado"

- **Causa**: As dependências necessárias não estão instaladas.
- **Solução**: O script `start-local.bat` tenta instalar automaticamente as dependências. Se falhar, siga as instruções que aparecem na tela.

### O áudio não é gerado

- **Causa**: O FFmpeg não está instalado corretamente.
- **Solução**: O script tenta instalar o FFmpeg automaticamente. Se falhar, siga as instruções na tela para instalar manualmente.

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

Feito com ❤️ para a comunidade de audiobooks

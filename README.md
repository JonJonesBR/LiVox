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

### Problemas com arquivos grandes

- **Causa**: Arquivos muito grandes podem levar muito tempo para processar.
- **Solução**: Experimente com arquivos menores primeiro. O tamanho máximo padrão é 10MB.

## 🏗️ Arquitetura

O aplicativo é dividido em duas partes principais:

### Backend (Python/FastAPI)
- API RESTful para processamento de arquivos
- Conversão de texto em áudio usando Edge TTS
- Suporte a processamento assíncrono
- Documentação automática com Swagger

### Frontend (Next.js/React)
- Interface moderna e responsiva
- Componentes UI com shadcn/ui
- Atualizações em tempo real do progresso
- Upload de arrastar e soltar

## 🚀 Começando (Para Desenvolvedores)

### Pré-requisitos

- Docker e Docker Compose (opcional)
- Node.js 18+ (para desenvolvimento do frontend)
- Python 3.11+ (para desenvolvimento local do backend)
- FFmpeg (será instalado automaticamente se não encontrado)

### 1. Clonar o Repositório

```bash
git clone <seu-repositorio>
cd audiobook-generator
```

### 2. Configurar o Ambiente

Copie o arquivo de exemplo de ambiente:

```bash
cp .env.example .env
```

### 3. Iniciar com Docker (Recomendado)

#### Iniciar o Ambiente

```bash
./start-dev.sh
```

Este script irá:
- Construir a imagem Docker do backend
- Iniciar os containers
- Verificar se o backend está saudável

#### Parar o Ambiente

```bash
./stop.sh
```

### 4. Executar Localmente (Sem Docker)

Se preferir executar o aplicativo localmente sem depender do Docker, você pode usar os scripts fornecidos:

#### Iniciar o Ambiente Local

```bash
./start-local.bat
```

Este script irá:
- Verificar e instalar automaticamente o FFmpeg se necessário
- Criar e ativar um ambiente virtual Python
- Instalar todas as dependências necessárias
- Iniciar o backend (API) na porta 8000
- Iniciar o frontend (Next.js) na porta 3000
- Abrir o navegador automaticamente

> **Nota**: Se o FFmpeg não estiver instalado, o script tentará instalá-lo automaticamente. Se a instalação automática falhar, instruções manuais serão fornecidas.

#### Parar o Ambiente Local

```bash
./stop-local.bat
```

Este script irá:
- Fornecer instruções para fechar os terminais do backend e frontend
- Orientar sobre como verificar processos remanescentes

#### Iniciar Backend e Frontend Separadamente

Você também pode iniciar os serviços separadamente:

**Backend (API):**
```bash
./start-backend.bat
```

**Frontend (Interface):**
```bash
./start-frontend.bat
```

### 5. Empacotamento e Distribuição

Para distribuir o Audiobook Generator como um pacote executável, existem várias opções disponíveis no diretório `packaging/`:

#### Opção 1: Script Auto-extrator Simples

O método mais simples usa um script batch que copia os arquivos e inicia o aplicativo:

1. Execute `packaging\simple-extractor.bat` como administrador
2. O script copiará os arquivos para um diretório temporário e iniciará o aplicativo

#### Opção 2: Instalador Profissional (NSIS)

Para criar um instalador profissional:

1. Instale o NSIS (Nullsoft Scriptable Install System)
2. Execute o comando: `makensis packaging\installer.nsi`
3. O instalador `AudiobookGeneratorInstaller.exe` será criado

Mais detalhes estão disponíveis em `packaging\README-NSIS.md`.

#### Opção 3: Pacote Auto-extrator (IExpress)

Para criar um pacote auto-extrator usando a ferramenta IExpress do Windows:

1. Execute o PowerShell como administrador
2. Navegue até o diretório `packaging`
3. Execute: `.\build-iexpress.ps1 -OutputExe ..\audiobook-local-runner.exe`

Mais detalhes estão disponíveis em `packaging\README.md`.

## 🔧 Configuração Avançada

### API do Google Gemini

Para usar a otimização com IA:

1. Acesse [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Crie uma nova chave API
3. No aplicativo, ative "Usar IA Gemini"
4. Cole sua chave API no campo correspondente
5. Clique em "Salvar Chave API"

### Variáveis de Ambiente

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `NEXT_PUBLIC_API_URL` | URL da API do backend | `http://localhost:8000` |
| `MAX_FILE_SIZE` | Tamanho máximo do arquivo em bytes | `10485760` (10MB) |
| `ALLOWED_FILE_TYPES` | Tipos de arquivo permitidos | `pdf,txt,epub,doc,docx` |

## 🐳 Implantação

### Docker Compose

Para produção:

```bash
docker-compose -f docker-compose.yml up -d
```

### Implantação em Nuvem

O aplicativo pode ser implantado em várias plataformas:

#### Render
1. Faça deploy do backend como um Web Service
2. Faça deploy do frontend como um Static Site
3. Configure as variáveis de ambiente

#### Heroku
1. Use o Dockerfile para o backend
2. Configure o buildpack para múltiplos apps
3. Adicione os addons necessários

#### Vercel
1. Implante o frontend no Vercel
2. Use o backend como uma API externa ou função serverless

## 📁 Estrutura do Projeto

```
audiobook-generator/
├── backend/
│   ├── main.py              # Código principal do backend
│   ├── requirements.txt     # Dependências Python
│   └── Dockerfile          # Configuração Docker
├── frontend/
│   └── page.tsx            # Componente React principal
├── docker-compose.yml      # Orquestração Docker
├── start-dev.sh           # Script de inicialização
├── stop.sh               # Script de parada
├── .env.example          # Exemplo de configuração
├── package.json          # Dependências e scripts do frontend (agora na raiz)
├── next-env.d.ts         # Tipos de ambiente Next.js
├── next.config.js        # Configuração do Next.js
├── postcss.config.js     # Configuração do PostCSS
├── tailwind.config.ts    # Configuração do Tailwind CSS
└── tsconfig.json         # Configuração do TypeScript
```

## 🛠️ Desenvolvimento

### Adicionando Novas Vozes

As vozes são carregadas dinamicamente da API Edge TTS. Para adicionar suporte a outros idiomas:

1. Modifique a função `get_available_voices` em `backend/main.py`
2. Atualize o filtro de locale conforme necessário
3. Teste as novas vozes

### Extendendo o Backend

O backend usa FastAPI, então você pode:

- Adicionar novos endpoints em `main.py`
- Usar o FastAPI dependency injection
- Acessar a documentação em `/docs`
- Testar endpoints com o Swagger UI

### Personalizando o Frontend

O frontend usa:
- Next.js para roteamento e SSR
- shadcn/ui para componentes
- Tailwind CSS para estilos
- Lucide React para ícones

## 🐛 Troubleshooting

### Problemas Comuns

#### Backend não inicia
- Verifique se a porta 8000 está disponível
- Confira se todas as dependências estão instaladas
- Verifique os logs com `docker-compose logs backend`

#### Erro de upload de arquivo
- Verifique o tamanho máximo do arquivo
- Confirme se o tipo de arquivo é suportado
- Verifique as permissões do diretório de uploads

#### Áudio não é gerado
- Verifique se o FFmpeg está instalado (obrigatório para modo local)
- Confirme se há espaço em disco suficiente
- Verifique os logs do backend para erros

#### Erro "Falha ao unificar partes do áudio"
- Este erro ocorre quando o FFmpeg não está instalado ou não está no PATH
- Siga as instruções em `FFMPEG-INSTALL.md` para instalar corretamente

### Logs

Para ver os logs do backend:

```bash
docker-compose logs -f backend
```

Para ver os logs do frontend:

```bash
docker-compose logs -f frontend
```

Para ver os logs do backend em modo local:
- Os logs são exibidos diretamente no terminal onde o backend está sendo executado

### Verificação de Dependências

Antes de executar o programa localmente, verifique se todas as dependências estão instaladas:

1. **Python 3.11+**: `python --version`
2. **Node.js 18+**: `node --version`
3. **FFmpeg**: `ffmpeg -version`

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🙏 Agradecimentos

- [FastAPI](https://fastapi.tiangolo.com/) - Framework web moderno
- [Edge TTS](https://github.com/rany2/edge-tts) - Síntese de voz
- [Next.js](https://nextjs.org/) - Framework React
- [shadcn/ui](https://ui.shadcn.com/) - Componentes UI
- [Tailwind CSS](https://tailwindcss.com/) - Framework CSS

## 📞 Suporte

Se você tiver algum problema ou sugestão:

1. Verifique a seção de troubleshooting
2. Abra uma issue no GitHub
3. Entre em contato com os mantenedores

---

Feito com ❤️ para a comunidade de audiobooks

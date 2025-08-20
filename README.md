# 🔊 Audiobook Generator

Transforme seus documentos e e-books em audiobooks com vozes naturais e de alta qualidade usando tecnologia de ponta.

## 🌟 Recursos Principais

- **Múltiplos Formatos**: Suporte para PDF, TXT, EPUB, DOC e DOCX
- **Vozes Naturais**: Utiliza Microsoft Edge TTS para vozes realistas
- **Otimização com IA**: Opção de usar Google Gemini para melhorar o texto
- **Interface Moderna**: Frontend responsivo com Next.js e shadcn/ui
- **Fácil Implantação**: Suporte a Docker para ambiente consistente
- **Progresso em Tempo Real**: Acompanhe o status da conversão

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

## 🚀 Começando

### Pré-requisitos

- Docker e Docker Compose
- Node.js 18+ (para desenvolvimento do frontend)
- Python 3.11+ (para desenvolvimento local do backend)

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

### 4. Desenvolvimento Local

#### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # No Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

#### Frontend

O frontend agora usa o `package.json` na raiz do projeto. Para desenvolvê-lo:

```bash
npm run dev
```

## 📖 Como Usar

1. **Acesse o Aplicativo**: Abra http://localhost:3000/audiobook no navegador
2. **Selecione um Arquivo**: Clique em "Escolher arquivo" e selecione seu documento
3. **Escolha uma Voz**: Selecione uma das vozes disponíveis em português
4. **Configure Opções**:
   - Adicione um título para o audiobook (opcional)
   - Ative a IA Gemini para melhorar o texto (opcional)
5. **Gere o Audiobook**: Clique em "Gerar Audiobook"
6. **Acompanhe o Progresso**: Veja o status em tempo real
7. **Baixe o Resultado**: Quando pronto, o download começará automaticamente

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
- Verifique se o FFmpeg está instalado
- Confirme se há espaço em disco suficiente
- Verifique os logs do backend para erros

### Logs

Para ver os logs do backend:

```bash
docker-compose logs -f backend
```

Para ver os logs do frontend:

```bash
docker-compose logs -f frontend
```

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

# 🔊 LylyReader

Transforme seus documentos e e-books em audiobooks com vozes naturais e de alta qualidade usando tecnologia de ponta.

## 🎯 Para Iniciantes

> 🎯 **Modo Fácil: Comece em 3 Cliques!**

Com o LylyReader, transformar seus documentos em audiobooks é simples!

**O que você precisa:**

*   Um computador com Windows 10 ou superior.
*   Conexão com a internet.

**Como começar:**

## 🚀 Download do Aplicativo de Desktop

Para a experiência mais fácil e completa, baixe a versão executável do LylyReader para Windows:

*   **Windows:** [LylyReader Setup.exe](https://github.com/JonJonesBR/LylyReader/releases/download/0.1.0/LylyReader.Setup.0.1.0.zip) (115MB)

Após o download, descompacte o arquivo e execute o LylyReader Setup.exe`.

O instalador automático começará a rodar e após finalizar a janela do app será aberta!

### ATENÇÃO! SE O INSTALADOR INFORMAR QUE A JANELA OU O PROGRAMA NÃO CONSEGUE SER FECHADO DURANTE A INSTALAÇÃO, BASTA CLICAR EM REPETIR QUE A INSTALAÇÃO PROSSEGUIRÁ NORMALMENTE [ESTOU TRABALHANDO PARA RESOLVER ESSE BUG]

## 🌟 Recursos Principais

*   **Vozes Naturais:** Ouça seus documentos com vozes que parecem humanas.
*   **Vários Formatos:** Funciona com PDF, TXT, EPUB, DOC e DOCX.
*   **Otimização com IA (Opcional):** Use a inteligência artificial para melhorar o texto.

## 📖 Como Usar (Passo a Passo)

1.  **Abra o atalho do LylyReader criado em sua área de trabalho ou no menu iniciar:**
2.  **Selecione o Arquivo:** Clique em "Escolher arquivo" e selecione o documento que você quer transformar em audiobook.
3.  **Escolha a Voz:** Selecione uma das vozes em português disponíveis.
4.  **Configure (Opcional):**
    *   Adicione um título para o seu audiobook.
    *   Ative a IA Gemini para melhorar o texto. [Você pode pegar a chave api do gemini de graça no link: https://aistudio.google.com/app/apikey]
5.  **Gere o Audiobook:** Clique em "Gerar Audiobook".
6.  **Acompanhe o Progresso:** Veja o status da conversão na tela.
7.  **Baixe o Resultado:** Quando o processo terminar, o download do audiobook começará automaticamente e você pode escolher onde salvar e o nome do arquivo.

## 🛑 Como Parar o Programa

*   **No Windows:** Clique no botão vermelho no canto superior direito do app chamado: Fechar Aplicativo

## ❓ Dúvidas?

Se você tiver algum problema, aqui estão algumas dicas:

*   **O programa não abre:** Na primeira vez, pode demorar um pouco para baixar e instalar tudo. Espere alguns minutos.
*   **Mensagem "Porta já em uso":** Outro programa está usando a mesma porta que o LylyReader precisa. Tente executar `stop-local.bat` ou reiniciar o computador.
*   **Outros problemas:** Se você encontrar outros problemas, siga as instruções na tela ou consulte a seção para programadores para obter mais informações sobre como solucionar problemas.

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

Feito com ❤️ para a comunidade de audiobooks

## 👨‍💻 Para Programadores

### Estrutura do Projeto

-   **frontend/**: Código do frontend (Next.js)
-   **backend/**: Código do backend (Python, FastAPI)
-   **build/**: Saída de build do frontend para o Electron
-   **dist/**: Saída de build do Electron (aplicativo de desktop)
-   **backend/audiobooks/**: Arquivos de áudio gerados
-   **backend/uploads/**: Arquivos de upload
-   **start-*.bat/sh**: Scripts para iniciar e parar o projeto em modo de desenvolvimento
-   **main.js**: Ponto de entrada principal do Electron
-   **preload.js**: Script de pré-carregamento do Electron
-   **stop-app.js**: Script cross-platform para parar a aplicação

### Como Configurar o Ambiente de Desenvolvimento

**Pré-requisitos:**

*   Node.js e npm (ou yarn)
*   Python 3.x
*   FFmpeg (necessário para conversão de áudio)

**Passos:**

1.  **Instale as dependências:**
    *   No diretório raiz, execute `npm install`.
    *   No diretório `frontend/`, execute `npm install`.
    *   No diretório `backend/`, execute `pip install -r requirements.txt`.
2.  **Configure as variáveis de ambiente:**
    *   Crie um arquivo `.env.local` no diretório `frontend/`.
    *   Adicione as variáveis necessárias, como:
        ```
        NEXT_PUBLIC_API_URL=http://localhost:8000
        ```

### Como Executar o Projeto em Modo de Desenvolvimento

1.  **Backend:** No diretório `backend/`, execute `python main.py`.
2.  **Frontend:** No diretório `frontend/`, execute `npm run dev`.
3.  **Electron:** No diretório raiz, execute `npm run electron`.
4.  Acesse o frontend em http://localhost:3000.

### Como Construir o Aplicativo de Desktop

Para gerar o aplicativo de desktop (Windows, Linux, macOS):

1.  **Certifique-se de ter as dependências de desenvolvimento instaladas:** Node.js, npm, Python, pip.
2.  **Instale as dependências do projeto raiz:**
    ```bash
    npm install
    ```
3.  **Construa o backend Python em um executável:**
    ```bash
    cd backend
    pip install pyinstaller
    python -m PyInstaller lylyreader-backend.spec
    cd ..
    ```
4.  **Execute o script de build do Electron:**
    ```bash
    npm run electron:build:win
    ```
    Isso irá:
    *   Construir o frontend Next.js.
    *   Copiar o frontend construído para o diretório `build/`.
    *   Empacotar o aplicativo Electron, incluindo o backend Python compilado.

    Os executáveis serão gerados no diretório `dist/`.

### Scripts Disponíveis

*   `npm run dev`: Inicia o frontend Next.js em modo de desenvolvimento
*   `npm run electron`: Inicia a aplicação Electron em modo de desenvolvimento
*   `npm run electron:build:win`: Constrói o aplicativo para Windows
*   `npm run electron:build:linux`: Constrói o aplicativo para Linux
*   `npm run electron:build:mac`: Constrói o aplicativo para macOS
*   `npm run stop`: Para a aplicação usando o script cross-platform

### Como Contribuir

1.  **Faça um fork do repositório.**
2.  **Crie uma branch para sua feature:** `git checkout -b minha-feature`
3.  **Faça suas alterações e commit:** `git commit -m "Adicionei minha feature"`
4.  **Envie suas alterações para a branch:** `git push origin minha-feature`
5.  **Crie um Pull Request no GitHub.**

### Tecnologias Utilizadas

*   **Frontend:** Next.js, React, shadcn/ui
*   **Backend:** Python, FastAPI, Microsoft Edge TTS, Google Gemini (opcional)
*   **Desktop Application:** Electron
*   **Banco de Dados:** Nenhum (arquivos locais)

## 📝 Licença

Este projeto está sob a licença MIT:

MIT License

Copyright (c) 2025 LylyReader Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

Feito com ❤️ para a comunidade de audiobooks

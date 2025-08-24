@echo off
setlocal enabledelayedexpansion

echo 🧪 Testando instalação automática do FFmpeg...

REM Verificar se o FFmpeg está instalado
echo 🔍 Verificando dependências...
ffmpeg -version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ FFmpeg encontrado
    exit /b 0
) else (
    echo ⚠️  FFmpeg não encontrado!
    echo.
    echo 🔄 Tentando instalar o FFmpeg automaticamente...
    
    REM Criar diretório temporário para download
    set "TEMP_DIR=%TEMP%\\ffmpeg_install_test"
    if not exist "!TEMP_DIR!" mkdir "!TEMP_DIR!"
    
    REM Baixar FFmpeg
    echo 📥 Baixando FFmpeg...
    curl -L -o "!TEMP_DIR!\\ffmpeg.zip" "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    
    if !errorlevel! == 0 (
        echo ✅ FFmpeg baixado com sucesso!
        
        REM Criar diretório de instalação
        set "FFMPEG_DIR=%TEMP%\\ffmpeg_test"
        if not exist "!FFMPEG_DIR!" mkdir "!FFMPEG_DIR!"
        
        REM Extrair FFmpeg
        echo 📂 Extraindo FFmpeg...
        powershell -Command "Expand-Archive -Path '!TEMP_DIR!\\ffmpeg.zip' -DestinationPath '!FFMPEG_DIR!' -Force"
        
        if !errorlevel! == 0 (
            echo ✅ FFmpeg extraído com sucesso!
            
            REM Verificar se o executável existe
            if exist "!FFMPEG_DIR!\\ffmpeg*.exe" (
                echo ✅ FFmpeg encontrado no diretório de extração
            ) else (
                echo ⚠️  Procurando estrutura correta...
                for /d %%D in ("!FFMPEG_DIR!\\ffmpeg-*") do (
                    if exist "%%D\\bin\\ffmpeg.exe" (
                        echo ✅ FFmpeg encontrado em %%D\\bin\\
                    )
                )
            )
            
            REM Limpar arquivos temporários
            rmdir "!TEMP_DIR!" /S /Q
            
            echo.
            echo 🎉 Teste de instalação automática concluído com sucesso!
            echo.
        ) else (
            echo ❌ Falha ao extrair FFmpeg.
            rmdir "!TEMP_DIR!" /S /Q
        )
    ) else (
        echo ❌ Falha ao baixar FFmpeg.
        rmdir "!TEMP_DIR!" /S /Q
    )
)
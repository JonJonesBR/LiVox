"use client";

import { useState, useEffect } from "react";
import { Button } from "../../../components/ui/button";
import { Alert, AlertDescription } from "../../../components/ui/alert";
import { Volume2, Sparkles, Power } from "lucide-react";
import { FileUploadCard } from "../../../components/FileUploadCard";
import { SettingsCard } from "../../../components/SettingsCard";
import { StatusCard } from "../../../components/StatusCard";
import { Card, CardContent, CardHeader, CardTitle } from "../../../components/ui/card";

interface VoiceOption {
  [key: string]: string;
}

interface TaskStatus {
  status: string;
  message: string;
  progress: number;
  file_path?: string;
}

export default function LylyReader() {
  const [voices, setVoices] = useState<VoiceOption>({});
  const [selectedVoice, setSelectedVoice] = useState<string>("");
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [bookTitle, setBookTitle] = useState<string>("");
  const [useGemini, setUseGemini] = useState<boolean>(false);
  const [geminiApiKey, setGeminiApiKey] = useState<string>("");
  const [currentTask, setCurrentTask] = useState<string | null>(null);
  const [taskStatus, setTaskStatus] = useState<TaskStatus | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [apiKeySaved, setApiKeySaved] = useState<boolean>(false);

  const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 
                      (typeof window !== 'undefined' ? 
                        `${window.location.protocol}//${window.location.hostname === '127.0.0.1' ? 'localhost' : window.location.hostname}:8000` : 
                        "http://localhost:8000");

  useEffect(() => {
    fetchVoices();
  }, []);

  const fetchVoices = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/voices`);
      if (response.ok) {
        const voicesData = await response.json();
        setVoices(voicesData);
        const firstVoice = Object.keys(voicesData)[0];
        if (firstVoice) {
          setSelectedVoice(firstVoice);
        }
      }
    } catch (err) {
      setError("Erro ao carregar vozes disponíveis");
    }
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const validTypes = [
        "application/pdf",
        "text/plain",
        "application/epub+zip",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/msword",
      ];

      if (validTypes.includes(file.type)) {
        setSelectedFile(file);
        setError(null);
      } else {
        setError("Tipo de arquivo não suportado. Por favor, selecione PDF, TXT, EPUB ou DOCX.");
      }
    }
  };

  const handleSaveApiKey = async () => {
    if (!geminiApiKey.trim()) {
      setError("Por favor, insira uma chave API válida");
      return;
    }

    try {
      const formData = new FormData();
      formData.append("api_key", geminiApiKey);

      const response = await fetch(`${API_BASE_URL}/set_gemini_api_key`, {
        method: "POST",
        body: formData,
      });

      if (response.ok) {
        setApiKeySaved(true);
        setError(null);
        setTimeout(() => setApiKeySaved(false), 3000);
      } else {
        setError("Erro ao salvar chave API");
      }
    } catch (err) {
      setError("Erro ao conectar com o servidor");
    }
  };

  const handleGenerateAudiobook = async () => {
    if (!selectedFile) {
      setError("Por favor, selecione um arquivo");
      return;
    }

    if (!selectedVoice) {
      setError("Por favor, selecione uma voz");
      return;
    }

    setIsLoading(true);
    setError(null);
    setTaskStatus(null);

    try {
      const formData = new FormData();
      formData.append("file", selectedFile);
      formData.append("voice", selectedVoice);
      formData.append("use_gemini", useGemini.toString());
      if (bookTitle.trim()) {
        formData.append("book_title", bookTitle);
      }

      const response = await fetch(`${API_BASE_URL}/process_file`, {
        method: "POST",
        body: formData,
      });

      if (response.ok) {
        const { task_id } = await response.json();
        setCurrentTask(task_id);
        pollTaskStatus(task_id);
      } else {
        const errorData = await response.json();
        setError(errorData.detail || "Erro ao processar arquivo");
        setIsLoading(false);
      }
    } catch (err) {
      setError("Erro ao conectar com o servidor");
      setIsLoading(false);
    }
  };

  const pollTaskStatus = (taskId: string) => {
    const interval = setInterval(async () => {
      try {
        const response = await fetch(`${API_BASE_URL}/status/${taskId}`);
        if (response.ok) {
          const status = await response.json();
          setTaskStatus(status);

          if (status.status === "completed") {
            clearInterval(interval);
            setIsLoading(false);
            setTimeout(() => downloadAudiobook(taskId), 1000);
          } else if (status.status === "failed") {
            clearInterval(interval);
            setIsLoading(false);
            setError(status.message || "Erro na conversão");
          }
        }
      } catch (err) {
        clearInterval(interval);
        setIsLoading(false);
        setError("Erro ao verificar status da tarefa");
      }
    }, 2000);
  };

  const downloadAudiobook = async (taskId: string) => {
    try {
      const response = await fetch(`${API_BASE_URL}/download/${taskId}`);
      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = taskStatus?.file_path?.split("/").pop() || "audiobook.mp3";
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      }
    } catch (err) {
      setError("Erro ao baixar audiobook");
    }
  };

  const handleCloseApplication = async () => {
    // Confirm before closing
    const confirmClose = window.confirm("Tem certeza que deseja fechar o aplicativo?");
    if (!confirmClose) return;

    try {
      // Show message immediately
      alert("Fechando aplicativo... A página será fechada automaticamente em alguns segundos.");
      
      // Call the backend shutdown endpoint
      const response = await fetch(`${API_BASE_URL}/shutdown`, {
        method: "POST",
      });
      
      if (!response.ok) {
        console.warn("Shutdown endpoint returned error:", response.status);
      }
      
      // Close the frontend after 4 seconds (enough time for backend to stop)
      setTimeout(() => {
        // Try to close the browser tab
        window.close();
        
        // If we can't close the tab, show message after a delay
        setTimeout(() => {
          alert("Aplicativo foi fechado. Você pode fechar esta aba manualmente se ela não fechou automaticamente.");
        }, 1000);
      }, 4000);
      
    } catch (err) {
      console.error("Error calling shutdown endpoint:", err);
      // Still close the frontend even if the request fails
      setTimeout(() => {
        window.close();
        setTimeout(() => {
          alert("Aplicativo foi fechado. Você pode fechar esta aba manualmente.");
        }, 1000);
      }, 3000);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <div className="max-w-4xl mx-auto">
        {/* Botão Fechar Aplicativo no topo */}
        <div className="flex justify-end mb-4">
          <Button
            onClick={handleCloseApplication}
            variant="destructive"
            size="lg"
            className="bg-red-600 hover:bg-red-700 text-white font-semibold px-6 py-3 shadow-lg"
          >
            <Power className="mr-2 h-5 w-5" />
            Fechar Aplicativo
          </Button>
        </div>

        <div className="flex flex-col items-center space-y-4">
                <Volume2 className="h-12 w-12 text-blue-500" />
                <h1 className="text-3xl font-bold text-center">
                  🔊 LylyReader
                </h1>
                <p className="text-lg text-gray-600 text-center">
                  Transforme seus documentos em audiobooks com vozes naturais
                </p>
              </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <FileUploadCard
            selectedFile={selectedFile}
            handleFileChange={handleFileChange}
            voices={voices}
            selectedVoice={selectedVoice}
            setSelectedVoice={setSelectedVoice}
            bookTitle={bookTitle}
            setBookTitle={setBookTitle}
          />

          <SettingsCard
            useGemini={useGemini}
            setUseGemini={setUseGemini}
            geminiApiKey={geminiApiKey}
            setGeminiApiKey={setGeminiApiKey}
            handleSaveApiKey={handleSaveApiKey}
            apiKeySaved={apiKeySaved}
          />
        </div>

        <div className="mt-6 text-center">
          <Button
            onClick={handleGenerateAudiobook}
            disabled={isLoading || !selectedFile || !selectedVoice}
            size="lg"
            className="px-8 py-3"
          >
            {isLoading ? (
              <>
                <Volume2 className="mr-2 h-4 w-4 animate-spin" />
                Processando...
              </>
            ) : (
              <>
                <Sparkles className="mr-2 h-4 w-4" />
                Gerar LylyReader
              </>
            )}
          </Button>
        </div>

        <StatusCard
          taskStatus={taskStatus}
          currentTask={currentTask}
          downloadAudiobook={downloadAudiobook}
        />

        {error && (
          <Alert className="mt-6 border-red-200 bg-red-50">
            <AlertDescription className="text-red-800">
              {error}
            </AlertDescription>
          </Alert>
        )}

        <Card className="mt-8">
          <CardHeader>
            <CardTitle>Como Usar</CardTitle>
          </CardHeader>
          <CardContent>
            <ol className="list-decimal list-inside space-y-2 text-sm text-gray-600">
              <li>Selecione um arquivo (PDF, TXT, EPUB, DOC ou DOCX)</li>
              <li>Escolha uma voz na lista de opções</li>
              <li>Opcional: Adicione um título para o LylyReader</li>
              <li>Opcional: Use IA Gemini para melhorar a qualidade do texto</li>
              <li>Clique em "Gerar LylyReader" e aguarde o processamento</li>
              <li>Baixe seu LylyReader quando estiver pronto</li>
            </ol>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Upload } from "lucide-react";
import React from "react";

interface FileUploadCardProps {
  selectedFile: File | null;
  handleFileChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  voices: { [key: string]: string };
  selectedVoice: string;
  setSelectedVoice: (voice: string) => void;
  bookTitle: string;
  setBookTitle: (title: string) => void;
}

export function FileUploadCard({
  selectedFile,
  handleFileChange,
  voices,
  selectedVoice,
  setSelectedVoice,
  bookTitle,
  setBookTitle,
}: FileUploadCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Upload className="h-5 w-5" />
          Upload de Arquivo
        </CardTitle>
        <CardDescription>
          Selecione um arquivo para converter em LylyReader
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div>
          <Label htmlFor="file">Arquivo</Label>
          <Input
            id="file"
            type="file"
            accept=".pdf,.txt,.epub,.doc,.docx"
            onChange={handleFileChange}
            className="mt-1"
          />
          <p className="text-sm text-gray-500 mt-1">
            Formatos suportados: PDF, TXT, EPUB, DOC, DOCX
          </p>
        </div>

        {selectedFile && (
          <div className="p-3 bg-blue-50 rounded-lg">
            <p className="text-sm font-medium text-blue-900">
              Arquivo selecionado: {selectedFile.name}
            </p>
            <p className="text-xs text-blue-600">
              {(selectedFile.size / 1024 / 1024).toFixed(2)} MB
            </p>
          </div>
        )}

        <div>
          <Label htmlFor="voice">Voz</Label>
          <Select value={selectedVoice} onValueChange={setSelectedVoice}>
            <SelectTrigger className="mt-1">
              <SelectValue placeholder="Selecione uma voz" />
            </SelectTrigger>
            <SelectContent>
              {Object.entries(voices).map(([key, value]) => (
                <SelectItem key={key} value={key}>
                  {value}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div>
          <Label htmlFor="title">Título do Livro (Opcional)</Label>
          <Input
            id="title"
            type="text"
            value={bookTitle}
            onChange={(e) => setBookTitle(e.target.value)}
            placeholder="Digite o título do livro"
            className="mt-1"
          />
        </div>
      </CardContent>
    </Card>
  );
}

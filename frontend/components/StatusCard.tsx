import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Progress } from "./ui/progress";
import { Download } from "lucide-react";
import React from "react";

interface TaskStatus {
  status: string;
  message: string;
  progress: number;
  file_path?: string;
}

interface StatusCardProps {
  taskStatus: TaskStatus | null;
  currentTask: string | null;
  downloadAudiobook: (taskId: string) => void;
}

export function StatusCard({ taskStatus, currentTask, downloadAudiobook }: StatusCardProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case "completed":
        return "text-green-600";
      case "failed":
        return "text-red-600";
      case "processing":
      case "converting":
        return "text-blue-600";
      default:
        return "text-gray-600";
    }
  };

  if (!taskStatus) {
    return null;
  }

  return (
    <Card className="mt-6">
      <CardHeader>
        <CardTitle>Status da Conversão</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center justify-between">
          <span className={`font-medium ${getStatusColor(taskStatus.status)}`}>
            {taskStatus.status === "in_queue" && "Na fila"}
            {taskStatus.status === "extracting" && "Extraindo texto"}
            {taskStatus.status === "formatting" && "Formatando texto"}
            {taskStatus.status === "ai_enhancing" && "Melhorando com IA"}
            {taskStatus.status === "converting" && "Convertendo para áudio"}
            {taskStatus.status === "merging_audio" && "Unificando áudio"}
            {taskStatus.status === "completed" && "Concluído"}
            {taskStatus.status === "failed" && "Falhou"}
          </span>
          <span className="text-sm text-gray-500">{taskStatus.progress}%</span>
        </div>
        
        <Progress value={taskStatus.progress} className="w-full" />
        
        <p className="text-sm text-gray-600">{taskStatus.message}</p>
        
        {taskStatus.status === "completed" && (
          <Button
            onClick={() => currentTask && downloadAudiobook(currentTask)}
            className="w-full"
          >
            <Download className="mr-2 h-4 w-4" />
            Baixar LylyReader
          </Button>
        )}
      </CardContent>
    </Card>
  );
}

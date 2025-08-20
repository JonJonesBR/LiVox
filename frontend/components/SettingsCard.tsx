import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Switch } from "./ui/switch";
import { Button } from "./ui/button";
import { Settings } from "lucide-react";
import React from "react";

interface SettingsCardProps {
  useGemini: boolean;
  setUseGemini: (checked: boolean) => void;
  geminiApiKey: string;
  setGeminiApiKey: (key: string) => void;
  handleSaveApiKey: () => void;
  apiKeySaved: boolean;
}

export function SettingsCard({
  useGemini,
  setUseGemini,
  geminiApiKey,
  setGeminiApiKey,
  handleSaveApiKey,
  apiKeySaved,
}: SettingsCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Settings className="h-5 w-5" />
          Configurações
        </CardTitle>
        <CardDescription>
          Configure opções avançadas de processamento
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center justify-between">
          <div className="space-y-0.5">
            <Label>Usar IA Gemini</Label>
            <p className="text-sm text-gray-500">
              Melhore o texto com inteligência artificial
            </p>
          </div>
          <Switch
            checked={useGemini}
            onCheckedChange={setUseGemini}
          />
        </div>

        {useGemini && (
          <div className="space-y-2">
            <Label htmlFor="apiKey">Chave API do Google Gemini</Label>
            <div className="flex gap-2">
              <Input
                id="apiKey"
                type="password"
                value={geminiApiKey}
                onChange={(e) => setGeminiApiKey(e.target.value)}
                placeholder="Cole sua chave API aqui"
                className="flex-1"
              />
              <Button
                onClick={handleSaveApiKey}
                size="sm"
                variant={apiKeySaved ? "default" : "outline"}
              >
                {apiKeySaved ? "✓ Salvo" : "Salvar"}
              </Button>
            </div>
            <p className="text-xs text-gray-500">
              Obtenha sua chave gratuita em: aistudio.google.com/app/apikey
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

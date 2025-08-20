#!/usr/bin/env python3
"""
Script de teste para o Audiobook Generator Backend
"""

import requests
import json
import time
import os

BASE_URL = "http://localhost:8000"

def test_health():
    """Testa o endpoint de saúde"""
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            print("✅ Health check passed")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_voices():
    """Testa o endpoint de vozes"""
    try:
        response = requests.get(f"{BASE_URL}/voices")
        if response.status_code == 200:
            voices = response.json()
            print(f"✅ Voices loaded: {len(voices)} voices available")
            return voices
        else:
            print(f"❌ Voices endpoint failed: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Voices endpoint error: {e}")
        return None

def test_gemini_api_key():
    """Testa o salvamento da chave API do Gemini"""
    try:
        # Testa com uma chave de exemplo (não vai funcionar de verdade)
        response = requests.post(f"{BASE_URL}/set_gemini_api_key", 
                               data={"api_key": "test_key"})
        if response.status_code == 200:
            print("✅ Gemini API key endpoint working")
            return True
        else:
            print(f"❌ Gemini API key endpoint failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Gemini API key endpoint error: {e}")
        return False

def main():
    """Função principal de teste"""
    print("🧪 Testing Audiobook Generator Backend")
    print("=" * 50)
    
    # Testa saúde do backend
    if not test_health():
        print("❌ Backend is not healthy. Make sure it's running on port 8000")
        return
    
    # Testa carregamento de vozes
    voices = test_voices()
    if voices:
        print("📝 Available voices:")
        for key, value in list(voices.items())[:3]:  # Mostra apenas as 3 primeiras
            print(f"   - {value}")
        if len(voices) > 3:
            print(f"   ... and {len(voices) - 3} more")
    
    # Testa endpoint da Gemini API
    test_gemini_api_key()
    
    print("\n🎉 All tests completed!")
    print("\n📚 API Documentation available at: http://localhost:8000/docs")

if __name__ == "__main__":
    main()
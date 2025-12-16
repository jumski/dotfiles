#!/usr/bin/env python3
import os
import sys
import io
import requests
import argparse

# Language configuration - can be overridden via AUDIO_LANGUAGE env var
DEFAULT_LANGUAGE = os.getenv("AUDIO_LANGUAGE", "en")

def transcribe_with_groq(file_data, language=None):
    """Transcribe audio using Groq's Whisper API"""
    api_key = os.getenv("GROQ_API_KEY")
    if not api_key:
        raise ValueError("GROQ_API_KEY not set")

    lang = language or DEFAULT_LANGUAGE
    file_obj = io.BytesIO(file_data)

    r = requests.post(
        "https://api.groq.com/openai/v1/audio/transcriptions",
        headers={"Authorization": f"Bearer {api_key}"},
        data={"model": "whisper-large-v3", "language": lang},
        files={"file": ("audio.wav", file_obj, "audio/wav")},
        timeout=120
    )
    r.raise_for_status()
    return r.json()["text"]

def transcribe_with_openai(file_data, language=None):
    """Transcribe audio using OpenAI's Whisper API"""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OPENAI_API_KEY not set")

    lang = language or DEFAULT_LANGUAGE
    file_obj = io.BytesIO(file_data)

    r = requests.post(
        "https://api.openai.com/v1/audio/transcriptions",
        headers={"Authorization": f"Bearer {api_key}"},
        data={"model": "whisper-1", "language": lang},
        files={"file": ("audio.wav", file_obj, "audio/wav")},
        timeout=120
    )
    r.raise_for_status()
    return r.json()["text"]

def get_transcription_backend():
    """Determine which backend to use based on environment variable or default"""
    backend = os.getenv("TRANSCRIPTION_BACKEND", "groq").lower()
    
    if backend == "openai":
        return transcribe_with_openai, "OpenAI"
    else:
        return transcribe_with_groq, "Groq"

def main():
    parser = argparse.ArgumentParser(description="Transcribe a WAV file to text")
    parser.add_argument("wav_file", help="Path to the WAV file to transcribe")
    args = parser.parse_args()
    
    wav_path = args.wav_file
    
    # Check if file exists
    if not os.path.exists(wav_path):
        print(f"Error: File '{wav_path}' not found", file=sys.stderr)
        sys.exit(1)
    
    # Check if it's a WAV file
    if not wav_path.endswith('.wav'):
        print(f"Error: File must be a .wav file", file=sys.stderr)
        sys.exit(1)
    
    # Get transcription backend
    transcribe_func, backend_name = get_transcription_backend()
    
    try:
        # Read the WAV file
        with open(wav_path, "rb") as f:
            file_data = f.read()
        
        print(f"Transcribing with {backend_name}...", file=sys.stderr)
        
        # Transcribe
        transcript = transcribe_func(file_data)
        
        # Create output filename
        txt_path = wav_path.replace('.wav', '.txt')
        
        # Save transcript to file
        with open(txt_path, 'w') as f:
            f.write(transcript)
        
        print(f"Transcription saved to: {txt_path}")
        print(f"\nTranscript:\n{transcript}")
        
    except ValueError as e:
        print(f"Configuration error: {e}", file=sys.stderr)
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        print(f"HTTP Error: {e}", file=sys.stderr)
        if hasattr(e, 'response'):
            print(f"Response: {e.response.text}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
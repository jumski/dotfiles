#!/usr/bin/env python3
import os, sys, requests, pathlib

API_KEY = os.getenv("GROQ_API_KEY")
if not API_KEY:
    sys.exit("GROQ_API_KEY not set")

wav = pathlib.Path(sys.argv[1] if len(sys.argv)>1 else "out.wav")
if not wav.is_file():
    sys.exit(f"{wav} missing")

r = requests.post(
    "https://api.groq.com/openai/v1/audio/transcriptions",
    headers={"Authorization": f"Bearer {API_KEY}"},
    data={"model": "whisper-large-v3-turbo"},
    files={"file": wav.open("rb")},
    timeout=60
)
r.raise_for_status()
print(r.json()["text"])
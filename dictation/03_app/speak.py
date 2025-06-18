#!/usr/bin/env python3
import os, signal, subprocess, requests, sys

API_KEY = os.getenv("GROQ_API_KEY")
if not API_KEY:
    sys.exit("GROQ_API_KEY env var missing")

F = "out.wav"
cmd = ["/usr/bin/rec","-q","-r","48000","-c","1",F]

print("Recording... press Ctrl-C to stop")
p = subprocess.Popen(cmd)

def stop(sig, frame):
    print("\nStopping")
    p.terminate()
    p.wait()
    upload()

def upload():
    print("Uploading")
    with open(F,"rb") as f:
        r = requests.post(
            "https://api.groq.com/openai/v1/audio/transcriptions",
            headers={"Authorization":f"Bearer {API_KEY}"},
            data={"model":"whisper-large-v3-turbo"},
            files={"file":f}, timeout=120
        )
    r.raise_for_status()
    print("\nTRANSCRIPT:\n")
    print(r.json()["text"])
    sys.exit(0)

signal.signal(signal.SIGINT, stop)
signal.pause()
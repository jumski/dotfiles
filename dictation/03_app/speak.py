#!/usr/bin/env python3
import os, signal, subprocess, requests, sys

API_KEY = os.getenv("GROQ_API_KEY")
if not API_KEY:
    sys.exit("GROQ_API_KEY env var missing")

F = "out.wav"
cmd = ["/usr/bin/rec","-q","-r","48000","-c","1",F]

print("Recording... press Ctrl-C to stop")
p = subprocess.Popen(cmd)

ctrl_c_count = 0

def stop(sig, frame):
    global ctrl_c_count
    ctrl_c_count += 1
    
    if ctrl_c_count == 1:
        print("\nStopping recording...")
        p.terminate()
        p.wait()
        upload()
    else:
        print("\nAborting!")
        os._exit(1)

def upload():
    print("Uploading (Ctrl-C to abort)...")
    try:
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
    except KeyboardInterrupt:
        print("\nUpload aborted!")
        sys.exit(1)
    sys.exit(0)

signal.signal(signal.SIGINT, stop)

try:
    signal.pause()
except KeyboardInterrupt:
    pass
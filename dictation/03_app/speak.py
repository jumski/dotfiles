#!/usr/bin/env python3
import os, signal, subprocess, requests, sys

# ANSI color codes for muted/gray text
GRAY = '\033[90m'
RESET = '\033[0m'

def err_print(msg):
    sys.stderr.write(f"{GRAY}{msg}{RESET}")
    sys.stderr.flush()

API_KEY = os.getenv("GROQ_API_KEY")
if not API_KEY:
    err_print("GROQ_API_KEY env var missing\n")
    sys.exit(1)

F = "out.wav"
cmd = ["/usr/bin/rec","-q","-r","48000","-c","1",F]

err_print("Recording... press Ctrl-C to stop\n")
p = subprocess.Popen(cmd)

ctrl_c_count = 0

def stop(sig, frame):
    global ctrl_c_count
    ctrl_c_count += 1
    
    if ctrl_c_count == 1:
        err_print("\nStopping recording...\n")
        p.terminate()
        p.wait()
        upload()
    else:
        err_print("\nAborting!\n")
        os._exit(1)

def upload():
    err_print("Uploading (Ctrl-C to abort)...\n")
    try:
        with open(F,"rb") as f:
            r = requests.post(
                "https://api.groq.com/openai/v1/audio/transcriptions",
                headers={"Authorization":f"Bearer {API_KEY}"},
                data={"model":"whisper-large-v3-turbo"},
                files={"file":f}, timeout=120
            )
        r.raise_for_status()
        # Only output the transcription to stdout
        print(r.json()["text"])
    except KeyboardInterrupt:
        err_print("\nUpload aborted!\n")
        sys.exit(1)
    sys.exit(0)

signal.signal(signal.SIGINT, stop)

try:
    signal.pause()
except KeyboardInterrupt:
    pass
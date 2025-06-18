#!/usr/bin/env python3
import os, subprocess, requests, sys, time

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

# Start recording in a subprocess
p = subprocess.Popen(cmd)

try:
    # Wait for the process (will be interrupted by Ctrl-C)
    p.wait()
except KeyboardInterrupt:
    # User pressed Ctrl-C
    err_print("\nStopping recording...\n")
    p.terminate()
    time.sleep(0.5)  # Give it time to terminate
    if p.poll() is None:
        p.kill()  # Force kill if needed
    
    # Now upload
    err_print("Uploading (Ctrl-C to abort)...\n")
    try:
        with open(F,"rb") as f:
            r = requests.post(
                "https://api.groq.com/openai/v1/audio/transcriptions",
                headers={"Authorization":f"Bearer {API_KEY}"},
                data={"model":"whisper-large-v3"},
                files={"file":f}, timeout=120
            )
        r.raise_for_status()
        # Only output the transcription to stdout
        print(r.json()["text"])
    except KeyboardInterrupt:
        err_print("\nUpload aborted!\n")
        sys.exit(1)
    except Exception as e:
        err_print(f"\nUpload error: {e}\n")
        sys.exit(1)
#!/usr/bin/env python3
import os, subprocess, requests, sys, time

# ANSI color codes
GRAY = '\033[90m'
RED = '\033[31m'
GREEN = '\033[32m'
RESET = '\033[0m'

def err_print(msg, color=GRAY):
    sys.stderr.write(f"{color}{msg}{RESET}")
    sys.stderr.flush()

API_KEY = os.getenv("GROQ_API_KEY")
if not API_KEY:
    err_print("GROQ_API_KEY env var missing\n")
    sys.exit(1)

F = "out.wav"
cmd = ["/usr/bin/rec","-q","-r","48000","-c","1",F]

err_print("Recording... press Ctrl-C to stop\n", RED)

# Start recording in a subprocess
p = subprocess.Popen(cmd)

try:
    # Wait for the process (will be interrupted by Ctrl-C)
    p.wait()
except KeyboardInterrupt:
    # User pressed Ctrl-C
    err_print("\nStopping recording...\n", RED)
    p.terminate()
    time.sleep(0.5)  # Give it time to terminate
    if p.poll() is None:
        p.kill()  # Force kill if needed
    
    # Check if file exists and has content
    if not os.path.exists(F):
        err_print(f"\nError: Recording file {F} not found!\n")
        sys.exit(1)
    
    file_size = os.path.getsize(F)
    err_print(f"Recording file size: {file_size} bytes\n")
    
    if file_size == 0:
        err_print("\nError: Recording file is empty!\n")
        sys.exit(1)
    
    # Now upload
    err_print("Uploading (Ctrl-C to abort)...\n", GREEN)
    try:
        with open(F,"rb") as f:
            # Read file content for upload
            file_data = f.read()
            
        # Create a new file-like object for the request
        import io
        file_obj = io.BytesIO(file_data)
        
        r = requests.post(
            "https://api.groq.com/openai/v1/audio/transcriptions",
            headers={"Authorization":f"Bearer {API_KEY}"},
            data={"model":"whisper-large-v3"},
            files={"file": ("out.wav", file_obj, "audio/wav")},
            timeout=120
        )
        r.raise_for_status()
        # Only output the transcription to stdout
        print(r.json()["text"])
    except KeyboardInterrupt:
        err_print("\nUpload aborted!\n")
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        err_print(f"\nHTTP Error: {e}\n")
        err_print(f"Response: {e.response.text}\n")
        sys.exit(1)
    except Exception as e:
        err_print(f"\nUpload error: {e}\n")
        sys.exit(1)
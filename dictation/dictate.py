#!/usr/bin/env python3
import os, subprocess, requests, sys, time, signal, io, threading

# ANSI color codes
GRAY = '\033[90m'
RED = '\033[31m'
GREEN = '\033[32m'
RESET = '\033[0m'

def err_print(msg, color=GRAY):
    sys.stderr.write(f"{color}{msg}{RESET}")
    sys.stderr.flush()

def transcribe_with_groq(file_data):
    """Transcribe audio using Groq's Whisper API"""
    api_key = os.getenv("GROQ_API_KEY")
    if not api_key:
        raise ValueError("GROQ_API_KEY not set")
    
    file_obj = io.BytesIO(file_data)
    
    r = requests.post(
        "https://api.groq.com/openai/v1/audio/transcriptions",
        headers={"Authorization": f"Bearer {api_key}"},
        data={"model": "whisper-large-v3"},
        files={"file": ("out.wav", file_obj, "audio/wav")},
        timeout=120
    )
    r.raise_for_status()
    return r.json()["text"]

def transcribe_with_openai(file_data):
    """Transcribe audio using OpenAI's Whisper API"""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OPENAI_API_KEY not set")
    
    file_obj = io.BytesIO(file_data)
    
    r = requests.post(
        "https://api.openai.com/v1/audio/transcriptions",
        headers={"Authorization": f"Bearer {api_key}"},
        data={"model": "whisper-1"},
        files={"file": ("out.wav", file_obj, "audio/wav")},
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

# Main script starts here
transcribe_func, backend_name = get_transcription_backend()
err_print(f"Using {backend_name} for transcription\n")

F = "out.wav"

# Use arecord as recommended by Perplexity - it properly drains buffers on SIGINT
# From Perplexity: arecord -q -f S16_LE -r 48000 -c 1 --buffer-time 200000 out.wav
cmd = [
    "/usr/bin/arecord",
    "-q",                    # Quiet mode
    "-f", "S16_LE",         # 16-bit signed little-endian
    "-r", "48000",          # 48kHz sample rate
    "-c", "1",              # Mono
    "--buffer-time", "200000",  # 200ms buffer (small enough to drain quickly)
    F                       # Output file
]

err_print("Recording... press any key to stop\n", RED)

# Start recording in a subprocess
p = subprocess.Popen(cmd)

# Simple function to wait for any input
def wait_for_input():
    import termios, tty
    old_settings = termios.tcgetattr(sys.stdin)
    try:
        tty.setcbreak(sys.stdin.fileno())  # Set terminal to cbreak mode
        sys.stdin.read(1)  # Read one character
    finally:
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
    os.kill(os.getpid(), signal.SIGINT)  # Send SIGINT to ourselves

# Start thread to watch for keypress
input_thread = threading.Thread(target=wait_for_input)
input_thread.daemon = True
input_thread.start()

try:
    # Wait for the process (will be interrupted by SIGINT from any key or Ctrl-C)
    p.wait()
except KeyboardInterrupt:
    # Any key or Ctrl-C pressed
    err_print("\nStopping recording...\n", RED)
    p.send_signal(signal.SIGINT)  # Send SIGINT to arecord
    p.wait()  # Wait for it to finish and drain buffers
    
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
    err_print(f"Uploading to {backend_name} (only Ctrl-C can abort)...\n", GREEN)
    try:
        with open(F, "rb") as f:
            file_data = f.read()
        
        # Use the selected transcription backend
        transcript = transcribe_func(file_data)
        print(transcript)
        
    except KeyboardInterrupt:
        err_print("\nUpload aborted!\n")
        sys.exit(1)
    except ValueError as e:
        err_print(f"\nConfiguration error: {e}\n")
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        err_print(f"\nHTTP Error: {e}\n")
        err_print(f"Response: {e.response.text}\n")
        sys.exit(1)
    except Exception as e:
        err_print(f"\nUpload error: {e}\n")
        sys.exit(1)
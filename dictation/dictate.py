#!/usr/bin/env python3
import os, subprocess, requests, sys, time, signal, io, threading

# ANSI color codes
GRAY = '\033[90m'
RED = '\033[31m'
GREEN = '\033[32m'
RESET = '\033[0m'
CLEAR_LINE = '\033[2K\r'

def err_print(msg, color=GRAY):
    sys.stderr.write(f"{color}{msg}{RESET}")
    sys.stderr.flush()

def show_recording_indicator(color=RED):
    """Display recording indicator"""
    # Add top padding and centered circle
    indicator = f"""

  {color}●{RESET}

"""
    sys.stderr.write(indicator)
    sys.stderr.flush()

def animate_recording():
    """Show animated recording indicator"""
    # First show the REC line with padding
    sys.stderr.write(f"\n  {RED}REC...{RESET}\n")
    
    # Then show the legend with padding
    legend = f"""{GRAY}
  Enter: paste & run
  C: clipboard
  S: search Firefox
  Other: paste only{RESET}

"""
    sys.stderr.write(legend)
    sys.stderr.flush()
    
    # Move cursor back up to the REC line
    sys.stderr.write("\033[6A")  # Move up 6 lines
    
    while not stop_animation.is_set():
        for dots in ["   ", ".  ", ".. ", "..."]:
            if stop_animation.is_set():
                break
            sys.stderr.write(f"\r  {RED}REC{dots}{RESET}")
            sys.stderr.flush()
            time.sleep(0.5)

def animate_uploading():
    """Show animated uploading indicator"""
    # First, redraw the circle in green
    sys.stderr.write("\033[9A")  # Move cursor up to circle position
    sys.stderr.write(f"\r  {GREEN}●{RESET}")
    
    # Move to the REC line position
    sys.stderr.write("\033[2D\033[2B")  # Move to REC position
    
    for i in range(20):  # Max 10 seconds of animation
        for dots in ["   ", ".  ", ".. ", "..."]:
            sys.stderr.write(f"\r  {GREEN}UP{dots}{RESET}")
            sys.stderr.flush()
            time.sleep(0.5)
            if upload_done.is_set():
                sys.stderr.write("\r              \n")  # Clear the line and newline
                return

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

F = "out.wav"

# Use arecord as recommended by Perplexity - it properly drains buffers on SIGINT
cmd = [
    "/usr/bin/arecord",
    "-q",                    # Quiet mode
    "-f", "S16_LE",         # 16-bit signed little-endian
    "-r", "48000",          # 48kHz sample rate
    "-c", "1",              # Mono
    "--buffer-time", "200000",  # 200ms buffer (small enough to drain quickly)
    F                       # Output file
]

# Show recording indicator first
show_recording_indicator()

# Start recording in a subprocess
p = subprocess.Popen(cmd)

# Initialize key tracking
key_pressed = None

# Start animation thread
stop_animation = threading.Event()
upload_done = threading.Event()
animation_thread = threading.Thread(target=animate_recording)
animation_thread.daemon = True
animation_thread.start()

# Simple function to wait for any input
def wait_for_input():
    import termios, tty
    global key_pressed
    old_settings = termios.tcgetattr(sys.stdin)
    try:
        tty.setcbreak(sys.stdin.fileno())  # Set terminal to cbreak mode
        key_pressed = sys.stdin.read(1)  # Read one character
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
    stop_animation.set()
    p.send_signal(signal.SIGINT)  # Send SIGINT to arecord
    p.wait()  # Wait for it to finish and drain buffers
    
    # Check if file exists and has content
    if not os.path.exists(F):
        err_print(f"\nError: Recording file {F} not found!\n")
        sys.exit(1)
    
    file_size = os.path.getsize(F)
    
    if file_size == 0:
        err_print("\nError: Recording file is empty!\n")
        sys.exit(1)
    
    # Now upload with animation
    upload_thread = threading.Thread(target=animate_uploading)
    upload_thread.daemon = True
    upload_thread.start()
    
    try:
        with open(F, "rb") as f:
            file_data = f.read()
        
        # Use the selected transcription backend
        transcript = transcribe_func(file_data)
        upload_done.set()  # Stop animation
        time.sleep(0.1)  # Let animation clear
        print(transcript)
        
        # Exit with code based on key pressed
        if key_pressed in ['\n', '\r']:  # Enter key
            sys.exit(0)
        elif key_pressed in ['c', 'C']:  # C key for clipboard
            sys.exit(1)
        elif key_pressed in ['s', 'S']:  # S key for search
            sys.exit(2)
        else:
            sys.exit(99)  # Default action (just paste)
        
    except KeyboardInterrupt:
        upload_done.set()
        err_print("\nUpload aborted!\n")
        sys.exit(1)
    except ValueError as e:
        upload_done.set()
        err_print(f"\nConfiguration error: {e}\n")
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        upload_done.set()
        err_print(f"\nHTTP Error: {e}\n")
        err_print(f"Response: {e.response.text}\n")
        sys.exit(1)
    except Exception as e:
        upload_done.set()
        err_print(f"\nUpload error: {e}\n")
        sys.exit(1)
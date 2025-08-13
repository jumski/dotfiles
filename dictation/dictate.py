#!/usr/bin/env python3
import os, subprocess, requests, sys, time, signal, io, threading, datetime, argparse

# ANSI color codes
GRAY = '\033[90m'
RED = '\033[31m'
GREEN = '\033[32m'
BLUE = '\033[34m'
RESET = '\033[0m'
BOLD = '\033[1m'
CLEAR_LINE = '\033[2K\r'

def err_print(msg, color=GRAY):
    sys.stderr.write(f"{color}{msg}{RESET}")
    sys.stderr.flush()

def show_recording_indicator(color=RED):
    """Display recording indicator"""
    # Popup width is 31, mic + waves is ~10 chars wide
    # Move 1 column left from center
    padding = " " * 10
    indicator = f"""




{padding}{color}╭─╮
{padding}│●│ ～～～
{padding}╰─╯
{padding} │ 
{padding}═╧═{RESET}
"""
    sys.stderr.write(indicator)
    sys.stderr.flush()

def animate_recording():
    """Show animated recording indicator"""
    # Just add a blank line for REC position
    padding = " " * 9  # 2 columns less than circle padding
    sys.stderr.write(f"\n\n")
    
    # Show the legend below with extra spacing and right shift
    legend = f"""


     {GRAY}{BOLD}Enter{RESET}{GRAY}: paste & run
     {BOLD}C{RESET}{GRAY}: clipboard  
     {BOLD}S{RESET}{GRAY}: search Firefox
     {BOLD}F{RESET}{GRAY}: format markdown
     {BOLD}Esc/^C{RESET}{GRAY}: cancel
     {BOLD}Other{RESET}{GRAY}: paste only{RESET}

"""
    sys.stderr.write(legend)
    sys.stderr.flush()
    
    # Move cursor back up to REC line for animation
    sys.stderr.write("\033[10A")  # Move up 10 lines (one more for markdown line)
    
    while not stop_animation.is_set():
        for dots in ["   ", ".  ", ".. ", "..."]:
            if stop_animation.is_set():
                break
            sys.stderr.write(f"\r{padding}{RED}Listening{dots}{RESET}")
            sys.stderr.flush()
            time.sleep(0.5)

def animate_uploading():
    """Show animated uploading indicator"""
    # Clear the entire screen and redraw
    sys.stderr.write("\033[2J")  # Clear screen
    sys.stderr.write("\033[H")   # Move cursor to home position
    
    # Show green circle
    show_recording_indicator(GREEN)
    
    # Just add blank lines for UP position (no static text)
    padding = " " * 9  # 2 columns less than circle padding
    sys.stderr.write(f"\n\n")
    
    # Show the legend again
    legend = f"""


     {GRAY}{BOLD}Enter{RESET}{GRAY}: paste & run
     {BOLD}C{RESET}{GRAY}: clipboard  
     {BOLD}S{RESET}{GRAY}: search Firefox
     {BOLD}F{RESET}{GRAY}: format markdown
     {BOLD}Esc/^C{RESET}{GRAY}: cancel
     {BOLD}Other{RESET}{GRAY}: paste only{RESET}

"""
    sys.stderr.write(legend)
    sys.stderr.flush()
    
    # Move cursor back to UP line for animation
    sys.stderr.write("\033[10A")  # Move up 10 lines (one more for markdown line)
    
    for i in range(20):  # Max 10 seconds of animation
        for dots in ["   ", ".  ", ".. ", "..."]:
            sys.stderr.write(f"\r{padding}{GREEN}Transcribing{dots}{RESET}")
            sys.stderr.flush()
            time.sleep(0.5)
            if upload_done.is_set():
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
        data={"model": "whisper-large-v3", "language": "en"},
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
        data={"model": "whisper-1", "language": "en"},
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

# Recording directory setup - using NAS path
NAS_DEV_DIR = os.path.expanduser("~/SynologyDrive/Areas/Dev")
RECORD_DIR = os.path.join(NAS_DEV_DIR, "dictation-data")

# Check if Dev directory exists (indicates NAS is mounted)
if not os.path.exists(NAS_DEV_DIR):
    err_print(f"\n{RED}ERROR: NAS not mounted or Dev directory missing!{RESET}\n")
    err_print(f"Expected path: {NAS_DEV_DIR}\n")
    err_print(f"Please ensure your Synology Drive is properly mounted.\n")
    sys.exit(1)

# Create dictation-data directory if it doesn't exist
os.makedirs(RECORD_DIR, exist_ok=True)

# CLI argument parsing
ap = argparse.ArgumentParser(add_help=False)
ap.add_argument("--retry", metavar="FILE", help="re-upload a saved .wav file")
ap.add_argument("--retry-last", action="store_true", help="re-upload the newest saved .wav file")
args, _ = ap.parse_known_args()

# Main script starts here
transcribe_func, backend_name = get_transcription_backend()

# Helper for retry
def do_retry(path):
    try:
        with open(path, "rb") as f:
            transcript = transcribe_func(f.read())
            print(transcript)
            # Save transcript file
            txt_file = path.replace('.wav', '.txt')
            with open(txt_file, 'w') as tf:
                tf.write(transcript)
        sys.exit(0)
    except Exception as e:
        err_print(f"\nRetry failed: {e}\n")
        sys.exit(1)

if args.retry or args.retry_last:
    if args.retry:
        wav_path = args.retry
    else:
        wav_files = [f for f in os.listdir(RECORD_DIR) if f.endswith(".wav")]
        if not wav_files:
            err_print("\nNo recordings found to retry\n")
            sys.exit(1)
        wav_path = os.path.join(RECORD_DIR, sorted(wav_files)[-1])
    do_retry(wav_path)

# Create a permanent file for recording
now = datetime.datetime.now()
stamp = now.strftime("%Y%m%d-%H%M%S-") + f"{now.microsecond//1000:03d}"
F = os.path.join(RECORD_DIR, f"{stamp}.wav")

# Use arecord as recommended by Perplexity - it properly drains buffers on SIGINT
cmd = [
    "/usr/bin/arecord",
    "-q",                    # Quiet mode
    "-f", "S16_LE",         # 16-bit signed little-endian
    "-r", "48000",          # 48kHz sample rate
    "-c", "1",              # Mono
    "--buffer-time", "50000",   # 50ms buffer (reduced for lower latency)
    F                       # Output file
]

# Start recording FIRST (before showing UI)
p = subprocess.Popen(cmd)

# Small delay to ensure recording has started
time.sleep(0.05)

# Show recording indicator after recording has started
show_recording_indicator()

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
    
    # If Ctrl-C was pressed (no key_pressed set), exit immediately
    if key_pressed is None:
        err_print("\nCancelled!\n")
        err_print(f"Recording kept at: {F}\n")
        err_print(f"Retry later with: dictate --retry '{F}'\n")
        sys.exit(130)
    
    # Check if Escape was pressed - exit immediately without transcribing
    if key_pressed == '\x1b':
        err_print("\nCancelled!\n")
        err_print(f"Recording kept at: {F}\n")
        err_print(f"Retry later with: dictate --retry '{F}'\n")
        sys.exit(130)
    
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
        
        # Save transcript to file
        txt_file = F.replace('.wav', '.txt')
        with open(txt_file, 'w') as f:
            f.write(transcript)
        
        # Exit with code based on key pressed
        if key_pressed in ['\n', '\r']:  # Enter key
            sys.exit(0)
        elif key_pressed in ['c', 'C']:  # C key for clipboard
            sys.exit(10)
        elif key_pressed in ['s', 'S']:  # S key for search
            sys.exit(11)
        elif key_pressed in ['f', 'F']:  # F key for markdown formatting
            sys.exit(12)
        else:
            sys.exit(99)  # Default action (just paste)
        
    except KeyboardInterrupt:
        upload_done.set()
        err_print("\nUpload aborted!\n")
        err_print(f"Recording kept at: {F}\n")
        err_print(f"Retry later with: dictate --retry '{F}'\n")
        sys.exit(1)
    except ValueError as e:
        upload_done.set()
        err_print(f"\nConfiguration error: {e}\n")
        err_print(f"Recording kept at: {F}\n")
        err_print(f"Retry later with: dictate --retry '{F}'\n")
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        upload_done.set()
        err_print(f"\nHTTP Error: {e}\n")
        err_print(f"Response: {e.response.text}\n")
        err_print(f"Recording kept at: {F}\n")
        err_print(f"Retry later with: dictate --retry '{F}'\n")
        sys.exit(1)
    except Exception as e:
        upload_done.set()
        err_print(f"\nUpload error: {e}\n")
        err_print(f"Recording kept at: {F}\n")
        err_print(f"Retry later with: dictate --retry '{F}'\n")
        sys.exit(1)
finally:
    # Only delete if we succeeded (transcript was saved)
    if 'transcript' in locals() and os.path.exists(F):
        try:
            os.remove(F)
        except OSError:
            pass
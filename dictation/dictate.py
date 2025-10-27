#!/usr/bin/env python3
import os, subprocess, requests, sys, time, signal, io, threading, datetime, argparse, shutil

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
    """Show animated recording indicator with timer"""
    # WAV format constants (from arecord command)
    SAMPLE_RATE = 48000  # Hz
    BITS_PER_SAMPLE = 16
    CHANNELS = 1
    BYTES_PER_SEC = SAMPLE_RATE * (BITS_PER_SAMPLE / 8) * CHANNELS  # ~96 KB/s
    MAX_SIZE_MB = 25  # API limit for upload (OGG)
    MAX_SIZE_BYTES = MAX_SIZE_MB * 1024 * 1024

    # OGG compression ratio (Quality 4 gives ~12x typically, use 10x for safety)
    OGG_COMPRESSION_RATIO = 10  # Conservative estimate (worst case was 9x)

    # Since we convert WAV to OGG, we can record until WAV is 250MB (becomes 25MB OGG)
    MAX_WAV_SIZE_BYTES = MAX_SIZE_BYTES * OGG_COMPRESSION_RATIO
    MAX_DURATION_SEC = MAX_WAV_SIZE_BYTES / BYTES_PER_SEC  # ~2730 seconds (~45.5 min)

    padding = " " * 9  # 2 columns less than circle padding

    # Reserve space for: timer + blank + status + blank + legend
    sys.stderr.write(f"\n\n\n")

    # Show the legend below with extra spacing
    legend = f"""

     {GRAY}{BOLD}Enter{RESET}{GRAY}: paste & run
     {BOLD}Tab{RESET}{GRAY}: browse history
     {BOLD}C{RESET}{GRAY}: clipboard
     {BOLD}S{RESET}{GRAY}: search Firefox
     {BOLD}F{RESET}{GRAY}: format markdown
     {BOLD}Esc/^C{RESET}{GRAY}: cancel
     {BOLD}Other{RESET}{GRAY}: paste only{RESET}

"""
    sys.stderr.write(legend)
    sys.stderr.flush()

    # Move cursor back up to timer line
    sys.stderr.write("\033[11A")  # Move up to timer line

    # Hide cursor during animation
    sys.stderr.write("\033[?25l")
    sys.stderr.flush()

    start_time = time.time()
    dot_cycle = ["   ", ".  ", ".. ", "..."]
    dot_index = 0

    while not stop_animation.is_set():
        elapsed = time.time() - start_time

        # Calculate file size and progress using actual file size
        if hasattr(animate_recording, 'recording_file') and os.path.exists(animate_recording.recording_file):
            current_size_bytes = os.path.getsize(animate_recording.recording_file)
        else:
            # Fallback to estimate if file doesn't exist yet
            current_size_bytes = elapsed * BYTES_PER_SEC

        current_size_mb = current_size_bytes / (1024 * 1024)
        # Calculate percentage based on WAV size limit (which becomes 25MB OGG after conversion)
        percent = (current_size_bytes / MAX_WAV_SIZE_BYTES) * 100
        remaining_sec = MAX_DURATION_SEC - (current_size_bytes / BYTES_PER_SEC)

        # Format time as MM:SS
        elapsed_min = int(elapsed // 60)
        elapsed_sec = int(elapsed % 60)
        remaining_min = int(remaining_sec // 60)
        remaining_sec_display = int(remaining_sec % 60)

        # Check if we're in danger zone (<1 minute remaining)
        danger_zone = remaining_sec < 60

        # Choose colors
        if danger_zone:
            # Everything red when <1 minute
            elapsed_color = RED
            pct_color = RED
            remaining_color = RED
        else:
            # Normal colors
            elapsed_color = RESET  # Normal/white color
            if percent < 70:
                pct_color = BLUE
            elif percent < 90:
                pct_color = '\033[33m'  # Yellow
            else:
                pct_color = RED
            remaining_color = GRAY

        # Format percentage with padding (always NNN%)
        pct_str = f"{int(percent):3d}%"

        # Line 1: Timer, percentage, remaining (left aligned with small indent)
        timer_line = f"   {elapsed_color}{elapsed_min:02d}:{elapsed_sec:02d}{RESET}   {pct_color}{pct_str}{RESET}   {remaining_color}~{remaining_min:02d}:{remaining_sec_display:02d}{RESET}"

        # Line 3 (skip line 2 for spacing): Status with animation (centered under mic)
        status_line = f"{padding}{RED}Listening{dot_cycle[dot_index]}{RESET}"

        # Write timer line (line 1)
        sys.stderr.write(f"\r{timer_line}\033[K")
        # Skip line 2 (blank line for spacing)
        sys.stderr.write(f"\n\r\033[K")
        # Write status line (line 3)
        sys.stderr.write(f"\n\r{status_line}\033[K")

        # Move cursor back up to timer line (2 lines up)
        sys.stderr.write("\033[2A")
        sys.stderr.flush()

        # Update animation
        dot_index = (dot_index + 1) % len(dot_cycle)
        time.sleep(0.5)

        if stop_animation.is_set():
            break

    # Show cursor again when animation stops
    sys.stderr.write("\033[?25h")
    sys.stderr.flush()

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
     {BOLD}Tab{RESET}{GRAY}: browse history
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

def transcribe_with_groq(file_data, mime_type="audio/ogg", filename="out.ogg"):
    """Transcribe audio using Groq's Whisper API"""
    api_key = os.getenv("GROQ_API_KEY")
    if not api_key:
        raise ValueError("GROQ_API_KEY not set")

    file_obj = io.BytesIO(file_data)

    r = requests.post(
        "https://api.groq.com/openai/v1/audio/transcriptions",
        headers={"Authorization": f"Bearer {api_key}"},
        data={"model": "whisper-large-v3", "language": "en"},
        files={"file": (filename, file_obj, mime_type)},
        timeout=120
    )
    r.raise_for_status()
    return r.json()["text"]

def transcribe_with_openai(file_data, mime_type="audio/ogg", filename="out.ogg"):
    """Transcribe audio using OpenAI's Whisper API"""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OPENAI_API_KEY not set")

    file_obj = io.BytesIO(file_data)

    r = requests.post(
        "https://api.openai.com/v1/audio/transcriptions",
        headers={"Authorization": f"Bearer {api_key}"},
        data={"model": "whisper-1", "language": "en"},
        files={"file": (filename, file_obj, mime_type)},
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
ap.add_argument("--retry", metavar="FILE", help="re-upload a saved .ogg or .wav file")
ap.add_argument("--retry-last", action="store_true", help="re-upload the newest saved recording (.ogg or .wav)")
args, _ = ap.parse_known_args()

# Main script starts here
transcribe_func, backend_name = get_transcription_backend()

# Helper for retry
def do_retry(path):
    try:
        # Determine file format
        if path.endswith('.ogg'):
            mime_type = "audio/ogg"
            filename = "out.ogg"
            ext = '.ogg'
        elif path.endswith('.wav'):
            mime_type = "audio/wav"
            filename = "out.wav"
            ext = '.wav'
        else:
            err_print(f"\nUnsupported file format: {path}\n")
            sys.exit(1)

        with open(path, "rb") as f:
            transcript = transcribe_func(f.read(), mime_type, filename)
            print(transcript)
            # Save transcript file
            txt_file = path.replace(ext, '.txt')
            with open(txt_file, 'w') as tf:
                tf.write(transcript)
        sys.exit(0)
    except Exception as e:
        err_print(f"\nRetry failed: {e}\n")
        sys.exit(1)

if args.retry or args.retry_last:
    if args.retry:
        file_path = args.retry
    else:
        # Look for OGG files first (new format), then WAV (legacy)
        ogg_files = [f for f in os.listdir(RECORD_DIR) if f.endswith(".ogg")]
        wav_files = [f for f in os.listdir(RECORD_DIR) if f.endswith(".wav")]
        all_files = [(f, ".ogg") for f in ogg_files] + [(f, ".wav") for f in wav_files]

        if not all_files:
            err_print("\nNo recordings found to retry\n")
            sys.exit(1)

        # Sort by filename (chronological) and get the newest
        all_files.sort(key=lambda x: x[0])
        newest_file, ext = all_files[-1]
        file_path = os.path.join(RECORD_DIR, newest_file)

    do_retry(file_path)

# Create a temp file for recording (in /tmp for speed)
now = datetime.datetime.now()
stamp = now.strftime("%Y%m%d-%H%M%S-") + f"{now.microsecond//1000:03d}"
F_wav = os.path.join("/tmp", f"dictate-{stamp}.wav")

# Use arecord as recommended by Perplexity - it properly drains buffers on SIGINT
cmd = [
    "/usr/bin/arecord",
    "-q",                    # Quiet mode
    "-f", "S16_LE",         # 16-bit signed little-endian
    "-r", "48000",          # 48kHz sample rate
    "-c", "1",              # Mono
    "--buffer-time", "50000",   # 50ms buffer (reduced for lower latency)
    F_wav                   # Output file
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
animate_recording.recording_file = F_wav  # Set file path for timer
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
        err_print(f"Recording kept at: {F_wav}\n")
        err_print(f"Retry later with: dictate --retry '{F_wav}'\n")
        sys.exit(130)

    # Check if Escape was pressed - exit immediately without transcribing
    if key_pressed == '\x1b':
        err_print("\nCancelled!\n")
        err_print(f"Recording kept at: {F_wav}\n")
        err_print(f"Retry later with: dictate --retry '{F_wav}'\n")
        sys.exit(130)

    # Check if Tab was pressed - exit immediately to open browse
    if key_pressed == '\t':
        err_print("\nOpening history...\n")
        sys.exit(13)

    # Check if file exists and has content
    if not os.path.exists(F_wav):
        err_print(f"\nError: Recording file {F_wav} not found!\n")
        sys.exit(1)

    file_size = os.path.getsize(F_wav)
    
    if file_size == 0:
        err_print("\nError: Recording file is empty!\n")
        sys.exit(1)
    
    # Now convert to OGG and upload with animation
    upload_thread = threading.Thread(target=animate_uploading)
    upload_thread.daemon = True
    upload_thread.start()

    try:
        # Convert WAV to OGG (in /tmp for speed)
        F_ogg = os.path.join("/tmp", f"dictate-{stamp}.ogg")
        subprocess.run([
            "ffmpeg", "-y", "-i", F_wav,
            "-acodec", "libvorbis", "-q:a", "4",
            "-hide_banner", "-loglevel", "error",
            F_ogg
        ], check=True)

        # Read OGG file for upload
        with open(F_ogg, "rb") as f:
            file_data = f.read()

        # Use the selected transcription backend with OGG
        transcript = transcribe_func(file_data, "audio/ogg", "out.ogg")
        upload_done.set()  # Stop animation
        time.sleep(0.1)  # Let animation clear
        print(transcript)

        # Save OGG to NAS permanently
        F_nas = os.path.join(RECORD_DIR, f"{stamp}.ogg")
        shutil.copy(F_ogg, F_nas)

        # Save transcript to file
        txt_file = F_nas.replace('.ogg', '.txt')
        with open(txt_file, 'w') as f:
            f.write(transcript)

        # Cleanup temp files
        os.remove(F_wav)
        os.remove(F_ogg)
        
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
        err_print(f"Recording kept at: {F_wav}\n")
        err_print(f"Retry later with: dictate --retry '{F_wav}'\n")
        sys.exit(1)
    except ValueError as e:
        upload_done.set()
        err_print(f"\nConfiguration error: {e}\n")
        err_print(f"Recording kept at: {F_wav}\n")
        err_print(f"Retry later with: dictate --retry '{F_wav}'\n")
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        upload_done.set()
        err_print(f"\nHTTP Error: {e}\n")
        err_print(f"Response: {e.response.text}\n")
        err_print(f"Recording kept at: {F_wav}\n")
        err_print(f"Retry later with: dictate --retry '{F_wav}'\n")
        sys.exit(1)
    except Exception as e:
        upload_done.set()
        err_print(f"\nUpload error: {e}\n")
        err_print(f"Recording kept at: {F_wav}\n")
        err_print(f"Retry later with: dictate --retry '{F_wav}'\n")
        sys.exit(1)
finally:
    # Temp files are already cleaned up in try block on success
    # On failure, they're kept in /tmp for retry
    pass
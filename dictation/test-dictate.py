#!/usr/bin/env python3
import os, subprocess, sys, time

# ANSI color codes
GRAY = '\033[90m'
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'

def err_print(msg, color=GRAY):
    sys.stderr.write(f"{color}{msg}{RESET}")
    sys.stderr.flush()

F = "out.wav"

# Use arecord as recommended - it properly drains buffers on SIGINT
cmd = [
    "/usr/bin/arecord",
    "-q",                    # Quiet mode
    "-f", "S16_LE",         # 16-bit signed little-endian
    "-r", "48000",          # 48kHz sample rate
    "-c", "1",              # Mono
    "--buffer-time", "200000",  # 200ms buffer (small enough to drain quickly)
    F                       # Output file
]

err_print("Recording with arecord... press Ctrl-C to stop\n", RED)
err_print("arecord properly drains buffers on exit - no audio should be lost!\n", GREEN)

# Start recording
p = subprocess.Popen(cmd)

try:
    # Wait for the process (will be interrupted by Ctrl-C)
    p.wait()
except KeyboardInterrupt:
    # User pressed Ctrl-C
    err_print("\nStopping recording...\n", RED)
    
    # arecord handles SIGINT properly and drains buffers
    # Just wait for it to finish
    p.wait()
    
    # Check if file exists and has content
    if not os.path.exists(F):
        err_print(f"\nError: Recording file {F} not found!\n")
        sys.exit(1)
    
    file_size = os.path.getsize(F)
    err_print(f"Recording file size: {file_size} bytes\n")
    
    # Get file duration
    try:
        duration_output = subprocess.check_output(["/usr/bin/soxi", "-D", F], text=True).strip()
        err_print(f"Recording duration: {duration_output} seconds\n")
    except:
        pass
    
    if file_size == 0:
        err_print("\nError: Recording file is empty!\n")
        sys.exit(1)
    
    # Now play it back
    err_print("\nPlaying back recording...\n", YELLOW)
    err_print("Listen for complete audio - nothing should be cut off!\n", GREEN)
    
    try:
        # Use play command
        play_cmd = ["/usr/bin/play", F]
        play_proc = subprocess.run(play_cmd)
        
        if play_proc.returncode == 0:
            err_print("\nPlayback complete!\n", GREEN)
            err_print(f"File saved as: {F}\n", GREEN)
            err_print("You can play it again with: play out.wav\n")
        else:
            err_print("\nPlayback failed!\n")
            
    except Exception as e:
        err_print(f"\nPlayback error: {e}\n")
        err_print(f"You can manually play the file with: play {F}\n")
        sys.exit(1)
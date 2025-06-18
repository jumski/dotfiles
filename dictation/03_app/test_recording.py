#!/usr/bin/env python3
import os, subprocess, sys, time, signal

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
# Same recording parameters as the main script
cmd = ["/usr/bin/rec", "--buffer", "65536", "-q", "-r", "48000", "-c", "1", F]

err_print("Recording... press Ctrl-C to stop\n", RED)

# Start recording in a subprocess
p = subprocess.Popen(cmd)

try:
    # Wait for the process (will be interrupted by Ctrl-C)
    p.wait()
except KeyboardInterrupt:
    # User pressed Ctrl-C
    err_print("\nStopping recording...\n", RED)
    
    # Send SIGINT to rec (same as Ctrl-C) for graceful shutdown
    p.send_signal(signal.SIGINT)
    
    # Wait up to 2 seconds for graceful shutdown
    try:
        p.wait(timeout=2.0)
    except subprocess.TimeoutExpired:
        # If still running, terminate
        err_print("Force stopping...\n", RED)
        p.terminate()
        time.sleep(0.5)
        if p.poll() is None:
            p.kill()
    
    # Wait for file to be fully written (check if size is stable)
    if os.path.exists(F):
        prev_size = 0
        for _ in range(10):  # Check up to 10 times
            time.sleep(0.1)
            curr_size = os.path.getsize(F)
            if curr_size == prev_size and curr_size > 0:
                break  # File size is stable
            prev_size = curr_size
    
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
    err_print("Listen carefully for any cut-off at the beginning or end\n", YELLOW)
    
    try:
        # Use play command (part of sox) to play the audio
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
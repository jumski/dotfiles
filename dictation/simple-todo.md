# Simple Dictation Backup - Pragmatic Implementation

## Core Concept
1. Always record into `~/.dictation_recordings/<timestamp>.wav` instead of temp file
2. On API failure, keep the file and show retry command
3. Add `--retry` flag to resend an existing file
4. Auto-cleanup files older than 14 days

That's it. No complexity. ~35 lines of changes.

## Implementation Changes

### 1. Add imports and setup (top of file)
```python
import os, subprocess, requests, sys, time, signal, io, threading, datetime, argparse

RECORD_DIR = os.path.expanduser("~/.dictation_recordings")
RETENTION_DAYS = 14
os.makedirs(RECORD_DIR, exist_ok=True)
```

### 2. Add cleanup function (runs on startup)
```python
def cleanup_old():
    """Delete recordings older than RETENTION_DAYS (best effort)."""
    cutoff = time.time() - RETENTION_DAYS * 86400
    for name in os.listdir(RECORD_DIR):
        if not name.endswith(".wav"):
            continue
        path = os.path.join(RECORD_DIR, name)
        if os.path.getmtime(path) < cutoff:
            try:
                os.remove(path)
            except OSError:
                pass
cleanup_old()
```

### 3. Add CLI arguments
```python
ap = argparse.ArgumentParser(add_help=False)
ap.add_argument("--retry", metavar="FILE", help="re-upload a saved .wav file")
ap.add_argument("--retry-last", action="store_true", help="re-upload the newest saved .wav file")
args, _ = ap.parse_known_args()

def do_retry(path):
    try:
        with open(path, "rb") as f:
            print(transcribe_func(f.read()))
        sys.exit(0)
    except Exception as e:
        err_print(f"\nRetry failed: {e}\n")
        sys.exit(1)

if args.retry or args.retry_last:
    wav_path = (args.retry if args.retry else
                os.path.join(RECORD_DIR,
                             sorted(f for f in os.listdir(RECORD_DIR)
                                    if f.endswith(".wav"))[-1]))
    do_retry(wav_path)
```

### 4. Replace temp file creation (lines 156-158)
```python
# OLD:
# import tempfile
# temp_fd, F = tempfile.mkstemp(suffix=".wav")
# os.close(temp_fd)

# NEW:
stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
F = os.path.join(RECORD_DIR, f"{stamp}.wav")
```

### 5. Update error handlers (all exception blocks)
Replace every `os.unlink(F)` in exception handlers with:
```python
err_print(f"\nRecording kept at: {F}\n"
          f"Retry later with: dictate.py --retry '{F}'\n")
```

### 6. Update final cleanup (bottom of file)
```python
# OLD:
# if os.path.exists(F):
#     os.unlink(F)

# NEW:
# Only delete if we succeeded
if 'transcript' in locals() and os.path.exists(F):
    try:
        os.remove(F)
    except OSError:
        pass
```

## Usage

Normal recording (unchanged):
```bash
dictate
```

If API fails, you'll see:
```
Recording kept at: ~/.dictation_recordings/20240115-143045.wav
Retry later with: dictate.py --retry '~/.dictation_recordings/20240115-143045.wav'
```

Retry options:
```bash
# Retry specific file
dictate.py --retry ~/.dictation_recordings/20240115-143045.wav

# Retry most recent recording
dictate.py --retry-last
```

## Benefits
- Never lose recordings
- Simple retry mechanism
- Automatic cleanup (no manual maintenance)
- Minimal code changes
- No dependencies or complex state

## What We DON'T Have (and don't need)
- ❌ Perfect atomicity
- ❌ Collision prevention
- ❌ Lock files
- ❌ Complex directory structures
- ❌ Audio compression
- ❌ Metadata files
- ❌ Configuration files
- ❌ Systemd timers

Perfect for personal use. Gets the job done. 🎯
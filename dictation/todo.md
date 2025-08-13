# Dictation Backup Recording System - Implementation Plan (v2)

## Overview
Implement a robust backup recording system to prevent data loss on API failures by storing recordings permanently with automatic retry capabilities.

## Critical Improvements from Review
- Use subdirectories per recording to ensure atomic operations
- Add collision prevention with microseconds/UUID
- Implement proper XDG directory standards
- Add disk space checks and auto-retry with exponential backoff
- Implement audio compression for storage efficiency

## Directory Structure
```
$XDG_DATA_HOME/dictation/     # (~/.local/share/dictation if XDG_DATA_HOME not set)
├── recordings/
│   ├── pending/
│   │   └── 2024-01-15_14-30-45.123456_a1b2c3/
│   │       └── audio.wav
│   ├── success/
│   │   └── 2024-01-15_14-25-30.654321_d4e5f6/
│   │       ├── audio.flac          # Compressed audio (optional)
│   │       ├── audio.wav           # Original (deleted after compression)
│   │       ├── transcript.txt      # Plain text transcript
│   │       └── metadata.json       # Full metadata with checksum
│   └── failed/
│       └── 2024-01-15_14-20-15.789012_g7h8i9/
│           ├── audio.wav
│           └── error.json          # Error details with retry count
└── lock                            # Lock file for concurrent operations
```

## File Naming Convention
- Directory name: `YYYY-MM-DD_HH-MM-SS.microseconds_shortuid`
  - Example: `2024-01-15_14-25-30.123456_a1b2c3`
  - Microseconds prevent same-second collisions
  - Short UID (6 chars) provides additional uniqueness

## Implementation Steps

### Phase 1: Core Infrastructure
- [ ] Use `$XDG_DATA_HOME/dictation` (fallback to `~/.local/share/dictation`)
- [ ] Create directory structure with proper permissions (700)
- [ ] Implement collision-resistant naming with microseconds + short UUID
- [ ] Add disk space check before recording (min 20MB free)
- [ ] Use `time.monotonic()` for duration calculation

### Phase 2: Atomic File Operations
- [ ] Create recording in subdirectory under `pending/`
- [ ] Write transcript/metadata to `.tmp` files first, then `os.replace()`
- [ ] Use `shutil.move()` for directory moves (atomic on same filesystem)
- [ ] Add filesystem check to ensure all dirs on same device
- [ ] Implement proper fsync for critical writes

### Phase 3: Auto-Retry with Exponential Backoff
- [ ] Detect transient errors (5xx, timeout, connection reset)
- [ ] Implement exponential backoff: 1s, 2s, 4s (max 3 attempts)
- [ ] Log retry attempts to stderr
- [ ] Move to `failed/` only after all retries exhausted
- [ ] Store retry history in error.json

### Phase 4: Audio Compression
- [ ] After successful transcription, compress WAV to FLAC
- [ ] Make compression optional via config (`reencode_success_to: flac|opus|none`)
- [ ] Delete original WAV after successful compression
- [ ] Store audio checksum (SHA-256) in metadata

### Phase 5: Enhanced CLI Arguments
- [ ] Add argparse for command-line options
- [ ] `--retry-last` - Retry most recent failed recording
- [ ] `--retry-all-failed` - Batch retry with rate limiting
- [ ] `--list-failed` - Show failed recordings with error summaries
- [ ] `--list-recent [N]` - Show last N recordings
- [ ] `--search <query>` - Full-text search in transcripts
- [ ] `--playback <timestamp>` - Play audio + show transcript
- [ ] `--print-path` - Output recording path for scripts
- [ ] `--cleanup <days>` - Manual cleanup of old recordings

### Phase 6: Configuration and Cleanup
- [ ] Configuration file: `$XDG_CONFIG_HOME/dictation/config.json`
  ```json
  {
    "data_dir": "$XDG_DATA_HOME/dictation",
    "keep_success_recordings": true,
    "success_retention_days": 7,
    "failed_retention_days": 30,
    "reencode_success_to": "flac",
    "auto_cleanup": true,
    "auto_retry_on_failure": true,
    "max_retry_attempts": 3,
    "min_free_space_mb": 20,
    "retry_delays": [1, 2, 4]
  }
  ```
- [ ] Implement cleanup with file locking
- [ ] Add systemd timer for automatic cleanup

### Phase 7: Robustness Features
- [ ] Add lock file for bulk operations (retry-all, cleanup)
- [ ] Implement integrity verification via checksums
- [ ] Add telemetry to metadata (API latency, retries, model version)
- [ ] Handle edge cases: 0-byte files, corrupted WAV headers
- [ ] Add `--validate` command to check recording integrity

## Key Code Implementation

### Directory Setup with XDG
```python
import os
import uuid
from datetime import datetime
from pathlib import Path

# XDG Base Directory compliance
XDG_DATA_HOME = os.environ.get('XDG_DATA_HOME', 
                               os.path.expanduser('~/.local/share'))
DICTATION_DIR = os.path.join(XDG_DATA_HOME, 'dictation')
PENDING_DIR = os.path.join(DICTATION_DIR, 'recordings/pending')
SUCCESS_DIR = os.path.join(DICTATION_DIR, 'recordings/success')
FAILED_DIR = os.path.join(DICTATION_DIR, 'recordings/failed')
LOCK_FILE = os.path.join(DICTATION_DIR, 'lock')

# Create with secure permissions
for dir_path in [PENDING_DIR, SUCCESS_DIR, FAILED_DIR]:
    os.makedirs(dir_path, mode=0o700, exist_ok=True)
```

### Collision-Resistant Naming
```python
def generate_recording_name():
    """Generate unique recording directory name"""
    now = datetime.now()
    timestamp = now.strftime("%Y-%m-%d_%H-%M-%S")
    microseconds = f"{now.microsecond:06d}"
    short_uid = uuid.uuid4().hex[:6]
    return f"{timestamp}.{microseconds}_{short_uid}"

# Check disk space
def check_disk_space(path, min_mb=20):
    """Check if enough disk space is available"""
    stat = os.statvfs(path)
    free_mb = (stat.f_bavail * stat.f_frsize) / (1024 * 1024)
    if free_mb < min_mb:
        raise IOError(f"Insufficient disk space: {free_mb:.1f}MB < {min_mb}MB")
```

### Atomic File Operations
```python
def save_transcript_atomic(recording_dir, transcript, metadata):
    """Save transcript and metadata atomically"""
    # Write to temp files first
    transcript_tmp = os.path.join(recording_dir, "transcript.txt.tmp")
    metadata_tmp = os.path.join(recording_dir, "metadata.json.tmp")
    
    # Write transcript
    with open(transcript_tmp, 'w') as f:
        f.write(transcript)
        f.flush()
        os.fsync(f.fileno())
    
    # Calculate audio checksum
    audio_path = os.path.join(recording_dir, "audio.wav")
    with open(audio_path, 'rb') as f:
        audio_checksum = hashlib.sha256(f.read()).hexdigest()
    
    # Add checksum to metadata
    metadata['audio_checksum'] = audio_checksum
    
    # Write metadata
    with open(metadata_tmp, 'w') as f:
        json.dump(metadata, f, indent=2)
        f.flush()
        os.fsync(f.fileno())
    
    # Atomic replace
    os.replace(transcript_tmp, os.path.join(recording_dir, "transcript.txt"))
    os.replace(metadata_tmp, os.path.join(recording_dir, "metadata.json"))
```

### Auto-Retry Implementation
```python
def transcribe_with_retry(file_data, backend_func, max_attempts=3):
    """Transcribe with exponential backoff retry"""
    delays = [1, 2, 4]  # seconds
    last_error = None
    
    for attempt in range(max_attempts):
        try:
            return backend_func(file_data), attempt + 1
        except requests.exceptions.RequestException as e:
            last_error = e
            
            # Check if error is retryable
            if isinstance(e, requests.exceptions.HTTPError):
                if e.response.status_code in [401, 403, 404]:
                    # Non-retryable errors
                    raise
            
            if attempt < max_attempts - 1:
                delay = delays[attempt]
                err_print(f"\\nTranscription failed ({e.__class__.__name__}). "
                         f"Retrying {attempt + 2}/{max_attempts} in {delay}s...\\n")
                time.sleep(delay)
            else:
                raise
    
    raise last_error
```

### Audio Compression
```python
def compress_audio(wav_path, format='flac'):
    """Compress audio file to save space"""
    if format == 'none':
        return wav_path
    
    base = os.path.splitext(wav_path)[0]
    
    if format == 'flac':
        output = f"{base}.flac"
        cmd = ['flac', '--best', '--silent', wav_path, '-o', output]
    elif format == 'opus':
        output = f"{base}.opus"
        cmd = ['opusenc', '--quiet', '--bitrate', '64', wav_path, output]
    else:
        raise ValueError(f"Unknown format: {format}")
    
    subprocess.run(cmd, check=True)
    os.unlink(wav_path)  # Delete original
    return output
```

### File Locking for Concurrent Operations
```python
def acquire_lock(timeout=10):
    """Acquire exclusive lock for bulk operations"""
    import fcntl
    
    start_time = time.time()
    lock_fd = None
    
    while time.time() - start_time < timeout:
        try:
            lock_fd = os.open(LOCK_FILE, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
            return lock_fd
        except FileExistsError:
            time.sleep(0.1)
    
    raise TimeoutError(f"Could not acquire lock after {timeout}s")

def release_lock(lock_fd):
    """Release the lock"""
    if lock_fd is not None:
        os.close(lock_fd)
        os.unlink(LOCK_FILE)
```

## Testing Plan
1. Test collision resistance with concurrent recordings
2. Simulate disk full scenarios
3. Test cross-filesystem moves (should fail gracefully)
4. Mock API failures to test retry logic
5. Verify atomic operations with kill -9 during writes
6. Test audio compression and checksum verification
7. Benchmark with 1000+ recordings for performance

## Security Considerations
- All directories created with 700 permissions
- No sensitive data in filenames
- Optional encryption for multi-user systems (future feature)
- Validate WAV headers before processing

## Migration Path
1. Detect old ~/.dictation location
2. Offer to migrate existing recordings
3. Update config to use new XDG paths
4. Keep backward compatibility for 2-3 versions
# Dictation Utility

A voice-to-text dictation system that records audio and transcribes it using Groq or OpenAI's Whisper API. Uses OGG Vorbis format for 10-14x smaller files and 50+ minute recording capacity. Features seamless tmux integration with multiple action keys for different workflows.

## Features

- **Reliable Audio Capture**: Uses `arecord` (ALSA) for buffer-safe recording - no audio cutoff
- **Permanent Recording Storage**: All recordings saved to NAS at `~/SynologyDrive/Areas/Dev/dictation-data/` with timestamps
- **Automatic Backup**: Never lose recordings - failed transcriptions can be retried later
- **Multiple Transcription Backends**: Groq (default) or OpenAI Whisper APIs
- **Smart Key Actions**:
  - **Enter**: Paste transcribed text and execute (perfect for chat/commands)
  - **C**: Copy to system clipboard
  - **S**: Search in Firefox via Perplexity
  - **F**: Format text as markdown using aichat
  - **Any other key**: Just paste text (no auto-execute)
- **Visual Feedback**: Clean UI with color-coded indicator (red ● for recording, green ● for uploading)
- **Tmux Integration**: Press `C-q C-q` to dictate from anywhere in tmux
- **Retry Failed Transcriptions**: Use `--retry` or `--retry-last` to resend recordings

## File Structure

```
dictation/
├── dictate.py              # Main dictation script - records and transcribes
├── dictate-actions.sh      # Action handler for different key presses
├── test-dictate.py         # Test script - records and plays back audio
├── test-dictate.sh         # Test wrapper for dictate-actions.sh
├── tmux-dictate-helper.sh  # Helper script for tmux popup environment
├── aliases.fish            # Fish shell aliases
├── crontab                 # Cron job for cleaning old recordings
└── README.md               # This file

~/SynologyDrive/Areas/Dev/dictation-data/  # Created automatically on NAS
├── 20240115-143045-123.ogg                # Saved recordings (YYYYMMDD-HHMMSS-mmm format, OGG Vorbis)
└── 20240115-143045-123.txt                # Transcribed text (created on success)
```

### File Descriptions

- **`dictate.py`**: Core script that handles recording (via arecord), transcription (via APIs), and key detection
- **`dictate-actions.sh`**: Wrapper that handles different actions based on which key was pressed
- **`test-dictate.py`**: Testing utility to verify audio recording works properly - plays back recorded audio
- **`test-dictate.sh`**: Test script for the dictation system with key actions
- **`tmux-dictate-helper.sh`**: Sources environment variables and runs dictate.py in tmux popup context
- **`aliases.fish`**: Defines shell commands: `dictate`, `dictate-groq`, `dictate-test`

## Requirements

### System Dependencies
- **Manjaro/Arch Linux** (or any Linux with ALSA)
- **Synology Drive** mounted at `~/SynologyDrive/` with `Areas/Dev` directory
- **arecord** (part of `alsa-utils` package)
- **ffmpeg** (for OGG Vorbis conversion)
- **sox** (for `play` command - audio playback)
- **Python 3** with `requests` library
- **tmux** (for popup integration)
- **xclip** (for clipboard functionality)
- **firefox** (for web search functionality)
- **fish shell** (for aliases, optional)

### API Requirements
- **Groq API key** (for default transcription)
- **OpenAI API key** (optional, for OpenAI backend)

## Installation

1. **Install system dependencies**:
   ```bash
   sudo pacman -S alsa-utils ffmpeg sox python-requests tmux xclip firefox
   ```

2. **Set up API keys in `~/.env.local`**:
   ```bash
   GROQ_API_KEY=your_groq_key_here
   OPENAI_API_KEY=your_openai_key_here  # Optional
   ```

3. **Source aliases in your fish config** (`~/.config/fish/config.fish`):
   ```fish
   source ~/.dotfiles/dictation/aliases.fish
   ```

4. **Add tmux keybinding** (already in your tmux.conf):
   ```tmux
   bind C-q run-shell -b "tmux display-popup -E -w 25 -h 10 -e TARGET_PANE='#{pane_id}' ~/.dotfiles/dictation/dictate-actions.sh"
   ```

5. **Set up automatic cleanup** (optional):
   ```bash
   # Add to your crontab
   crontab -e
   # Then add this line (removes OGG files after 28 days):
   0 3 * * * find ~/SynologyDrive/Areas/Dev/dictation-data -type f -name "*.ogg" -mtime +28 -delete 2>/dev/null

   # Optional: Also remove txt files (uncomment if you want to clean those too):
   # 0 3 * * * find ~/SynologyDrive/Areas/Dev/dictation-data -type f -name "*.txt" -mtime +28 -delete 2>/dev/null
   ```

## Usage

### Command Line
```bash
# Default (Groq transcription)
dictate

# Use OpenAI backend
dictate-openai

# Test recording (plays back audio)
dictate-test

# Set backend via environment
TRANSCRIPTION_BACKEND=openai dictate

# Retry failed transcriptions (supports both .ogg and .wav)
dictate --retry ~/SynologyDrive/Areas/Dev/dictation-data/20240115-143045-123.ogg
dictate --retry-last  # Retries the most recent recording
```

### In Tmux
1. Press `C-q C-q` (double prefix) anywhere in tmux
2. Small popup appears with red ● indicator and key legend
3. Speak into your microphone
4. Press a key to stop recording and choose action:
   - **Enter**: Transcribed text is pasted and executed (great for chat/commands)
   - **C**: Text is copied to system clipboard
   - **S**: Opens Firefox with Perplexity search of your text
   - **Any other key**: Just pastes the text without executing
5. Red ● turns green during upload
6. Popup closes and your chosen action is performed

## How It Works

1. **Recording**: Uses `arecord` with 50ms buffer for reliable capture
   - ALSA direct recording (no PulseAudio overhead)
   - Properly drains buffers on SIGINT (no audio loss)
   - Records 48kHz mono, 16-bit PCM WAV temporarily
   - Converts to OGG Vorbis Q4 for upload (10-14x smaller)

2. **Transcription**: Sends audio to chosen API
   - Groq: Uses `whisper-large-v3` model (fast and accurate)
   - OpenAI: Uses `whisper-1` model (alternative option)

3. **Smart Actions**: 
   - Python script exits with different codes based on key pressed
   - Shell wrapper (`dictate-actions.sh`) handles actions based on exit code
   - Clipboard uses background process with `nohup` to work in popup context
   - Target pane ID passed via environment variable for accurate pasting

## Troubleshooting

- **No audio devices**: Check `arecord -l` lists your microphone
- **API errors**: Verify API keys are set in `~/.env.local`
- **No text inserted**: Ensure tmux version ≥ 3.2 (for popup support)
- **Recording issues**: Test with `dictate-test` to verify audio capture
- **Failed transcription**: Check `/tmp` for temporary files or `~/SynologyDrive/Areas/Dev/dictation-data/` for saved OGG files, then use `dictate --retry-last`
- **NAS not mounted**: Script will fail with a red error if Synology Drive is not mounted or Dev directory is missing
- **Disk space**: OGG recordings are kept for 28 days by default. Transcripts (.txt files) are kept indefinitely unless you enable their cleanup in the cron job

## Technical Notes

- Uses `arecord` instead of `sox/rec` to avoid buffer loss issues
- Small 50ms ALSA buffer ensures quick draining on stop
- Records to `/tmp` (RAM) for speed, then converts to OGG before uploading
- OGG Vorbis Q4 provides 10-14x compression with excellent quality
- Tmux buffers provide reliable cross-pane text transfer
- All scripts output transcripts to stdout, errors to stderr
- Recordings saved as `YYYYMMDD-HHMMSS-mmm.ogg` in `~/SynologyDrive/Areas/Dev/dictation-data/` (includes milliseconds)
- Transcripts saved alongside as `.txt` files on successful transcription
- Failed recordings are preserved in `/tmp` for manual retry
- Successful transcriptions save OGG to NAS and delete temp files
- Legacy WAV files can still be retried with `--retry` flag
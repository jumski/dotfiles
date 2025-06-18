# Dictation Utility

A voice-to-text dictation system that records audio and transcribes it using Groq or OpenAI's Whisper API. Features seamless tmux integration for inserting transcribed text directly into any application.

## Features

- **Reliable Audio Capture**: Uses `arecord` (ALSA) for buffer-safe recording - no audio cutoff
- **Multiple Transcription Backends**: Groq (default) or OpenAI Whisper APIs
- **Tmux Integration**: Press `C-q e` to dictate directly into any tmux pane
- **Visual Feedback**: Color-coded status messages (red for recording, green for uploading)
- **Clean Architecture**: Simple, focused scripts that do one thing well

## File Structure

```
dictation/
├── dictate.py              # Main dictation script - records and transcribes
├── test-dictate.py         # Test script - records and plays back audio
├── tmux-dictate.sh         # Tmux integration wrapper (internal use)
├── tmux-dictate-helper.sh  # Helper script for tmux popup
├── aliases.fish            # Fish shell aliases
└── README.md               # This file
```

### File Descriptions

- **`dictate.py`**: Core script that handles recording (via arecord), transcription (via APIs), and outputs text to stdout
- **`test-dictate.py`**: Testing utility to verify audio recording works properly - plays back recorded audio
- **`tmux-dictate.sh`**: Internal script used by tmux keybinding - captures transcript and inserts into original pane
- **`tmux-dictate-helper.sh`**: Sources environment variables and runs dictate.py in tmux popup context
- **`aliases.fish`**: Defines shell commands: `dictate`, `dictate-groq`, `dictate-test`

## Requirements

### System Dependencies
- **Manjaro/Arch Linux** (or any Linux with ALSA)
- **arecord** (part of `alsa-utils` package)
- **sox** (for `play` command - audio playback)
- **Python 3** with `requests` library
- **tmux** (for popup integration)
- **fish shell** (for aliases, optional)

### API Requirements
- **Groq API key** (for default transcription)
- **OpenAI API key** (optional, for OpenAI backend)

## Installation

1. **Install system dependencies**:
   ```bash
   sudo pacman -S alsa-utils sox python-requests tmux
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
   bind e run-shell "sh -c '
       target=$(tmux display -p \"#{pane_id}\")
       tmux display-popup -E -w 40 -h 8 \"~/.dotfiles/dictation/tmux-dictate-helper.sh | tmux load-buffer -\"
       tmux paste-buffer -p -t \"$target\"
   '"
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
```

### In Tmux
1. Press `C-q e` (or `prefix + e`) anywhere in tmux
2. Small popup appears showing "Recording... press Ctrl-C to stop"
3. Speak into your microphone
4. Press `Ctrl-C` to stop recording
5. Wait for "Uploading..." message
6. Popup closes and transcribed text appears at your cursor

## How It Works

1. **Recording**: Uses `arecord` with 200ms buffer for reliable capture
   - ALSA direct recording (no PulseAudio overhead)
   - Properly drains buffers on SIGINT (no audio loss)
   - 48kHz mono, 16-bit PCM WAV format

2. **Transcription**: Sends audio to chosen API
   - Groq: Uses `whisper-large-v3` model (fast and accurate)
   - OpenAI: Uses `whisper-1` model (alternative option)

3. **Tmux Integration**: 
   - Captures pane ID before opening popup
   - Runs dictation in popup, capturing stdout
   - Loads transcript into tmux buffer
   - Pastes buffer content to original pane after popup closes

## Troubleshooting

- **No audio devices**: Check `arecord -l` lists your microphone
- **API errors**: Verify API keys are set in `~/.env.local`
- **No text inserted**: Ensure tmux version ≥ 3.2 (for popup support)
- **Recording issues**: Test with `dictate-test` to verify audio capture

## Technical Notes

- Uses `arecord` instead of `sox/rec` to avoid buffer loss issues
- Small 200ms ALSA buffer ensures quick draining on stop
- Tmux buffers provide reliable cross-pane text transfer
- All scripts output transcripts to stdout, errors to stderr
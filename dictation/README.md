# Dictation Utility

A voice-to-text dictation system that records audio and transcribes it using Groq or OpenAI's Whisper API. Features seamless tmux integration with multiple action keys for different workflows.

## Features

- **Reliable Audio Capture**: Uses `arecord` (ALSA) for buffer-safe recording - no audio cutoff
- **Multiple Transcription Backends**: Groq (default) or OpenAI Whisper APIs
- **Smart Key Actions**:
  - **Enter**: Paste transcribed text and execute (perfect for chat/commands)
  - **C**: Copy to system clipboard
  - **S**: Search in Firefox via Perplexity
  - **Any other key**: Just paste text (no auto-execute)
- **Visual Feedback**: Clean UI with color-coded indicator (red ● for recording, green ● for uploading)
- **Tmux Integration**: Press `C-q C-q` to dictate from anywhere in tmux

## File Structure

```
dictation/
├── dictate.py              # Main dictation script - records and transcribes
├── dictate-actions.sh      # Action handler for different key presses
├── test-dictate.py         # Test script - records and plays back audio
├── test-dictate.sh         # Test wrapper for dictate-actions.sh
├── tmux-dictate-helper.sh  # Helper script for tmux popup environment
├── aliases.fish            # Fish shell aliases
└── README.md               # This file
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
- **arecord** (part of `alsa-utils` package)
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
   sudo pacman -S alsa-utils sox python-requests tmux xclip firefox
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

1. **Recording**: Uses `arecord` with 200ms buffer for reliable capture
   - ALSA direct recording (no PulseAudio overhead)
   - Properly drains buffers on SIGINT (no audio loss)
   - 48kHz mono, 16-bit PCM WAV format

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

## Technical Notes

- Uses `arecord` instead of `sox/rec` to avoid buffer loss issues
- Small 200ms ALSA buffer ensures quick draining on stop
- Tmux buffers provide reliable cross-pane text transfer
- All scripts output transcripts to stdout, errors to stderr
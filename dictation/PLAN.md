We’re building a **self-contained “dictation” utility** that:

1. Records your voice to a WAV file (16 kHz mono) until you hit Ctrl-C
2. Uploads that file to Groq Whisper API for transcription
3. Prints the transcript to stdout and exits

All components live under a single `dictation/` folder, in three incremental stages you can verify one by one.

---

## Project layout

```bash
dictation/
├── 01_record/
│   └── record.sh
├── 02_transcribe/
│   └── transcribe.py
└── 03_app/
    └── speak.py
```

Create it once:

```bash
mkdir -p dictation/{01_record,02_transcribe,03_app}
```

---

## Quick facts from Groq docs

- **Endpoint**: `POST https://api.groq.com/openai/v1/audio/transcriptions`
- **File types**: WAV/MP3/FLAC/mp4 (≤ 25 MB free tier; 100 MB dev)
- **Model**: `whisper-large-v3-turbo` (≈ \$0.04/audio-hr)

No special auth beyond `Authorization: Bearer $GROQ_API_KEY`.

---

## Stage 01 `01_record/` – verify recording

1. **Install SoX**

   ```bash
   sudo apt-get update -qq
   sudo apt-get install -y sox libsox-fmt-all
   ```

2. **`01_record/record.sh`**

   ```bash
   #!/usr/bin/env bash
   set -e
   rec -q -r 16000 -b 16 -c 1 out.wav
   ```

3. **Test**

   ```bash
   cd dictation/01_record
   chmod +x record.sh
   ./record.sh    # speak, then Ctrl-C
   file out.wav   # expect: WAV (PCM) 16-bit mono 16kHz
   ```

---

## Stage 02 `02_transcribe/` – verify Groq upload

1. **Install Python deps**

   ```bash
   pip install requests
   ```

2. **`02_transcribe/transcribe.py`**

   ```python
   #!/usr/bin/env python3
   import os, sys, requests, pathlib

   API_KEY = os.getenv("GROQ_API_KEY")
   if not API_KEY:
       sys.exit("GROQ_API_KEY not set")

   wav = pathlib.Path(sys.argv[1] if len(sys.argv)>1 else "out.wav")
   if not wav.is_file():
       sys.exit(f"{wav} missing")

   r = requests.post(
       "https://api.groq.com/openai/v1/audio/transcriptions",
       headers={"Authorization": f"Bearer {API_KEY}"},
       data={"model": "whisper-large-v3-turbo"},
       files={"file": wav.open("rb")},
       timeout=60
   )
   r.raise_for_status()
   print(r.json()["text"])
   ```

3. **Test**

   ```bash
   cd dictation/02_transcribe
   cp ../01_record/out.wav .
   python3 transcribe.py out.wav
   ```

---

## Stage 03 `03_app/` – integrated utility

1. **`03_app/speak.py`**

   ```python
   #!/usr/bin/env python3
   import os, signal, subprocess, requests, sys

   API_KEY = os.getenv("GROQ_API_KEY")
   if not API_KEY:
       sys.exit("GROQ_API_KEY env var missing")

   F = "out.wav"
   cmd = ["rec","-q","-r","16000","-b","16","-c","1",F]

   print("Recording... press Ctrl-C to stop")
   p = subprocess.Popen(cmd)

   def stop(sig, frame):
       print("\nStopping")
       p.terminate()
       p.wait()
       upload()

   def upload():
       print("Uploading")
       with open(F,"rb") as f:
           r = requests.post(
               "https://api.groq.com/openai/v1/audio/transcriptions",
               headers={"Authorization":f"Bearer {API_KEY}"},
               data={"model":"whisper-large-v3-turbo"},
               files={"file":f}, timeout=120
           )
       r.raise_for_status()
       print("\nTRANSCRIPT:\n")
       print(r.json()["text"])
       sys.exit(0)

   signal.signal(signal.SIGINT, stop)
   signal.pause()
   ```

2. **Test**

   ```bash
   cd dictation/03_app
   chmod +x speak.py
   python3 speak.py   # speak, then Ctrl-C
   ```

   You should see your transcript printed and the script exit.

---

### Sanity checks

- If `rec` missing → install SoX or verify `$PATH`.
- If 413 error → keep recording under size limit or upgrade tier.
- If transcript slow → check network, file size, model choice.

Once all stages pass, `03_app/speak.py` is your final tool. It returns text on stdout, ready for any tmux piping or further automation.

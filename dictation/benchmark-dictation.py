#!/usr/bin/env python3
import os
import sys
import time
import subprocess
import requests
import io

# Get WAV file path from command line
if len(sys.argv) < 2:
    print("Usage: benchmark_dictation.py <wav_file>")
    sys.exit(1)

WAV_FILE = sys.argv[1]

if not os.path.exists(WAV_FILE):
    print(f"Error: File {WAV_FILE} not found")
    sys.exit(1)

# Check API key
api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    print("Error: GROQ_API_KEY not set")
    sys.exit(1)

# Get file info
wav_size = os.path.getsize(WAV_FILE)
print(f"\n{'='*60}")
print(f"Benchmarking: {os.path.basename(WAV_FILE)}")
print(f"WAV size: {wav_size / 1024 / 1024:.2f} MB")
print(f"{'='*60}\n")

# Test 1: Upload WAV directly
print("Test 1: Upload WAV directly to Groq")
print("-" * 60)

start = time.time()
with open(WAV_FILE, "rb") as f:
    wav_data = f.read()
read_time = time.time() - start

start = time.time()
file_obj = io.BytesIO(wav_data)
try:
    r = requests.post(
        "https://api.groq.com/openai/v1/audio/transcriptions",
        headers={"Authorization": f"Bearer {api_key}"},
        data={"model": "whisper-large-v3", "language": "en"},
        files={"file": ("out.wav", file_obj, "audio/wav")},
        timeout=120
    )
    r.raise_for_status()
    upload_time = time.time() - start
    total_wav = read_time + upload_time

    print(f"  Read time:   {read_time:.3f}s")
    print(f"  Upload time: {upload_time:.3f}s")
    print(f"  TOTAL:       {total_wav:.3f}s")
    transcript_wav = r.json()["text"]
    print(f"  Transcript preview: {transcript_wav[:80]}...")
except requests.exceptions.HTTPError as e:
    if e.response.status_code == 413:
        print(f"  ❌ FAILED: File too large ({wav_size / 1024 / 1024:.2f} MB exceeds 25MB API limit)")
        print(f"  This file CANNOT be transcribed as WAV!")
        total_wav = None
        transcript_wav = None
    else:
        raise

# Test 2: Convert to OGG then upload
print(f"\nTest 2: Convert to OGG + Upload OGG")
print("-" * 60)

ogg_file = "/tmp/benchmark_test.ogg"

start = time.time()
result = subprocess.run(
    ["ffmpeg", "-y", "-i", WAV_FILE, "-acodec", "libvorbis", "-q:a", "4",
     "-hide_banner", "-loglevel", "error", ogg_file],
    check=True,
    capture_output=True
)
convert_time = time.time() - start

ogg_size = os.path.getsize(ogg_file)
compression_ratio = wav_size / ogg_size

start = time.time()
with open(ogg_file, "rb") as f:
    ogg_data = f.read()
read_ogg_time = time.time() - start

start = time.time()
file_obj = io.BytesIO(ogg_data)
r = requests.post(
    "https://api.groq.com/openai/v1/audio/transcriptions",
    headers={"Authorization": f"Bearer {api_key}"},
    data={"model": "whisper-large-v3", "language": "en"},
    files={"file": ("out.ogg", file_obj, "audio/ogg")},
    timeout=120
)
r.raise_for_status()
upload_ogg_time = time.time() - start
total_ogg = convert_time + read_ogg_time + upload_ogg_time

print(f"  Convert time: {convert_time:.3f}s")
print(f"  Read time:    {read_ogg_time:.3f}s")
print(f"  Upload time:  {upload_ogg_time:.3f}s")
print(f"  TOTAL:        {total_ogg:.3f}s")
print(f"  OGG size:     {ogg_size / 1024 / 1024:.2f} MB (compression: {compression_ratio:.1f}x)")
transcript_ogg = r.json()["text"]
print(f"  Transcript preview: {transcript_ogg[:80]}...")

# Cleanup
os.remove(ogg_file)

# Summary
print(f"\n{'='*60}")
print("SUMMARY")
print(f"{'='*60}")
if total_wav is None:
    print(f"WAV total:  FAILED (file too large for API)")
    print(f"OGG total:  {total_ogg:.3f}s ✅ SUCCESS")
    print(f"\n🎯 KEY FINDING: WAV cannot be uploaded (>25MB limit)")
    print(f"   OGG compresses to {ogg_size / 1024 / 1024:.2f} MB and works perfectly!")
    print(f"   Without OGG, this recording would be UNUSABLE.")
else:
    print(f"WAV total:  {total_wav:.3f}s")
    print(f"OGG total:  {total_ogg:.3f}s")
    diff = total_wav - total_ogg
    if diff > 0:
        print(f"OGG is FASTER by {diff:.3f}s ({diff/total_wav*100:.1f}% faster)")
    else:
        print(f"WAV is FASTER by {-diff:.3f}s ({-diff/total_ogg*100:.1f}% faster)")

    print(f"\nUpload time saved: {upload_time - upload_ogg_time:.3f}s")
    print(f"Transcripts match: {transcript_wav == transcript_ogg}")

print(f"Compression ratio: {compression_ratio:.1f}x smaller")
print(f"{'='*60}\n")

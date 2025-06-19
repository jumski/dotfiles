#!/bin/bash

# List of all English voices
voices=(
    "Arista-PlayAI"
    "Atlas-PlayAI"
    "Basil-PlayAI"
    "Briggs-PlayAI"
    "Calum-PlayAI"
    "Celeste-PlayAI"
    "Cheyenne-PlayAI"
    "Chip-PlayAI"
    "Cillian-PlayAI"
    "Deedee-PlayAI"
    "Fritz-PlayAI"
    "Gail-PlayAI"
    "Indigo-PlayAI"
    "Mamaw-PlayAI"
    "Mason-PlayAI"
    "Mikail-PlayAI"
    "Mitch-PlayAI"
    "Quinn-PlayAI"
    "Thunder-PlayAI"
)

# Loop through each voice
for i in "${!voices[@]}"; do
    voice="${voices[$i]}"
    number=$((i + 1))
    echo "Playing voice $number: $voice"
    echo "$voice. Hi, this is voice number $number." | /home/jumski/.dotfiles/dictation/groq-tts.sh "$voice"
    sleep 1  # Small pause between voices
done

echo "Voice demo complete!"
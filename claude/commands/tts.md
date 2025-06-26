# TTS Voice Response Command

When this command is triggered, provide your response through the Groq text-to-speech system so the user can listen while browsing or doing other tasks.

Instructions:
1. FIRST write your complete response to the screen/output normally
2. THEN use the exact same text content for the TTS command
3. Use the reply-with-voice script at: /home/jumski/.dotfiles/dictation/reply-with-voice.sh
4. The script accepts a single argument - wrap your entire response in double quotes
5. Properly escape any quotes within the text using backslashes
6. Be concise and factual - get to the point immediately
7. Focus on the most important information first
8. No pleasantries, greetings, or filler words
9. Use complete sentences but keep them short and direct
10. Prioritize actionable information over explanations
11. If multiple points, lead with the most critical one

Example workflow:
1. Write: "The build failed due to missing dependencies. Run npm install to fix."
2. Then call: /home/jumski/.dotfiles/dictation/reply-with-voice.sh "The build failed due to missing dependencies. Run npm install to fix."

Remember: The user wants to read your response while listening to it. Always output the text first, then speak it.

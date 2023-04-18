function debug_with_gpt
  # Capture the current pane's content
    set pane_content (tmux capture-pane -p | tail -10)

    # prompt
    set pre_prompt "These are contents of my tmux pane:"
    set post_prompt "First: ignore output or command 'debug_with_gpt'. Your job is to understand output of previous command and suggest a solution if there was any kind of error, warning or failure."

    # Construct the JSON payload using jq
    set json_payload (echo '{}' | jq --arg content "$pre_prompt\n\n$pane_content\n\n$post_prompt" '.model = "gpt-3.5-turbo" | .messages = [{"role": "user", "content": $content}] | .temperature = 0.7')

    # Send the pane content to the OpenAI API and save the output to a variable
    set api_response (curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$json_payload" | jq -r '.choices[0].message.content // ""')

    echo "$api_response" | fmt -w 80
end

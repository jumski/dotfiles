#!/bin/bash

COMMIT_MSG_FILE="$1"
COMMIT_SOURCE="$2"

openai_model=gpt-4o
# openai_model=gpt-4o-mini

function generate_with() {
  echo $diff | sgpt --no-cache --model $openai_model --role commit-msg | sed 's/^\s*```//;s/```\s*$//' | awk 'NF {p=1} p; {if (NF) {p=1}}'
}

if [ -z "$COMMIT_SOURCE" ]; then
    diff=$(git diff --cached)
    diff_length=${#diff}

    if [ $diff_length -lt 5000 ]; then
        generate_with $openai_model > "$COMMIT_MSG_FILE"
    else
        echo "<<< DIFF TOO LONG - message generation skipped >>>" > "$COMMIT_MSG_FILE"
    fi
fi

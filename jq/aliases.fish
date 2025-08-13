#!/usr/bin/env fish

# jq-structure: Summarizes the structure of a JSON document in a jq-able way
# Source: https://github.com/stedolan/jq/issues/243#issuecomment-48470
alias jq-structure='jq -r '\''[path(..)|map(if type=="number" then "[]" else tostring end)|join(".")|split(".[]")|join("[]")]|unique|map("."+.)|.[]'\'''
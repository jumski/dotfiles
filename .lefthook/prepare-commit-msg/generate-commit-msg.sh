#!/bin/bash

COMMIT_MSG_FILE="$1"
COMMIT_SOURCE="$2"

README_MD=$(cat README.md)
ADDITIONAL_PROMPT="
- make your commit concise and clear
- do not explain basics, do not mindlessly repeat things or names
- use conventional commits format:

  <type>[optional scope]: <description>

  [optional body]

  [optional footer(s)]
- use one of the following commit types:
  - feat - Introduces a new feature
  - fix  - Patches a bug
  - docs - Documentation only changes
  - style - Code style changes (formatting, whitespace, etc.)
  - refactor - Refactoring code without changing behavior
  - perf - Performance improvements
  - test - Adding or correcting tests
  - build - Changes to build system or dependencies
  - ci - Changes to CI configuration
  - chore - Maintenance tasks (miscellaneous)
  - revert -Reverts a previous commit

- when changing files in a single directory, for example nvim/lazy-lock.yaml, use the folder name as conventional commit scope:
  - updated nvim/lazy-lock.yaml -> 'chore(nvim): update lazy-lock.yaml'
  - updates fish/aliases.fish -> 'feat(fish): add alias for google-search'
  - add new folder fzf/ and file fzf/packages.aur -> 'feat(fzf): setup packages.auro for fzf/'
- when changing files in multiple directories, concatenate dir names with + and use those as conventional commit scope:
  - updated nvim/plugins.vim and new alias in fish/aliases.fish -> 'chore(nvim+fish): install plugin_a with alias'
  - add new git alias in git/aliases.git and new binary in bin/git-smth -> 'feat(git+bin): add git smth'
"

if [ -z "$COMMIT_SOURCE" ]; then
    diff=$(git diff --cached --no-ext-diff --unified -- . ':(exclude)pnpm-lock.yaml' | head -c 5000)

    echo "$ADDITIONAL_PROMPT" > /tmp/commit.json
    echo $diff |
      bin/diff-to-commit-msg "openai" "$ADDITIONAL_PROMPT" |
      sed 's/^\s*```//;s/```\s*$//' | # remove code fences
      awk 'NF {p=1} p; {if (NF) {p=1}}' | # remove empty lines
      sed 's/\. /.\n/g' | # add newlines between sentences
      fmt --split-only --width=100 > "$COMMIT_MSG_FILE"
fi

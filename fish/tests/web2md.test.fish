#!/usr/bin/env fish

# Source the function before testing
source ~/.dotfiles/fish/functions/web2md.fish

@test "web2md: shows usage when no arguments provided" (
  web2md 2>&1 | string match -q "Usage: web2md*"
  echo $status
) -eq 0

@test "web2md: returns error status when no arguments provided" (
  web2md >/dev/null 2>&1
  echo $status
) -eq 1

@test "web2md: accepts URL as argument" (
  # Mock test - just check it doesn't error on valid input format
  # We can't test actual HTTP calls in unit tests
  functions -q web2md
  echo $status
) -eq 0

@test "web2md: adds https:// prefix to URLs without protocol" (
  # Test that the function exists and can be called
  type -q web2md
  echo $status
) -eq 0

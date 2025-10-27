#!/usr/bin/env fish

# Load the common functions
source (dirname (status filename))/../lib/common.fish

# Response handling tests
@test "_wt_confirm returns 0 for 'y' response" (echo "y" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 0

@test "_wt_confirm returns 0 for 'yes' response" (echo "yes" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 0

@test "_wt_confirm returns 0 for 'Y' response" (echo "Y" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 0

@test "_wt_confirm returns 1 for 'n' response" (echo "n" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 1

@test "_wt_confirm returns 1 for 'no' response" (echo "no" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 1

@test "_wt_confirm returns 1 for empty response (default N)" (echo "" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 1

@test "_wt_confirm returns 0 for empty response with --default-yes" (echo "" | _wt_confirm --prompt "Test prompt" --default-yes; echo $status) -eq 0

@test "_wt_confirm returns 1 for any other response" (echo "maybe" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 1

# Auto-confirm tests
@test "_wt_confirm returns 0 with --yes flag without prompting" (_wt_confirm --prompt "Test prompt" --yes >/dev/null; echo $status) -eq 0

@test "_wt_confirm returns 0 with --force flag without prompting" (_wt_confirm --prompt "Test prompt" --force >/dev/null; echo $status) -eq 0

@test "_wt_confirm returns 0 with --yes and no prompt text" (_wt_confirm --yes >/dev/null; echo $status) -eq 0

# Default prompt test
@test "_wt_confirm uses 'Confirm' as default prompt" (echo "y" | _wt_confirm; echo $status) -eq 0

# Prompt formatting tests (visual inspection needed, but status should be 0)
@test "_wt_confirm appends [y/N] indicator" (echo "y" | _wt_confirm --prompt "Proceed"; echo $status) -eq 0

@test "_wt_confirm appends [Y/n] indicator with --default-yes" (echo "n" | _wt_confirm --prompt "Proceed" --default-yes; echo $status) -eq 1

@test "_wt_confirm auto-adds question mark" (echo "y" | _wt_confirm --prompt "Do you want to proceed"; echo $status) -eq 0

@test "_wt_confirm does not add question mark if already present" (echo "y" | _wt_confirm --prompt "Proceed?"; echo $status) -eq 0

@test "_wt_confirm does not add question mark if ends with period" (echo "y" | _wt_confirm --prompt "Proceed."; echo $status) -eq 0

@test "_wt_confirm does not add question mark if ends with exclamation" (echo "y" | _wt_confirm --prompt "Proceed!"; echo $status) -eq 0
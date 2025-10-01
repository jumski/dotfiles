#!/usr/bin/env fish

# Load the common functions
source (dirname (status filename))/../functions/wt-common.fish

@test "_wt_confirm returns 0 for 'y' response" (echo "y" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 0

@test "_wt_confirm returns 0 for 'yes' response" (echo "yes" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 0

@test "_wt_confirm returns 0 for 'Y' response" (echo "Y" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 0

@test "_wt_confirm returns 1 for 'n' response" (echo "n" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 1

@test "_wt_confirm returns 1 for 'no' response" (echo "no" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 1

@test "_wt_confirm returns 1 for empty response (default N)" (echo "" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 1

@test "_wt_confirm returns 0 for empty response with --default-yes" (echo "" | _wt_confirm --prompt "Test prompt" --default-yes; echo $status) -eq 0

@test "_wt_confirm returns 1 for any other response" (echo "maybe" | _wt_confirm --prompt "Test prompt"; echo $status) -eq 1

@test "_wt_confirm uses custom prompt text" (echo "y" | _wt_confirm --prompt "Custom question [y/N]"; echo $status) -eq 0
#!/usr/bin/env fish

# Test main vmw dispatcher function

set -l functions_dir (dirname (status filename))/../functions
for f in $functions_dir/*.fish
    source $f
end

# Test: shows help when no args
@test "vmw shows help when no args" (
    vmw 2>&1 | grep -c "Usage:"
) -eq 1

# Test: shows help with --help
@test "vmw shows help with --help" (
    vmw --help 2>&1 | grep -c "Usage:"
) -eq 1

# Test: shows help with help subcommand
@test "vmw shows help with help subcommand" (
    vmw help 2>&1 | grep -c "Usage:"
) -eq 1

# Test: recognizes spawn subcommand
@test "vmw recognizes spawn subcommand" (
    vmw spawn 2>&1 | grep -c "Worktree path is required"
) -eq 1

# Test: recognizes list subcommand
@test "vmw recognizes list subcommand" (
    function virsh
        echo "mocked"
    end
    vmw list 2>&1 | grep -c "mocked"
) -eq 1

# Test: errors on unknown subcommand
@test "vmw errors on unknown subcommand" (
    vmw invalid-subcommand 2>&1 | grep -c "Unknown command"
) -eq 1

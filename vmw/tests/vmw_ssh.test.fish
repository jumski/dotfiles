#!/usr/bin/env fish

# Test vmw_ssh function

set -l functions_dir (dirname (status filename))/../functions
source $functions_dir/vmw_ssh.fish

# Test: fails when no name provided
@test "vmw_ssh fails when no name provided" (
    vmw_ssh 2>/dev/null
    echo $status
) -eq 1

# Test: outputs error when no name
@test "vmw_ssh outputs error when no name" (
    vmw_ssh 2>&1 | grep -c "VM name required"
) -eq 1

# Test: constructs correct SSH command
@test "vmw_ssh uses correct hostname" (
    set -g ssh_called ""
    function ssh
        set -g ssh_called "$argv"
        return 0
    end
    vmw_ssh my-vm >/dev/null 2>&1
    echo $ssh_called | grep -c "my-vm.local"
) -eq 1

# Test: forwards SSH agent
@test "vmw_ssh forwards agent with -A" (
    set -g ssh_called ""
    function ssh
        set -g ssh_called "$argv"
        return 0
    end
    vmw_ssh my-vm >/dev/null 2>&1
    echo $ssh_called | grep -c "\-A"
) -eq 1

#!/usr/bin/env fish

# Test vmw_destroy function

set -l functions_dir (dirname (status filename))/../functions
source $functions_dir/vmw_destroy.fish

# Test: fails when no name provided
@test "vmw_destroy fails when no name provided" (
    vmw_destroy 2>/dev/null
    echo $status
) -eq 1

# Test: outputs error when no name
@test "vmw_destroy outputs error when no name" (
    vmw_destroy 2>&1 | grep -c "VM name required"
) -eq 1

# Test: calls virsh destroy and undefine
@test "vmw_destroy calls virsh destroy" (
    set -g virsh_calls
    function virsh
        set -a virsh_calls "$argv"
        return 0
    end
    vmw_destroy my-vm >/dev/null 2>&1
    echo $virsh_calls | grep -c "destroy my-vm"
) -eq 1

# Test: calls virsh undefine
@test "vmw_destroy calls virsh undefine" (
    set -g virsh_calls
    function virsh
        set -a virsh_calls "$argv"
        return 0
    end
    vmw_destroy my-vm >/dev/null 2>&1
    echo $virsh_calls | grep -c "undefine my-vm"
) -eq 1

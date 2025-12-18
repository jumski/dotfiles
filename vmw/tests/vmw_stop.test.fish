#!/usr/bin/env fish

# Test vmw_stop function

set -l functions_dir (dirname (status filename))/../functions
source $functions_dir/vmw_stop.fish

# Test: fails when no name provided
@test "vmw_stop fails when no name provided" (
    vmw_stop 2>/dev/null
    echo $status
) -eq 1

# Test: outputs error when no name
@test "vmw_stop outputs error when no name" (
    vmw_stop 2>&1 | grep -c "VM name required"
) -eq 1

# Test: calls virsh shutdown with correct name
@test "vmw_stop calls virsh shutdown" (
    set -g virsh_called ""
    function virsh
        set -g virsh_called "$argv"
        return 0
    end
    vmw_stop my-vm >/dev/null 2>&1
    echo $virsh_called
) = "shutdown my-vm"

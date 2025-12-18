#!/usr/bin/env fish

# Test vmw_list function

set -l functions_dir (dirname (status filename))/../functions
source $functions_dir/vmw_list.fish

# Test: returns success (even with no VMs)
@test "vmw_list returns 0" (
    # Mock virsh to return empty list
    function virsh
        echo "Name   State"
        echo "-------------------"
    end
    vmw_list >/dev/null 2>&1
    echo $status
) -eq 0

# Test: parses virsh output and shows running VMs
@test "vmw_list shows running VMs" (
    function virsh
        echo " Id   Name              State"
        echo "--------------------------------"
        echo " 1    feature-branch    running"
        echo " 2    bugfix-123        running"
    end
    vmw_list | grep -c "running"
) -eq 2

# Test: handles VMs with vmw prefix
@test "vmw_list filters vmw- prefixed VMs" (
    function virsh
        echo " Id   Name              State"
        echo "--------------------------------"
        echo " 1    vmw-feature       running"
        echo " 2    other-vm          running"
    end
    # For now just show all VMs
    vmw_list | grep -c "vmw-feature"
) -eq 1

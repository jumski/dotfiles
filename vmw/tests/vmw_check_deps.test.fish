#!/usr/bin/env fish

# Test vmw_check_deps function

set -l functions_dir (dirname (status filename))/../functions
source $functions_dir/vmw_check_deps.fish

# Test: returns success when all deps are available
@test "vmw_check_deps returns 0 when all deps installed" (
    # Mock which to always succeed
    function which
        return 0
    end
    vmw_check_deps 2>/dev/null
    echo $status
) -eq 0

# Test: returns failure when virsh missing
@test "vmw_check_deps fails when virsh missing" (
    function which
        test "$argv[1]" != "virsh"
    end
    vmw_check_deps 2>/dev/null
    echo $status
) -eq 1

# Test: returns failure when qemu-img missing
@test "vmw_check_deps fails when qemu-img missing" (
    function which
        test "$argv[1]" != "qemu-img"
    end
    vmw_check_deps 2>/dev/null
    echo $status
) -eq 1

# Test: returns failure when virtiofsd missing
@test "vmw_check_deps fails when virtiofsd missing" (
    function which
        test "$argv[1]" != "virtiofsd"
    end
    vmw_check_deps 2>/dev/null
    echo $status
) -eq 1

# Test: outputs missing deps
@test "vmw_check_deps lists missing deps" (
    function which
        test "$argv[1]" = "virsh"; or test "$argv[1]" = "qemu-img"
    end
    vmw_check_deps 2>&1 | grep -c "Missing"
) -eq 1

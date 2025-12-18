#!/usr/bin/env fish

# Test vmw_setup function

set -l functions_dir (dirname (status filename))/../functions
source $functions_dir/vmw_check_deps.fish
source $functions_dir/vmw_setup.fish

# Test: checks dependencies first
@test "vmw_setup checks dependencies" (
    # Mock vmw_check_deps to fail
    function vmw_check_deps
        echo "deps check called" >&2
        return 1
    end
    vmw_setup 2>&1 | grep -c "deps check called"
) -eq 1

# Test: fails if deps missing
@test "vmw_setup fails if deps missing" (
    function vmw_check_deps
        return 1
    end
    vmw_setup >/dev/null 2>&1
    echo $status
) -eq 1

# Test: creates config directory
@test "vmw_setup creates config directory" (
    set -gx VMW_CONFIG_DIR /tmp/vmw-test-(random)
    function vmw_check_deps
        return 0
    end
    function wget
        return 0
    end
    function qemu-img
        return 0
    end
    vmw_setup >/dev/null 2>&1
    test -d $VMW_CONFIG_DIR
    set -l result $status
    rm -rf $VMW_CONFIG_DIR
    echo $result
) -eq 0

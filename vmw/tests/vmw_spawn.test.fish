#!/usr/bin/env fish

# Test vmw_spawn function

set -l functions_dir (dirname (status filename))/../functions
source $functions_dir/vmw_extract_name.fish
source $functions_dir/vmw_spawn.fish

# Test: fails when path doesn't exist
@test "vmw_spawn fails when path doesn't exist" (
    vmw_spawn /nonexistent/path 2>/dev/null
    echo $status
) -eq 1

# Test: fails when path is empty
@test "vmw_spawn fails when path is empty" (
    vmw_spawn "" 2>/dev/null
    echo $status
) -eq 1

# Test: fails when golden image missing
@test "vmw_spawn fails when golden image missing" (
    set -gx VMW_CONFIG_DIR /tmp/vmw-test-nonexistent
    vmw_spawn /tmp 2>/dev/null
    echo $status
) -eq 1

# Test: outputs error for missing path
@test "vmw_spawn outputs error for missing path" (
    vmw_spawn /nonexistent/path 2>&1 | grep -c "does not exist"
) -eq 1

# Test: outputs error for missing golden image
@test "vmw_spawn outputs error for missing golden image" (
    set -gx VMW_CONFIG_DIR /tmp/vmw-test-nonexistent
    vmw_spawn /tmp 2>&1 | grep -c "golden image not found"
) -eq 1

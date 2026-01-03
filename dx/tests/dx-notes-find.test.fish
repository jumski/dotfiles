#!/usr/bin/env fish

source (dirname (status -f))/../functions/dx-file-select.fish
source (dirname (status -f))/../functions/dx-notes-find.fish

# Helper to create test environment and run dx-notes-find
function _test_dx_notes_find
    set -l test_dir (mktemp -d)
    mkdir -p $test_dir/.notes
    echo "# Note" > $test_dir/.notes/note.md

    # Mock fzf
    function fzf
        head -n 1
    end

    cd $test_dir
    set result (dx-notes-find 2>/dev/null)
    set code $status

    rm -rf $test_dir
    functions -e fzf

    if test $code -eq 0; and string match -q "*.notes/*" -- $result
        return 0
    end
    return 1
end

# Helper to test missing .notes dir
function _test_dx_notes_find_missing
    set -l test_dir (mktemp -d)
    cd $test_dir
    dx-notes-find 2>/dev/null
    set code $status
    rm -rf $test_dir
    test $code -ne 0
end

# Helper to test empty .notes dir
function _test_dx_notes_find_empty
    set -l test_dir (mktemp -d)
    mkdir -p $test_dir/.notes
    cd $test_dir
    dx-notes-find 2>/dev/null
    set code $status
    rm -rf $test_dir
    test $code -ne 0
end

@test "finds files in .notes directory" (_test_dx_notes_find; echo $status) -eq 0

@test "returns error when .notes directory missing" (_test_dx_notes_find_missing; echo $status) -eq 0

@test "returns error when .notes has no markdown files" (_test_dx_notes_find_empty; echo $status) -eq 0

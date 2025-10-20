#!/usr/bin/env fish

source (dirname (status -f))/../functions/dx-notes-find.fish

# Create a temporary directory for testing
set -l test_dir (mktemp -d)

function setup
    # Create test markdown files
    mkdir -p $test_dir/notes
    mkdir -p $test_dir/branch-docs
    mkdir -p $test_dir/nested/dir
    mkdir -p $test_dir/node_modules

    echo "# Note 1" > $test_dir/notes/note1.md
    echo "# Note 2" > $test_dir/notes/note2.md
    echo "# Branch Doc" > $test_dir/branch-docs/doc1.md
    echo "# Root Note" > $test_dir/root.md
    echo "# Nested Note" > $test_dir/nested/dir/nested.md
    echo "# Ignored" > $test_dir/node_modules/ignored.md
end

function teardown
    rm -rf $test_dir
end

@test "finds files in \$notes directory when set" (
    setup

    set -x notes $test_dir/notes
    cd $test_dir

    # Mock fzf to return the first file
    function fzf
        head -n 1
    end

    set result (dx-notes-find)
    set exit_code $status

    test $exit_code -eq 0
    or return 1

    string match -q "*/notes/note1.md" -- $result
    or return 1

    set -e notes
    teardown
)

@test "falls back to branch-docs when \$notes not set" (
    setup

    set -e notes
    cd $test_dir

    function fzf
        head -n 1
    end

    set result (dx-notes-find)
    set exit_code $status

    test $exit_code -eq 0
    or return 1

    string match -q "*/branch-docs/doc1.md" -- $result
    or return 1

    teardown
)

@test "finds all markdown files recursively when no specific directory" (
    setup

    set -e notes
    cd $test_dir
    rm -rf branch-docs

    function fzf
        grep "nested.md"
    end

    set result (dx-notes-find)
    set exit_code $status

    test $exit_code -eq 0
    or return 1

    string match -q "*/nested/dir/nested.md" -- $result
    or return 1

    teardown
)

@test "excludes node_modules from search" (
    setup

    set -e notes
    cd $test_dir
    rm -rf branch-docs

    function fzf
        read -z files
        echo $files | string match -q "*node_modules*"
        and return 1
        or echo $files | head -n 1
    end

    set result (dx-notes-find)

    echo $result | string match -q "*node_modules*"
    and return 1
    or return 0

    teardown
)

@test "returns error when no markdown files found" (
    set -l empty_dir (mktemp -d)

    set -e notes
    cd $empty_dir

    dx-notes-find 2>/dev/null
    set exit_code $status

    test $exit_code -ne 0
    or begin
        rm -rf $empty_dir
        return 1
    end

    rm -rf $empty_dir
)

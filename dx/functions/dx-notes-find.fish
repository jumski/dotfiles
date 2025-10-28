function dx-notes-find -d "Find and select notes using fzf with bat preview"
    # Parse arguments
    argparse 'h/help' -- $argv
    or return 1

    # Show help
    if set -q _flag_help
        echo "Usage: dx-notes-find"
        echo ""
        echo "Find and select markdown notes using fzf with bat preview."
        echo ""
        echo "Search priority (stops at first match):"
        echo "  1. ./.notes/          Recursively search in notes directory"
        echo "  2. ./branch-docs/     Recursively search in branch docs directory"
        echo "  3. ./                 Recursively search all .md files from current directory"
        echo ""
        echo "Exclusions:"
        echo "  - node_modules/"
        echo "  - .git/"
        echo ""
        echo "Output:"
        echo "  Prints the selected file path to stdout, or returns 1 if cancelled."
        echo ""
        echo "Options:"
        echo "  -h, --help    Show this help message"
        return 0
    end

    # Use the generalized file selector with note-specific defaults
    # Priority order:
    #   1. ./.notes directory (recursive)
    #   2. ./branch-docs directory (recursive)
    #   3. All .md files recursively from current dir (excluding node_modules and .git)

    dx-file-select \
        --dirs 'RECURSIVE:./.notes' \
        --dirs 'RECURSIVE:./branch-docs' \
        --dirs 'RECURSIVE:.' \
        --pattern '*.md' \
        --exclude-dir node_modules \
        --exclude-dir .git \
        --preview-cmd 'bat --style=numbers,changes --color=always --language=markdown {}' \
        --preview-window 'right:60%:wrap' \
        --prompt 'Select note > '
end

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
        echo "  1. ./.notes/          Search in notes directory"
        echo "  2. ./branch-docs/     Search in branch docs directory"
        echo "  3. ./                 Search all .md files from current directory"
        echo ""
        echo "All searches are recursive by default."
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
    #   1. ./.notes directory
    #   2. ./branch-docs directory
    #   3. Current directory (all searches are recursive)

    dx-file-select \
        --dirs ./.notes \
        --dirs ./branch-docs \
        --dirs . \
        --pattern '*.md' \
        --exclude-dir node_modules \
        --exclude-dir .git \
        --preview-cmd 'bat --style=numbers,changes --color=always --language=markdown {}' \
        --preview-window 'right:60%:wrap' \
        --prompt 'Select note > '
end

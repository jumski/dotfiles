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
        echo "Searches only in ./.notes/ directory (recursive)."
        echo ""
        echo "Output:"
        echo "  Prints the selected file path to stdout, or returns 1 if cancelled."
        echo ""
        echo "Options:"
        echo "  -h, --help    Show this help message"
        return 0
    end

    # Search only in .notes directory
    dx-file-select \
        --dirs ./.notes \
        --pattern '*.md' \
        --preview-cmd 'bat --style=numbers,changes --color=always --language=markdown {}' \
        --preview-window 'right:60%:wrap' \
        --prompt 'Select note > '
end

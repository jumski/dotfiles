function dx-notes-find -d "Find and select notes using fzf with bat preview"
    # Use the generalized file selector with note-specific defaults
    # Priority order:
    #   1. $notes env variable
    #   2. ./branch-docs directory
    #   3. All .md files recursively (excluding node_modules and .git)

    dx-file-select \
        --dirs '$notes' ./branch-docs 'RECURSIVE:.' \
        --pattern '*.md' \
        --exclude-dir node_modules \
        --exclude-dir .git \
        --preview-cmd 'bat --style=numbers,changes --color=always --language=markdown {}' \
        --preview-window 'right:60%:wrap' \
        --prompt 'Select note > '
end

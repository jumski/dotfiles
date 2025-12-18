function vmw_extract_name --description "Extract VM name from worktree path"
    set -l path $argv[1]

    # Fail on empty path
    if test -z "$path"
        return 1
    end

    # Remove trailing slash and get basename
    set -l cleaned (string replace -r '/$' '' "$path")
    set -l name (basename "$cleaned")

    # Sanitize: replace dots and underscores with dashes
    set -l sanitized (string replace -a '.' '-' "$name" | string replace -a '_' '-')

    echo $sanitized
end

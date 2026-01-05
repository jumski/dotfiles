function _vmw_stage_claude --description "Stage ~/.claude/ items for VM mount"
    set -l staging_dir $argv[1]

    if test -z "$staging_dir"
        echo "Error: staging directory path required" >&2
        return 1
    end

    # Find the config file
    set -l config_file (dirname (status filename))/../claude-mount.list
    if not test -f "$config_file"
        echo "Error: claude-mount.list not found at $config_file" >&2
        return 1
    end

    set -l source_dir ~/.claude

    # Create staging directory
    mkdir -p $staging_dir

    # Read config and create symlinks
    for line in (cat $config_file)
        # Skip comments and empty lines
        set -l trimmed (string trim $line)
        if test -z "$trimmed"; or string match -q '#*' $trimmed
            continue
        end

        set -l source_path $source_dir/$trimmed
        set -l target_path $staging_dir/$trimmed

        if test -e "$source_path"
            # Create parent directory if needed
            set -l parent_dir (dirname $target_path)
            mkdir -p $parent_dir

            # Create symlink (virtiofsd follows symlinks)
            ln -sf $source_path $target_path
        else
            echo "Warning: $source_path does not exist, skipping" >&2
        end
    end

    return 0
end

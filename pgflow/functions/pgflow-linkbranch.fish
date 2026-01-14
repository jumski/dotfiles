function pgflow-linkbranch --description "Link current branch to pgflow branch docs folder"
    # Check if we're in pgflow repository by checking remote origin
    set -l remote_url (git remote get-url origin 2>/dev/null)
    if not string match -q "*pgflow*" "$remote_url"
        echo (set_color red)"Error: This function only works in a pgflow repository"(set_color normal)
        echo (set_color red)"Current remote: $remote_url"(set_color normal)
        return 1
    end

    # Get current branch name
    set -l branch_name (git branch --show-current 2>/dev/null)
    if test -z "$branch_name"
        echo (set_color red)"Error: Could not determine current branch"(set_color normal)
        return 1
    end

    set -l pgflow_branches_dir ~/SynologyDrive/Areas/pgflow/branches
    set -l target_dir "$pgflow_branches_dir/$branch_name"
    set -l link_path "./branch-docs"

    # Check current state
    echo (set_color cyan)"=== pgflow-linkbranch Status ==="(set_color normal)
    echo (set_color yellow)"Repository:"(set_color normal) (set_color green)"pgflow"(set_color normal)
    echo (set_color yellow)"Branch:"(set_color normal) (set_color green)"$branch_name"(set_color normal)
    echo (set_color yellow)"Target directory:"(set_color normal) "$target_dir"

    # Check if target directory exists
    if test -d "$target_dir"
        echo (set_color yellow)"Target dir status:"(set_color normal) (set_color green)"EXISTS"(set_color normal)
    else
        echo (set_color yellow)"Target dir status:"(set_color normal) (set_color blue)"WILL CREATE"(set_color normal)
    end

    # Check link status
    if test -L "$link_path"
        set -l current_target (readlink "$link_path")
        set -l resolved_target (realpath "$target_dir")
        set -l resolved_current (realpath "$current_target" 2>/dev/null)

        if test "$resolved_current" = "$resolved_target"
            echo (set_color yellow)"Link status:"(set_color normal) (set_color green)"ALREADY CORRECT"(set_color normal)
            echo (set_color green)"✓ branch-docs already points to the correct location"(set_color normal)
            return 0
        else
            echo (set_color yellow)"Link status:"(set_color normal) (set_color red)"WRONG TARGET"(set_color normal)
            echo (set_color red)"✗ branch-docs points to: $current_target"(set_color normal)
            echo (set_color red)"✗ Expected: $target_dir"(set_color normal)
            echo (set_color red)"Error: branch-docs is linked to something else!"(set_color normal)
            return 1
        end
    else if test -e "$link_path"
        echo (set_color yellow)"Link status:"(set_color normal) (set_color red)"FILE/DIR EXISTS"(set_color normal)
        echo (set_color red)"✗ branch-docs exists but is not a symbolic link"(set_color normal)
        echo (set_color red)"Error: branch-docs is occupied by something else!"(set_color normal)
        return 1
    else
        echo (set_color yellow)"Link status:"(set_color normal) (set_color blue)"WILL CREATE"(set_color normal)
    end

    echo ""
    echo (set_color cyan)"Plan:"(set_color normal)
    if not test -d "$target_dir"
        echo (set_color blue)"• Create directory: $target_dir"(set_color normal)
    end
    echo (set_color blue)"• Create symbolic link: $link_path → $target_dir"(set_color normal)
    echo ""

    # Ask for confirmation with nice prompt
    echo (set_color cyan)"Ready to proceed? "(set_color normal)(set_color green)"[Press any key]"(set_color normal)" "(set_color red)"[Ctrl+C to cancel]"(set_color normal)
    read -n 1

    # Create target directory if needed
    if not test -d "$target_dir"
        echo (set_color blue)"Creating directory: $target_dir"(set_color normal)
        if not mkdir -p "$target_dir"
            echo (set_color red)"Error: Failed to create directory"(set_color normal)
            return 1
        end
    end

    # Create symbolic link
    echo (set_color blue)"Creating link: $link_path → $target_dir"(set_color normal)
    if ln -s "$target_dir" "$link_path"
        echo (set_color green)"✓ Successfully linked branch-docs to $branch_name branch folder"(set_color normal)
        ls -la "$link_path"
    else
        echo (set_color red)"Error: Failed to create symbolic link"(set_color normal)
        return 1
    end
end

function pgflow-new-branch
    # Fixed paths
    set -l pgflow_root "/home/jumski/Code/pgflow-dev/pgflow"
    set -l worktrees_dir "/home/jumski/Code/pgflow-dev/worktrees"
    
    # Parse arguments for --base flag
    set -l base_branch
    set -l description_args
    set -l skip_next false
    
    for i in (seq (count $argv))
        if test "$skip_next" = "true"
            set skip_next false
            continue
        end
        
        if test "$argv[$i]" = "--base"
            if test (math $i + 1) -le (count $argv)
                set base_branch $argv[(math $i + 1)]
                set skip_next true
            end
        else if string match -q -- "--base=*" $argv[$i]
            set base_branch (string replace -- "--base=" "" $argv[$i])
        else
            set -a description_args $argv[$i]
        end
    end
    
    # Get current branch as default base
    set -l current_branch (git -C $pgflow_root branch --show-current)
    if test -z "$base_branch"
        set base_branch $current_branch
    end
    
    # Validate base branch exists
    if not git -C $pgflow_root rev-parse --verify --quiet $base_branch >/dev/null 2>&1
        echo "❌ "(set_color red)"Error: Branch '$base_branch' does not exist"(set_color normal)
        return 1
    end
    
    # Ask for branch description
    echo ""
    echo "🌊 "(set_color --bold cyan)"New pgflow Branch"(set_color normal)
    echo ""
    echo "🎯 "(set_color yellow)"Base branch: "(set_color --bold green)$base_branch(set_color normal)
    if test "$base_branch" != "$current_branch"
        echo "   "(set_color --dim)"(current branch: $current_branch)"(set_color normal)
    end
    echo ""
    
    set -l prompt_text (string join "" "📝 " (set_color --bold) "What are you working on? " (set_color normal))
    set -l description
    if test (count $description_args) -gt 0
        set description (string join " " $description_args)
        echo $prompt_text$description
    else
        # Use read without -l to avoid scope issues
        read -P "$prompt_text" description
    end
    
    # Track rejected branch names
    set -l rejected_names
    
    # Loop until user confirms branch name
    while true
        # Generate branch name using our AI function
        echo "Generating branch name..."
        echo "DEBUG: description = '$description'"
        
        # Build description with rejected names if any
        set -l full_description $description
        if test (count $rejected_names) -gt 0
            set full_description "$description (avoid these rejected names: "(string join ", " $rejected_names)")"
        end
        
        echo "DEBUG: full_description = '$full_description'"
        set -l branch_name (branch-name-ai "$full_description")
        
        if test -z "$branch_name"
            echo "Error: Failed to generate branch name"
            return 1
        end
        
        echo ""
        echo "🌿 "(set_color --bold green)"$branch_name"(set_color normal)
        echo ""
        echo "✅ "(set_color green)"y"(set_color normal)" = yes   "
        echo "❌ "(set_color red)"n"(set_color normal)" = no    "
        echo "🔄 "(set_color yellow)"r"(set_color normal)" = regenerate (or just hit "(set_color --bold)"Enter"(set_color normal)")"
        echo "✏️  "(set_color blue)"e"(set_color normal)" = edit description"
        echo ""
        set -l choice_prompt (string join "" (set_color --bold) "Your choice: " (set_color normal))
        read -n 1 -l -P "$choice_prompt" confirm
        echo  # Add newline after single character input
        
        if test -z "$confirm" -o "$confirm" = "r"
            # Regenerate with same description (empty input or 'r')
            echo "Regenerating..."
            set -a rejected_names $branch_name
            continue
        else if test "$confirm" = "y"
            # Debug: show branch name
            echo ""
            echo "🔍 "(set_color --bold magenta)"DEBUG INFO:"(set_color normal)
            echo "  🌿 "(set_color green)"branch_name"(set_color normal)" = "(set_color --bold)"'$branch_name'"(set_color normal)
            
            # Create simplified branch name for worktree directory
            set -l simplified_name (string replace -- "/" "--" $branch_name)
            echo "  📁 "(set_color blue)"simplified_name"(set_color normal)" = "(set_color --bold)"'$simplified_name'"(set_color normal)
            
            set -l worktree_path "$worktrees_dir/$simplified_name"
            echo "  📍 "(set_color cyan)"worktree_path"(set_color normal)" = "(set_color --bold)"'$worktree_path'"(set_color normal)
            echo "  🎯 "(set_color yellow)"base_branch"(set_color normal)" = "(set_color --bold green)"'$base_branch'"(set_color normal)
            echo ""
            
            # TEMPORARY: Ask for confirmation before proceeding
            read -l -P "🚧 Debug mode: Continue with actual worktree creation? (y/n): " debug_confirm
            if test "$debug_confirm" != "y"
                echo "⏸️  Paused for debugging. Exiting."
                return 0
            end
            
            # Check if worktree already exists
            if test -d $worktree_path
                echo "🔄 Worktree already exists at $worktree_path"
                echo "🚀 Opening in muxit..."
                muxit $worktree_path
                return 0
            end
            
            # Check if branch already exists and create worktree accordingly
            if git -C $pgflow_root rev-parse --verify --quiet $branch_name >/dev/null 2>&1
                echo "✨ Branch '$branch_name' already exists, using it!"
                echo "📂 Creating worktree at $worktree_path"
                if not git -C $pgflow_root worktree add $worktree_path $branch_name
                    echo "❌ Failed to create worktree"
                    return 1
                end
            else
                echo "🌱 Creating new branch '$branch_name' from base branch '$base_branch'"
                echo "📂 Creating worktree at $worktree_path"
                if not git -C $pgflow_root worktree add -b $branch_name $worktree_path $base_branch
                    echo "❌ Failed to create worktree"
                    return 1
                end
            end
            
            # Double-check the worktree was created
            if not test -d $worktree_path
                echo "❌ Worktree directory was not created: $worktree_path"
                echo "Something went wrong with the git worktree command"
                return 1
            end
            
            # Change to worktree directory
            cd $worktree_path
            echo "📁 Changed to: "(pwd)
            
            # Allow direnv
            echo "Allowing direnv..."
            if not direnv allow
                echo "⚠️  direnv allow failed, but continuing..."
            end
            
            # Run pnpm install
            echo "Running pnpm install..."
            if not pnpm install
                echo "⚠️  pnpm install failed, but continuing..."
            end
            
            # Open in muxit
            echo "Opening in muxit..."
            muxit $worktree_path
            
            break
        else if test "$confirm" = "n"
            echo "Cancelled."
            return 1
        else if test "$confirm" = "e"
            # Ask for new description
            echo ""
            set -l edit_prompt (string join "" "✏️  " (set_color --bold) "New description: " (set_color normal))
            read -l -P "$edit_prompt" description
        else
            echo "Invalid option. Please use y, n, r, or e"
        end
    end
end
function __mksupa_init -d "Initialize Supabase in current directory"
    set -l custom_version $argv[1]
    set -l should_commit $argv[2]
    set -l pgflow_version $argv[3]
    set -l supa_version "2.62.10"

    # Use custom version if provided
    if test -n "$custom_version"
        set supa_version $custom_version
    end

    set -l npx_cmd "npx -y supabase@$supa_version"

    echo ""
    set_color cyan
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 Supabase: Initialization"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    set_color normal
    echo ""

    # Setup environment FIRST (before using npx)
    set_color yellow
    echo "⚙  Setting up environment..."
    set_color normal

    # Create or update .env file with versions
    if test -n "$custom_version" -o -n "$pgflow_version"
        set_color brblack
        echo "  → Creating/updating .env..."
        set_color normal

        set -l env_lines
        if test -n "$custom_version"
            set -a env_lines "SUPABASE_VERSION=$custom_version"
        end
        if test -n "$pgflow_version"
            set -a env_lines "PGFLOW_VERSION=$pgflow_version"
        end

        printf '%s\n' $env_lines > .env
    end

    # Only create .envrc if it doesn't exist
    if not test -f .envrc
        set_color brblack
        echo "  → Creating .envrc"
        set_color normal
        printf '%s\n' 'use asdf' 'dotenv_if_exists ~/.env.local' 'dotenv_if_exists .env' '' 'PATH_add bin' > .envrc
    else
        set_color brblack
        echo "  → .envrc already exists"
        set_color normal
    end

    set_color brblack
    echo "  → Running direnv allow"
    set_color normal
    direnv allow .

    set_color brblack
    echo "  → Loading direnv environment"
    set_color normal
    eval (direnv export fish)
    echo ""

    # Run supabase init
    set_color blue
    echo "📦 Running supabase init..."
    set_color normal
    eval "$npx_cmd init --yes --with-intellij-settings --with-vscode-settings"
    if test $status -ne 0
        set_color red
        echo "✗ Failed to initialize Supabase"
        set_color normal
        return 1
    end
    echo ""

    # Create local supa command wrapper
    set_color yellow
    echo "⚙  Setting up local 'supa' command..."
    set_color normal
    set_color brblack
    echo "  → Creating bin/ directory"
    set_color normal
    mkdir -p bin

    set_color brblack
    echo "  → Creating bin/supa wrapper script"
    set_color normal
    printf '%s\n' '#!/bin/bash' 'exec npx -y supabase@${SUPABASE_VERSION:-2.62.10} "$@"' > bin/supa
    chmod +x bin/supa
    set_color brblack
    echo "    (wraps: npx -y supabase@\${SUPABASE_VERSION:-2.62.10})"
    set_color normal

    # Create bin/pgflow wrapper if pgflow version is provided
    if test -n "$pgflow_version"
        set_color brblack
        echo "  → Creating bin/pgflow wrapper script"
        set_color normal
        printf '%s\n' '#!/bin/bash' 'exec npx -y pgflow@${PGFLOW_VERSION:-latest} "$@"' > bin/pgflow
        chmod +x bin/pgflow
        set_color brblack
        echo "    (wraps: npx -y pgflow@\${PGFLOW_VERSION:-latest})"
        set_color normal
    end

    set_color green
    echo "  ✓ Local 'supa' command is now available"
    if test -n "$pgflow_version"
        echo "  ✓ Local 'pgflow' command is now available"
    end
    set_color normal
    echo ""

    # Stop other supatemp projects
    set_color yellow
    echo "⏹  Stopping other supatemp projects..."
    set_color normal
    eval "$npx_cmd stop --no-backup --project-id supatemp" 2>/dev/null
    echo ""

    # Update project_id in config.toml
    set -l config_file "supabase/config.toml"
    if test -f "$config_file"
        set_color blue
        echo "📝 Updating project_id in config.toml..."
        set_color normal

        # Use sed to replace project_id line
        sed -i 's/^project_id = ".*"/project_id = "supatemp"/' "$config_file"

        if test $status -eq 0
            set_color green
            echo "  ✓ Updated project_id to 'supatemp'"
            set_color normal
        else
            set_color yellow
            echo "  ⚠ Failed to update project_id"
            set_color normal
        end
        echo ""
    else
        set_color yellow
        echo "⚠ config.toml not found at $config_file"
        set_color normal
        echo ""
    end

    # Start the new project
    set_color green
    echo "▶  Starting Supabase..."
    set_color normal
    set -l supabase_start_failed 0
    eval "$npx_cmd start"
    if test $status -ne 0
        set supabase_start_failed 1
        echo ""
        set_color red
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✗ Failed to start Supabase"
        echo "  (Is another Supabase instance already running?)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        set_color normal
        echo ""
        set_color yellow
        echo "⚠  Continuing with project setup..."
        set_color normal
    end

    echo ""
    if test $supabase_start_failed -eq 0
        set_color green; set_color --bold
        echo "✨ Supabase project initialized and started!"
        set_color normal
    else
        set_color yellow; set_color --bold
        echo "✨ Supabase project initialized (but not started)"
        set_color normal
    end

    # Send tmux notification
    if test -n "$TMUX"
        tmux display-message -d 4000 "✨ Supabase initialized!"
    end

    # Commit and push to git if requested (from mksupa new)
    if test "$should_commit" = "1"
        # Get directory name for commit message
        set -l dir_name (basename $PWD)

        # Source git functions
        set -l lib_dir (dirname (status --current-filename))
        source "$lib_dir/git.fish"

        __mksupa_git_commit_push "$dir_name"
        # Continue even if git fails - error messages already shown
    end
end

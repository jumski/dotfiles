function __mksupa_init -d "Initialize Supabase in current directory"
    set -l supa_version "2.34.3"
    set -l npx_cmd "npx -y supabase@$supa_version"

    echo ""
    set_color cyan
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 Supabase: Initialization"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    set_color normal
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

    # Setup local supa command via direnv
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
    echo "#!/bin/bash" > bin/supa
    echo "exec npx -y supabase@$supa_version \"\$@\"" >> bin/supa
    chmod +x bin/supa
    set_color brblack
    echo "    (wraps: npx -y supabase@$supa_version)"
    set_color normal

    set_color brblack
    echo "  → Creating .envrc with PATH_add bin"
    set_color normal
    echo "PATH_add bin" > .envrc

    set_color brblack
    echo "  → Running direnv allow"
    set_color normal
    direnv allow .

    set_color green
    echo "  ✓ Local 'supa' command is now available"
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
    eval "$npx_cmd start"
    if test $status -ne 0
        set_color red
        echo "✗ Failed to start Supabase"
        set_color normal
        return 1
    end

    echo ""
    set_color green; set_color --bold
    echo "✨ Supabase project initialized and started!"
    set_color normal
end

function __mksupa_init -d "Initialize Supabase in current directory"
    set -l supa_version "2.34.3"
    set -l npx_cmd "npx -y supabase@$supa_version"

    echo "🚀 Initializing Supabase project..."
    echo ""

    # Run supabase init
    echo "Running supabase init..."
    eval "$npx_cmd init --yes --with-intellij-settings --with-vscode-settings"
    if test $status -ne 0
        echo "Error: Failed to initialize Supabase"
        return 1
    end
    echo ""

    # Setup local supa command via direnv
    echo "Setting up local 'supa' command..."
    echo "  → Creating bin/ directory"
    mkdir -p bin

    echo "  → Creating bin/supa wrapper script"
    echo "#!/bin/bash" > bin/supa
    echo "exec npx -y supabase@$supa_version \"\$@\"" >> bin/supa
    chmod +x bin/supa
    echo "    (wraps: npx -y supabase@$supa_version)"

    echo "  → Creating .envrc with PATH_add bin"
    echo "PATH_add bin" > .envrc

    echo "  → Running direnv allow"
    direnv allow .

    echo "✓ Local 'supa' command is now available in this directory"
    echo ""

    # Stop other supatemp projects
    echo "Stopping other supatemp projects..."
    eval "$npx_cmd stop --no-backup --project-id supatemp" 2>/dev/null
    echo ""

    # Update project_id in config.toml
    set -l config_file "supabase/config.toml"
    if test -f "$config_file"
        echo "Updating project_id in $config_file..."

        # Use sed to replace project_id line
        sed -i 's/^project_id = ".*"/project_id = "supatemp"/' "$config_file"

        if test $status -eq 0
            echo "✓ Updated project_id to 'supatemp'"
        else
            echo "Warning: Failed to update project_id"
        end
        echo ""
    else
        echo "Warning: config.toml not found at $config_file"
        echo ""
    end

    # Start the new project
    echo "Starting Supabase..."
    eval "$npx_cmd start"
    if test $status -ne 0
        echo "Error: Failed to start Supabase"
        return 1
    end

    echo ""
    echo "✨ Supabase project initialized and started!"
end

function __mksupa_new_temp -d "Create new temporary Supabase project"
    set -l prefix $argv[1]
    set -l supabase_version $argv[2]
    set -l pgflow_version $argv[3]
    set -l base_dir "$HOME/Code/pgflow-dev/supatemp"

    # Check git repo status
    __mksupa_check_repo
    set -l repo_status $status

    if test $repo_status -eq 1
        # Directory doesn't exist - offer to clone
        __mksupa_offer_clone
        if test $status -ne 0
            return 1
        end
    else if test $repo_status -eq 2
        # Directory exists but is not a git repo - fail with error
        echo ""
        set_color red
        echo "✗ Error: $base_dir exists but is not a git repository"
        set_color normal
        echo ""
        set_color brblack
        echo "Please remove it and clone the repository:"
        echo "  → rm -rf $base_dir"
        echo "  → gh repo clone pgflow-dev/supatemp $base_dir"
        set_color normal
        echo ""
        return 1
    end
    # If repo_status is 0, it's a git repo - proceed

    echo ""
    set_color blue
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📁 Creating new temp project: $prefix"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    set_color normal

    # Create temporary directory with prefix
    set_color brblack
    echo "  → Creating temp directory..."
    set_color normal
    set -l date_stamp (date +%Y-%m-%d-%H%M)
    set -l temp_dir (mktemp -d "$base_dir/$date_stamp-$prefix-XXXXXX")
    if test $status -ne 0
        set_color red
        echo "  ✗ Failed to create temporary directory"
        set_color normal
        return 1
    end

    set -l dir_name (basename "$temp_dir")
    set -l session_name "supatemp-$dir_name"

    # Create .env file with version variables
    if test -n "$supabase_version" -o -n "$pgflow_version"
        set_color brblack
        echo "  → Creating .env..."
        set_color normal

        set -l env_lines
        if test -n "$supabase_version"
            set -a env_lines "SUPABASE_VERSION=$supabase_version"
        end
        if test -n "$pgflow_version"
            set -a env_lines "PGFLOW_VERSION=$pgflow_version"
        end

        printf '%s\n' $env_lines > "$temp_dir/.env"
    end

    # Create .envrc from template
    set_color brblack
    echo "  → Creating .envrc..."
    set_color normal
    printf '%s\n' 'use asdf' 'dotenv_if_exists ~/.env.local' 'dotenv_if_exists .env' '' 'PATH_add bin' > "$temp_dir/.envrc"

    # Allow direnv immediately to prevent error in tmux windows
    set_color brblack
    echo "  → Allowing .envrc..."
    set_color normal
    direnv allow "$temp_dir"

    # Create PGFLOW.md if pgflow_version is provided
    if test -n "$pgflow_version"
        set_color brblack
        echo "  → Creating PGFLOW.md..."
        set_color normal
        printf '%s\n' \
            "# Testing control-plane snapshot release" \
            "" \
            "Install with npm:" \
            "" \
            '```sh' \
            "npm install pgflow@$pgflow_version" \
            "npm install @pgflow/client@$pgflow_version" \
            "npm install @pgflow/core@$pgflow_version" \
            "npm install @pgflow/dsl@$pgflow_version" \
            "npm install @pgflow/example-flows@$pgflow_version" \
            '```' \
            "" \
            "For Deno/Supabase Edge Functions:" \
            "" \
            '```ts' \
            "import { EdgeWorker } from \"jsr:@pgflow/edge-worker@$pgflow_version\";" \
            '```' \
            "" \
            "Or add to deno.json imports:" \
            "" \
            '```json' \
            '{' \
            '  "imports": {' \
            "    \"@pgflow/edge-worker\": \"jsr:@pgflow/edge-worker@$pgflow_version\"," \
            "    \"@pgflow/dsl\": \"npm:@pgflow/dsl@$pgflow_version\"," \
            "    \"@pgflow/dsl/supabase\": \"npm:@pgflow/dsl@$pgflow_version/supabase\"," \
            "    \"@pgflow/core\": \"npm:@pgflow/core@$pgflow_version\"" \
            '  }' \
            '}' \
            '```' \
            > "$temp_dir/PGFLOW.md"
    end

    # Create bin/serve script
    set_color brblack
    echo "  → Creating bin/serve..."
    set_color normal
    mkdir -p "$temp_dir/bin"
    printf '%s\n' \
        '#!/usr/bin/env bash' \
        '' \
        'supabase functions serve --no-verify-jwt 2>&1 | grep -Pv '\''serving the request with supabase/functions/[a-zA-Z0-9-]+-worker|^\d{4}-\d{2}-\d{2}T[\d:.]+Z\s\*$'\''' \
        > "$temp_dir/bin/serve"
    chmod +x "$temp_dir/bin/serve"

    # Set up templates directory path
    set -l lib_dir (dirname (status --current-filename))
    set -l templates_dir (realpath "$lib_dir/../templates")

    # Create queries directory and SQL files
    set_color brblack
    echo "  → Creating queries/start_flow.sql..."
    set_color normal
    mkdir -p "$temp_dir/queries"
    printf '%s\n' \
        "SELECT pgflow.start_flow(" \
        "  flow_slug => 'greetUser'," \
        "  input => '{\"firstName\": \"Alice\", \"lastName\": \"Smith\"}'::jsonb" \
        ") FROM generate_series(1, :COUNT::int);" \
        > "$temp_dir/queries/start_flow.sql"

    set_color brblack
    echo "  → Creating queries/runs.sql..."
    set_color normal
    printf '%s\n' \
        "SELECT status, remaining_steps, output FROM pgflow.runs" \
        "WHERE flow_slug = 'greetUser'" \
        "ORDER BY started_at DESC" \
        "LIMIT :COUNT::int;" \
        > "$temp_dir/queries/runs.sql"

    set_color brblack
    echo "  → Creating queries/results.sql..."
    set_color normal
    cp "$templates_dir/queries/results.sql" "$temp_dir/queries/results.sql"

    set_color brblack
    echo "  → Creating queries/step_states.sql..."
    set_color normal
    cp "$templates_dir/queries/step_states.sql" "$temp_dir/queries/step_states.sql"

    # Create bin/start_flow script
    set_color brblack
    echo "  → Creating bin/start_flow..."
    set_color normal
    cp "$templates_dir/bin/start_flow" "$temp_dir/bin/start_flow"
    chmod +x "$temp_dir/bin/start_flow"

    # Create bin/runs script
    set_color brblack
    echo "  → Creating bin/runs..."
    set_color normal
    cp "$templates_dir/bin/runs" "$temp_dir/bin/runs"
    chmod +x "$temp_dir/bin/runs"

    # Create bin/prune script
    set_color brblack
    echo "  → Creating bin/prune..."
    set_color normal
    cp "$templates_dir/bin/prune" "$temp_dir/bin/prune"
    chmod +x "$temp_dir/bin/prune"

    # Create bin/benchmark script
    set_color brblack
    echo "  → Creating bin/benchmark..."
    set_color normal
    cp "$templates_dir/bin/benchmark" "$temp_dir/bin/benchmark"
    chmod +x "$temp_dir/bin/benchmark"

    # Create bin/results script
    set_color brblack
    echo "  → Creating bin/results..."
    set_color normal
    cp "$templates_dir/bin/results" "$temp_dir/bin/results"
    chmod +x "$temp_dir/bin/results"

    # Create bin/worker script
    set_color brblack
    echo "  → Creating bin/worker..."
    set_color normal
    cp "$templates_dir/bin/worker" "$temp_dir/bin/worker"
    chmod +x "$temp_dir/bin/worker"

    # Create bin/workers script
    set_color brblack
    echo "  → Creating bin/workers..."
    set_color normal
    cp "$templates_dir/bin/workers" "$temp_dir/bin/workers"
    chmod +x "$temp_dir/bin/workers"

    # Stage and commit initial files
    set_color brblack
    echo "  → Committing initial files..."
    set_color normal
    git -C "$temp_dir" add -A
    git -C "$temp_dir" commit -m "chore: initialize temp project $dir_name"

    # Create tmux session with 4 windows
    set_color brblack
    echo "  → Creating tmux session with 4 windows..."
    set_color normal
    # new-session creates window 0, then we add 3 more windows (1, 2, 3)
    tmux new-session -d -s "$session_name" -c "$temp_dir"
    tmux new-window -t "$session_name" -c "$temp_dir"
    tmux new-window -t "$session_name" -c "$temp_dir"
    tmux new-window -t "$session_name" -c "$temp_dir"

    # Trigger mksupa --init in window 1 (second window, 0-indexed)
    set_color brblack
    echo "  → Triggering initialization in tmux window..."
    set_color normal
    set -l init_cmd "mksupa --init --commit"
    if test -n "$supabase_version"
        set init_cmd "$init_cmd --supabase=$supabase_version"
    end
    if test -n "$pgflow_version"
        set init_cmd "$init_cmd --pgflow=$pgflow_version"
    end
    tmux send-keys -t "$session_name:1" "$init_cmd" C-m

    # Pretty print information
    echo ""
    set_color green; set_color --bold
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✨ Temp project created successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    set_color normal
    echo ""
    set_color cyan
    echo "  📂 Directory: "
    set_color normal
    set_color brblack
    echo "     $temp_dir"
    set_color normal
    echo ""
    set_color cyan
    echo "  🖥  Session:   "
    set_color normal
    set_color brblack
    echo "     $session_name"
    set_color normal
    echo ""

    # Ask user if should switch to session
    set_color yellow
    read -l -P "Switch to this tmux session? [y/N] " response
    set_color normal

    if test "$response" = "y" -o "$response" = "Y"
        # Check if we're inside tmux
        if test -n "$TMUX"
            # Inside tmux - use switch-client
            tmux switch-client -t "$session_name"
            tmux select-window -t "$session_name:1"
        else
            # Outside tmux - use attach-session
            tmux attach-session -t "$session_name"
            tmux select-window -t "$session_name:1"
        end
    else
        echo ""
        set_color brblack
        if test -n "$TMUX"
            echo "To switch later: tmux switch-client -t \"$session_name\""
        else
            echo "To attach later: tmux attach-session -t \"$session_name\""
        end
        set_color normal
    end
end

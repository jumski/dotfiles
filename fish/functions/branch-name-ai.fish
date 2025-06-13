function branch-name-ai
    # Collect all arguments as query
    set -l query $argv

    # Check if stdin has input
    set -l stdin_input
    if not isatty 0
        set stdin_input (cat)
    end

    # Build the prompt for aichat
    set -l prompt "Generate a concise git branch name based on the following description. Output ONLY the branch name, nothing else. Use kebab-case. Keep it short but descriptive. Start with an appropriate prefix followed by a slash: feat/ for new features, fix/ for bug fixes, chore/ for maintenance tasks, refactor/ for code refactoring, docs/ for documentation, test/ for tests, perf/ for performance improvements, style/ for formatting/style changes, build/ for build system changes, ci/ for CI/CD changes. Example: feat/user-authentication or fix/login-validation. IMPORTANT: If the description mentions other branch names that should be avoided, make sure to generate a completely different name that doesn't resemble those."

    # Combine query and stdin if both exist
    set -l full_input
    if test -n "$query"
        set full_input "$query"
    end
    if test -n "$stdin_input"
        if test -n "$full_input"
            set full_input "$full_input\n\n$stdin_input"
        else
            set full_input "$stdin_input"
        end
    end

    # Check if we have any input
    if test -z "$full_input"
        echo "Error: No input provided" >&2
        return 1
    end
    
    # Call aichat with the model and options
    echo "$full_input" | aichat --model openai:gpt-4.1-nano --prompt "$prompt" --no-stream --code
end

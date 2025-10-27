#!/usr/bin/env fish

# Source the function to test
source /home/jumski/.dotfiles/wt/lib/common.fish

# GitHub SSH URLs
@test "parses GitHub SSH URL with .git" \
    (_wt_parse_repo_url "git@github.com:supabase/smart-office-demo.git" | string join "/") = "supabase/smart-office-demo/smart-office-demo"

@test "parses GitHub SSH URL without .git" \
    (_wt_parse_repo_url "git@github.com:supabase/smart-office-demo" | string join "/") = "supabase/smart-office-demo/smart-office-demo"

@test "extracts correct directory for GitHub SSH" \
    (_wt_parse_repo_url "git@github.com:torvalds/linux.git")[1] = "torvalds/linux"

@test "extracts correct repo name for GitHub SSH" \
    (_wt_parse_repo_url "git@github.com:torvalds/linux.git")[2] = "linux"

# GitHub HTTPS URLs
@test "parses GitHub HTTPS URL with .git" \
    (_wt_parse_repo_url "https://github.com/facebook/react.git" | string join "/") = "facebook/react/react"

@test "parses GitHub HTTPS URL without .git" \
    (_wt_parse_repo_url "https://github.com/facebook/react" | string join "/") = "facebook/react/react"

@test "extracts correct directory for GitHub HTTPS" \
    (_wt_parse_repo_url "https://github.com/microsoft/vscode.git")[1] = "microsoft/vscode"

@test "extracts correct repo name for GitHub HTTPS" \
    (_wt_parse_repo_url "https://github.com/microsoft/vscode.git")[2] = "vscode"

# Short format (org/repo)
@test "parses short format org/repo" \
    (_wt_parse_repo_url "supabase/smart-office-demo" | string join "/") = "supabase/smart-office-demo/smart-office-demo"

@test "extracts correct directory for short format" \
    (_wt_parse_repo_url "rails/rails")[1] = "rails/rails"

@test "extracts correct repo name for short format" \
    (_wt_parse_repo_url "rails/rails")[2] = "rails"

@test "parses org/repo preserving full path" \
    (_wt_parse_repo_url "facebook/react")[1] = "facebook/react"

@test "extracts only repo name from org/repo" \
    (_wt_parse_repo_url "facebook/react")[2] = "react"

@test "handles org/repo with hyphens" \
    (_wt_parse_repo_url "vercel/next.js")[1] = "vercel/next.js"

@test "handles org/repo with dots in name" \
    (_wt_parse_repo_url "vercel/next.js")[2] = "next.js"

# GitLab SSH URLs
@test "parses GitLab SSH URL with .git" \
    (_wt_parse_repo_url "git@gitlab.com:org/project.git" | string join "/") = "org/project/project"

@test "parses GitLab SSH URL without .git" \
    (_wt_parse_repo_url "git@gitlab.com:org/project" | string join "/") = "org/project/project"

@test "parses GitLab SSH URL with nested path" \
    (_wt_parse_repo_url "git@gitlab.com:group/subgroup/project.git")[1] = "group/subgroup/project"

@test "extracts repo name from nested GitLab path" \
    (_wt_parse_repo_url "git@gitlab.com:group/subgroup/project.git")[2] = "project"

# GitLab HTTPS URLs
@test "parses GitLab HTTPS URL with .git" \
    (_wt_parse_repo_url "https://gitlab.com/org/project.git" | string join "/") = "org/project/project"

@test "parses GitLab HTTPS URL without .git" \
    (_wt_parse_repo_url "https://gitlab.com/org/project" | string join "/") = "org/project/project"

@test "parses GitLab HTTPS URL with nested path" \
    (_wt_parse_repo_url "https://gitlab.com/group/subgroup/project.git")[1] = "group/subgroup/project"

# Generic/fallback URLs
@test "parses generic URL with .git" \
    (_wt_parse_repo_url "https://example.com/some-repo.git" | string join "/") = "some-repo/some-repo"

@test "parses generic URL without .git" \
    (_wt_parse_repo_url "https://example.com/some-repo" | string join "/") = "some-repo/some-repo"

@test "parses bare repo name" \
    (_wt_parse_repo_url "my-project" | string join "/") = "my-project/my-project"

# Edge cases
@test "handles URL with hyphenated org name" \
    (_wt_parse_repo_url "git@github.com:my-org/my-repo.git")[1] = "my-org/my-repo"

@test "handles URL with underscore in repo name" \
    (_wt_parse_repo_url "git@github.com:org/my_repo.git")[2] = "my_repo"

@test "handles URL with numbers" \
    (_wt_parse_repo_url "git@github.com:user123/repo456.git")[1] = "user123/repo456"

# Error handling
@test "returns error for empty input" \
    (_wt_parse_repo_url ""; echo $status) -eq 1
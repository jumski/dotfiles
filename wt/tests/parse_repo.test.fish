#!/usr/bin/env fish

# Tests for _wt_parse_repo_url function

# Source the wt-common functions
source /home/jumski/.dotfiles/wt/functions/wt-common.fish

@test "parse GitHub SSH URL with .git" \
    (_wt_parse_repo_url "git@github.com:supabase/smart-office-demo.git")[2] = "smart-office-demo"

@test "parse GitHub SSH URL without .git" \
    (_wt_parse_repo_url "git@github.com:supabase/smart-office-demo")[2] = "smart-office-demo"

@test "parse GitHub HTTPS URL with .git" \
    (_wt_parse_repo_url "https://github.com/torvalds/linux.git")[2] = "linux"

@test "parse GitHub HTTPS URL without .git" \
    (_wt_parse_repo_url "https://github.com/torvalds/linux")[2] = "linux"

@test "parse org/repo shorthand format" \
    (_wt_parse_repo_url "supabase/smart-office-demo")[2] = "smart-office-demo"

@test "parse GitLab SSH URL" \
    (_wt_parse_repo_url "git@gitlab.com:org/project.git")[2] = "project"

@test "parse GitLab HTTPS URL with nested groups" \
    (_wt_parse_repo_url "https://gitlab.com/org/nested/project.git")[2] = "project"

@test "parse generic git URL" \
    (_wt_parse_repo_url "https://example.com/some-repo.git")[2] = "some-repo"

@test "fail on empty URL" \
    (_wt_parse_repo_url ""; echo $status) -eq 1

@test "extract directory structure for GitHub SSH" \
    (_wt_parse_repo_url "git@github.com:supabase/smart-office-demo.git")[1] = "supabase/smart-office-demo"

@test "extract directory structure for org/repo format" \
    (_wt_parse_repo_url "supabase/smart-office-demo")[1] = "supabase/smart-office-demo"
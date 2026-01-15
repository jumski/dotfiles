#!/usr/bin/env fish

# Source the lib to test
source /home/jumski/.dotfiles/hive/lib/common.fish

# _hive_get_session_name tests
@test "session name from .dotfiles path" \
    (_hive_get_session_name "/home/jumski/.dotfiles") = "dotfiles"

@test "session name from worktree path" \
    (_hive_get_session_name "/home/jumski/Code/org/pgflow/worktrees/feat-auth") = "pgflow"

@test "session name from regular repo" \
    (_hive_get_session_name "/home/jumski/Code/org/myrepo") = "myrepo"

@test "session name requires path" \
    (_hive_get_session_name; echo $status) -eq 1

# _hive_get_window_name tests
@test "window name from .dotfiles path" \
    (_hive_get_window_name "/home/jumski/.dotfiles") = "dotfiles"

@test "window name from worktree path" \
    (_hive_get_window_name "/home/jumski/Code/org/pgflow/worktrees/feat-auth") = "feat-auth"

@test "window name from regular repo uses dirname" \
    (_hive_get_window_name "/home/jumski/Code/org/myrepo") = "myrepo"

@test "window name requires path" \
    (_hive_get_window_name; echo $status) -eq 1

# _hive_resolve_path tests
@test "resolve .dotfiles path" \
    (_hive_resolve_path ".dotfiles") = "/home/jumski/.dotfiles"

@test "resolve Code project path" \
    (_hive_resolve_path "org/repo") = "/home/jumski/Code/org/repo"

@test "resolve worktree path" \
    (_hive_resolve_path "org/pgflow/worktrees/main") = "/home/jumski/Code/org/pgflow/worktrees/main"

# _hive_next_window_name tests
# Note: These tests only cover the no-session case since _hive_window_exists
# requires tmux to be running and cannot be easily mocked in subshell
@test "next window name with no session returns base" \
    (_hive_next_window_name "" "test") = "test"

# The following tests would require mocking _hive_window_exists which depends on tmux
# They are tested manually in the spawn wizard workflow

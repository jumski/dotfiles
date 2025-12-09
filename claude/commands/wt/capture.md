---
description: Capture current branch to worktree with this Claude session
---

Capture the current branch to its own worktree and migrate this Claude session.

By invoking this command, the current session becomes the most recent and will be automatically selected for migration.

## Steps

1. Get the current session ID by finding the most recent .jsonl file in this project's Claude directory
2. Show the user what will happen
3. Run the capture command with the session ID

## Execute

Run this command to capture the branch and migrate the session:

```bash
fish -c "source ~/.dotfiles/wt/lib/common.fish && source ~/.dotfiles/wt/functions/wt_capture.fish && wt_capture --switch --yes"
```

After the command completes:
- The old worktree (main) will be back on the trunk branch with a fresh Claude session
- The new worktree will have this conversation resumed
- You'll be switched to the new tmux session

**Important**: After running the command, this Claude instance will be replaced. Continue the conversation in the new tmux session's window 4.

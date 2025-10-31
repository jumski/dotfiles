---
description: Generate unique emoji-prefixed tmux window name based on conversation context
allowed-tools: Bash(tmux:*), Bash(xargs:*)
---

# Rename Tmux Window

Analyze the current conversation context and any optional arguments provided by the user, then generate a unique, emoji-prefixed tmux window name.

## Target Window (captured at command invocation)

```bash
!`echo "TARGET_SESSION=$(tmux display-message -p '#S')"; echo "TARGET_WINDOW=$(tmux display-message -p '#I')"`
```

## Current Tmux Sessions and Windows

```bash
!`tmux list-sessions -F '#{session_name}' 2>/dev/null | xargs -I {} tmux list-windows -t {} -F 'Session: #{session_name} | Window: #{window_name}'`
```

## Instructions

1. **Review Context**
   - Analyze conversation history to understand the current task/topic
   - Consider any user-provided arguments or preferences
   - Check existing window names from the list above to ensure uniqueness

2. **Generate Emoji Prefix**
   - Choose an emoji that represents the FEATURE, BUG, or PROBLEM being worked on (not the action)
   - Must be unique within the current tmux session (can repeat across sessions)
   - The emoji should visually represent what you're working with, not what you're doing
   - Examples: 🐟 for fish shell, 🔐 for auth, 📚 for docs, 🐛 for a bug, 🖥️ for tmux, 🎯 for targets/goals, ⚙️ for system config

3. **Generate Name**
   - Maximum 15 characters (emoji does NOT count toward this limit)
   - Use lowercase with hyphens for word separation
   - Must be unique within the current session
   - Be SPECIFIC and DESCRIPTIVE - use the full character budget
   - Include context: what part/aspect of the feature you're working on
   - Example: If working on Claude commands, use "claude-cmd-tmux" not just "claude-cmd"
   - NO SPACE between emoji and name

4. **Execute Rename**
   Use the captured TARGET_SESSION and TARGET_WINDOW variables to rename the correct window:
   ```bash
   tmux rename-window -t "${TARGET_SESSION}:${TARGET_WINDOW}" "emoji-name-here"
   ```

## Example names
- `🐟fish-fns-tests`
- `🔐auth-jwt-impl`
- `📚docs-api-ref`
- `🖥️tmux-rename-cmd`
- `⚡claude-cmd-tmux`
- `🐛parser-null-fix`
- `🎯wt-switch-perf`

After generating the name, confirm the rename was successful and explain your emoji choice.

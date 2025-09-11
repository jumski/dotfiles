# Worktree Toolkit (wt) - Colorful Step Indicators

## Visual Step Indicators

The Worktree Toolkit uses colorful step indicators to help users distinguish between workflow steps and actual command output. This makes it easier to follow the process and understand what's happening.

### Color Scheme

- **Blue arrows (`→`)** - Steps in progress or actions being taken
- **Green checkmarks (`✓`)** - Completed steps or success messages
- **Normal text** - Command output, warnings, and user prompts

### Implementation

Use ANSI escape codes in echo statements:

```fish
# Step in progress (blue arrow)
echo -e "\033[34m→\033[0m Step description..."

# Success/completion (green checkmark)  
echo -e "\033[32m✓\033[0m Success message"

# Reset to normal color
echo -e "\033[0m Normal text"
```

### ANSI Color Codes Used

- `\033[34m` - Blue color
- `\033[32m` - Green color  
- `\033[0m` - Reset to normal/default color

### Example Implementation

```fish
function example_command
    echo -e "\033[34m→\033[0m Checking dependencies..."
    # ... actual command here ...
    
    echo -e "\033[34m→\033[0m Creating files..."
    # ... file creation logic ...
    
    echo -e "\033[32m✓\033[0m Operation completed successfully"
end
```

### When to Apply

Apply this pattern to commands that have multiple distinct steps, such as:
- `wt new` - Has steps for checking remotes, creating worktree, initializing tools
- `wt init` - Has steps for cloning, creating structure, setting up config
- `wt remove` - Has steps for validation, cleanup, session management

### Benefits

1. **Clear workflow visibility** - Users can see what step is currently running
2. **Output separation** - Distinguishes toolkit messages from underlying command output
3. **Progress indication** - Shows completion status with green checkmarks
4. **Professional appearance** - Clean, modern CLI experience

### Guidelines

- Use sparingly - only for major workflow steps
- Keep descriptions concise and action-oriented
- Always reset color after colored text
- Don't colorize error messages (let them use default error styling)
- Use blue for "doing" and green for "done"
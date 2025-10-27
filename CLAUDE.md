# Claude Assistant Context

Dotfiles repository guidelines.

## Stack
- **Fish shell** + **Fisher** package manager
- **Dotbot** for symlinks
- **Fishtape** for testing

## Structure
```
module/
├── install.sh      # installer
├── *.fish          # config files
├── functions/      # fish functions
├── tests/          # test files
│   └── *.test.fish
```

## Conventions
- Each tool gets its own directory
- `script/install` runs all installers
- `script/test` runs all tests
- Fish loads all `*.fish` except: `config.fish`, `_path.fish`, `.test.fish`
- Tests in `module/tests/*.test.fish`

## Testing

```fish
script/test         # run all
script/test wt      # run module
fishtape-watch      # watch mode
```

Write tests with `@test` syntax - see [TESTING.md](./TESTING.md)

## Key Modules

### Fish
- Config: `fish/config.fish`
- Packages: `fish/fishfile`
- Functions: `fish/functions/`

### Worktree Toolkit (wt)
Git worktree management with tmux integration:
- `wt-create`, `wt-switch`, `wt-remove`, `wt-list`

## Development

1. Follow existing patterns
2. Add tests for new functions
3. Run `script/test` before finalizing
4. Update docs if needed

## Tmux Window Management
- **Auto-rename windows**: After 3-5 message exchanges when conversation topic is clear, automatically run `/tmux:rename-window`
- Only rename once per conversation unless explicitly requested again
- Generate emoji-prefixed, descriptive names (emoji + max 15 chars)
- Emoji represents the feature/problem being worked on, not the action
- Name should be unique within the session and use full character budget
- Be specific: include context like "claude-cmd-tmux" not just "claude-cmd"

## Research and Documentation

When you need to search for information or documentation:
- **Prefer Perplexity Search** for current best practices, tool comparisons, and research
- **Use Context7 MCP** for library/framework documentation (Fish, Tmux, Git, etc.)
- **Avoid WebSearch/WebFetch** unless other tools fail
- See `.claude/core/finding_answers.md` for detailed tool selection guidance

## Notes
- `.test.fish` excluded from shell startup
- Source functions before testing them
- Respect modular structure
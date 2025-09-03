# mise in dotfiles

This directory contains configuration for [mise](https://mise.jdx.dev/) - a development environment tool that manages versions of languages, runtimes, and tools.

## Overview

mise is an alternative to asdf that provides:
- Faster performance (no shims)
- Better environment variable management
- Built-in task runner
- Single binary installation
- Native direnv replacement

## Common Usage

### Basic Commands

```bash
# List installed tools
mise ls

# List available versions for a tool
mise ls-remote node

# Install a specific version
mise install node@20.18.1

# Set a tool version for current project
mise use node@20.18.1

# Set a global tool version
mise use -g node@20.18.1

# Run a command with specific tool versions
mise exec -- node --version

# Run a task defined in mise.toml
mise run build
```

### Project Setup

Create a `mise.toml` file in your project root:

```toml
[tools]
node = "20.18.1"
python = "3.11.3"
```

### Environment Variables

```toml
[env]
NODE_ENV = "development"
DATABASE_URL = "postgresql://localhost:5432/myapp"
```

## Cheatsheet

### Core Commands
| Command | Description |
|---------|-------------|
| `mise ls` | List installed tools |
| `mise use <tool>@<version>` | Set tool version |
| `mise install <tool>@<version>` | Install tool version |
| `mise exec -- <command>` | Run command with tools |
| `mise activate` | Activate mise in current shell |

### Environment Management
| Command | Description |
|---------|-------------|
| `mise env` | Show environment variables |
| `mise shell <tool>@<version>` | Set tool for current shell |
| `mise set <key>=<value>` | Set environment variable |
| `mise unset <key>` | Unset environment variable |

### Task Runner
| Command | Description |
|---------|-------------|
| `mise run <task>` | Run a task |
| `mise tasks` | List available tasks |
| `mise run //all` | Run all tasks in parallel |

## Using mise vs asdf+direnv

### Current asdf+direnv Setup
Your current setup uses:
- **asdf** for tool version management
- **direnv** for automatic environment loading
- **.tool-versions** files for tool definitions
- **.envrc** files for direnv integration

### Benefits of mise

1. **No External Dependencies**: Unlike asdf+direnv which requires two separate tools, mise is a single binary
2. **Better Performance**: No shims or direnv overhead
3. **Built-in Environment Management**: No need for separate .envrc files
4. **Enhanced Features**: Task runner, better configuration options

### Migration Strategy

#### Option 1: Gradual Migration (Recommended)
1. Keep asdf+direnv for existing projects
2. Use mise for new projects
3. Gradually migrate projects as needed

#### Option 2: Parallel Usage
1. Use asdf+direnv in directories without `mise.toml`
2. Use mise automatically in directories with `mise.toml`
3. No configuration changes needed

#### Option 3: Full Replacement
1. Convert all `.tool-versions` to `mise.toml`
2. Remove direnv integration
3. Use `mise activate` for shell integration

### Configuration Files

**asdf approach:**
```
.tool-versions    # Tool versions
.envrc           # Environment loading
```

**mise approach:**
```
mise.toml        # Tool versions + environment
.config/mise/config.toml  # Global configuration
```

### Shell Integration

**Current asdf integration** (`asdf/init.fish`):
```fish
set PATH $PATH $HOME/.asdf/bin
source $HOME/.asdf/completions/asdf.fish
```

**mise integration** (`mise/init.fish`):
```fish
# Add mise to PATH
set -gx PATH $HOME/.local/share/mise/bin $PATH
# Load completions
source $HOME/.local/share/mise/completions/mise.fish
```

## Practical Examples

### Example 1: Node.js Project

**Old way (asdf):**
```bash
# .tool-versions
nodejs 20.18.1

# .envrc
use asdf
export NODE_ENV=development
```

**New way (mise):**
```toml
# mise.toml
[tools]
node = "20.18.1"

[env]
NODE_ENV = "development"
```

### Example 2: Python Project with Environment Variables

**Old way (asdf):**
```bash
# .tool-versions
python 3.11.3

# .envrc
use asdf
dotenv_if_exists .env
```

**New way (mise):**
```toml
# mise.toml
[tools]
python = "3.11.3"

[env]
_.file = ".env"
```

### Example 3: Multi-tool Project with Tasks

**New mise-only approach:**
```toml
# mise.toml
[tools]
node = "20.18.1"
python = "3.11.3"
rust = "latest"

[env]
DATABASE_URL = "postgresql://localhost:5432/myapp"

[tasks.build]
run = "npm run build"

[tasks.test]
run = [
  "npm run test",
  "python -m pytest"
]

[tasks.dev]
run = "npm run dev"
```

Run with: `mise run dev`

## Aliases

Common aliases defined in `aliases.fish`:

```fish
alias m="mise"
alias mu="mise use"
alias mi="mise install"
alias ml="mise ls"
alias mlt="mise ls-remote"
alias mau="mise activate"
alias msh="mise shell"
alias menv="mise env"
alias mexec="mise exec"
alias mx="mise x"
```

## Best Practices

1. **Use `mise.toml` for new projects** instead of `.tool-versions`
2. **Define environment variables in mise.toml** instead of separate .envrc files
3. **Use mise tasks** for common project commands
4. **Set global defaults** in `~/.config/mise/config.toml`
5. **Use `mise activate`** for shell integration instead of direnv

## Troubleshooting

### Common Issues

1. **Tool not found**: Run `mise install` to install missing tools
2. **Wrong version active**: Check for conflicting `mise.toml` files
3. **Environment variables not loading**: Ensure `mise activate` is run or shell integration is configured

### Debugging

```bash
# Show current environment
mise env

# Show active tools
mise ls

# Debug activation
mise activate --no-hook-env

# Check configuration
mise config ls
```

## Coexistence with asdf

This setup allows mise to coexist with asdf because:
- They use different binaries (`mise` vs `asdf`)
- They use different configuration files (`mise.toml` vs `.tool-versions`)
- They can be activated independently
- No automatic conflicts since they use different PATH management

You can use both in the same system and choose which to use per project.
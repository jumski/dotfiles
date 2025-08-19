# mise aliases
# These aliases provide quick access to mise commands

# Core mise commands
alias m="mise"
alias mu="mise use"
alias mi="mise install"
alias ml="mise ls"
alias mlt="mise ls-remote"
alias mau="mise activate"

# Tool-specific aliases (only if not conflicting with asdf)
alias mnode="mise x node"
alias mpython="mise x python"
alias mruby="mise x ruby"

# Environment management
alias msh="mise shell"
alias menv="mise env"
alias mexec="mise exec"
alias mx="mise x"

# Plugin management
alias mpa="mise plugins add"
alias mpl="mise plugins ls"
alias mpil="mise plugins install"
alias mpul="mise plugins uninstall"

# Task running
alias mr="mise run"
alias mrt="mise run task"

# Settings
alias mset="mise settings set"
alias mget="mise settings get"
alias msl="mise settings ls"
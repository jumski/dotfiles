
# add support for ctrl+o to open selected file in Vim
set -x FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(vim {})+abort'"

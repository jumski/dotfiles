
# add support for ctrl+o to open selected file in Vim
set -U FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(vim {})+abort'"

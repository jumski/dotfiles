# Codi
# Usage: codi [filetype] [filename]
function codi
  set -gx syntax (or $argv[1] | "python")

  fish -s shift
  vim -c \
    "let g:startify_disable_at_vimenter = 1 |\
    set bt=nofile ls=0 noru nonu nornu |\
    hi ColorColumn ctermbg=NONE |\
    hi VertSplit ctermbg=NONE |\
    hi NonText ctermfg=0 |\
    Codi $syntax" "$argv"
end

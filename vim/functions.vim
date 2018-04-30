
" populate the :args list with the filenames currently in the quickfix window
command! -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction

fu! OpenGitlabForCurrentFile()
  :!glbrowse %
endfunction
command! -bar Glbrowse call OpenGitlabForCurrentFile()
nnoremap <leader>og :Glbrowse<cr>

command Til :tabe ~/dotfiles/TIL.md

function! Browser ()
  let line = getline(".")
  let line = matchstr(line, "\%(http://\|www\.\)[^ ,;\t]*")
  exec "!google-chrome ".line
endfunction
map gX :call Browser()<CR>

" custom functions
fu! WriteCursorLastPosition()
  let output = system('echo ' . getreg('%') . ':' . line('.') . ' > .cursor_last_position')
endfunction
"
if !exists("b:jumski_write_rspec_guide")
  let b:jumski_write_rspec_guide = 1

  au BufWritePost *_spec.rb call WriteCursorLastPosition()
endif


augroup breakage
    " autocmd!
    "
    " autocmd BufReadPost *.clj nmap <silent> :norm <C-a> <C-a>mxcpp'x
    " autocmd BufReadPost *.clj nmap <silent> :norm <C-x> <C-x>mxcpp'x
    " autocmd BufReadPost *.clj nmap <silent> :norm cpp mxcpp'x
    "
    " " <Plug>(sexp_swap_element_forward)
    " " autocmd BufReadPost *.clj nmap <C-right> <Plug>(sexp_swap_element_forward)cppg,
    " " autocmd BufReadPost *.clj nmap <C-left> <Plug>(sexp_swap_element_backward)cppg,
    " " autocmd BufReadPost *.clj nmap <C-right> >ecppg,
    " " autocmd BufReadPost *.clj nmap <C-left> <ecppg,
    " autocmd BufReadPost *.clj nmap <silent> >e <Plug>(sexp_swap_element_forward)cppg,
    " autocmd BufReadPost *.clj nmap <silent> <e  <Plug>(sexp_swap_element_backward)cppg,
    "
    "
    "
    "
    " autocmd BufReadPost *.clj nmap cPP mxcpaF'x
    " autocmd BufReadPost *.clj nmap <C-p> mxcpaF'x
augroup END

function! BreakageMappingsOn()
    " inc/dec, eval form and go back to the number
    nmap <buffer> :norm <C-a> <C-a>mxcpp'x
    nmap <buffer> :norm <C-x> <C-x>mxcpp'x
    nmap <buffer> :norm cpp mxcpp'x

    " move element and eval, going back to element
    nmap <buffer> >e <Plug>(sexp_swap_element_forward)cppg,
    nmap <buffer> <e  <Plug>(sexp_swap_element_backward)cppg,

    " eval top-level form and go back
    nmap <buffer> cPP mxcpaF'x
    nmap <buffer> <C-p> mxcpaF'x
endfunction

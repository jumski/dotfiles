set updatetime=4000
let g:boostmove=0
au CursorMoved * call BoostMoveON()
au CursorMovedI * call BoostMoveON()
au CursorHold * call BoostMoveOFF()
au CursorHoldI * call BoostMoveOFF()
function BoostMoveON()
    if (g:boostmove == 0)
        set updatetime=10
        let g:boostmove=1
        setlocal syntax=off
    endif
endfunction
function BoostMoveOFF()
    if g:boostmove==1
        set updatetime=4000
        let g:boostmove=0
        setlocal syntax=on
    endif
endfunction

" Vim script to show file differences from a base version in SCM.
" Home: http://github.com/ghewgill/vim-scmdiff

" Default commands:
"   \d      Toggle diff view on/off
"   :D rev  Difference between current and rev
"
" You can change the highlighting by adding the following to your 
" .vimrc file and customizing as necessary.  (or just uncomment them here):
"   highlight DiffAdd ctermbg=DarkBlue ctermfg=white cterm=NONE
"   highlight DiffChange ctermbg=DarkBlue ctermfg=white cterm=NONE
"   highlight DiffText ctermbg=DarkBlue ctermfg=white cterm=underline
"   highlight DiffDelete ctermbg=red ctermfg=white

if exists("loadedScmDiff") || &cp
    finish
endif

let loadedScmDiff = 1

map <silent> <Leader>d :call <SID>scmToggle()<CR>
noremap <unique> <script> <plug>Dh :call <SID>scmDiff("h")<CR>
com! -bar -nargs=? D :call s:scmDiff(<f-args>)

let g:scmDiffRev = ''

function! s:scmToggle()

    if exists('b:scmDiffOn') && b:scmDiffOn == 1
        call s:scmDiffOff()
    else
        call s:scmDiff()
    endif

endfunction

function! s:scmRefresh()

    if exists('b:scmDiffOn') && b:scmDiffOn == 1
        call s:scmDiff()
    endif

endfunction

function! s:scmDiffOff()
    let b:scmDiffOn = 0
    set nodiff foldcolumn=0
    exe 'bdelete ' . b:scmDiffTmpfile
endfunction

function! s:scmDiff(...)

    if exists('b:scmDiffOn') && b:scmDiffOn == 1
        call s:scmDiffOff()
    endif

    let b:scmDiffOn = 1

    if a:0 == 1
        if a:1 == 'none'
            let g:scmDiffRev = ''
        else
            let g:scmDiffRev = a:1
            if (match(g:scmDiffCommand, 'darcs'))
                g:scmDiffRev = '--from-patch=' . g:scmDiffRev
            endif
        endif
    endif

    let ftype = &filetype
    let b:scmDiffTmpfile = tempname()
    let cmd = 'cd ./' . expand('%:h') . ' && git show HEAD:./' . expand('%:t') . ' > ' . b:scmDiffTmpfile
    let cmdOutput = system(cmd)

    if v:shell_error && cmdOutput != ''
        echohl WarningMsg | echon cmdOutput | echohl None
        return
    endif

    exe 'rightbelow vert diffsplit' . b:scmDiffTmpfile

    exe 'set filetype=' . ftype

    set foldcolumn=0
    set foldlevel=100
    set readonly
    winc h
    set foldcolumn=0


endfunction


" vim>600: expandtab sw=4 ts=4 sts=4 fdm=marker
" vim<600: expandtab sw=4 ts=4 sts=4

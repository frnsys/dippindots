" Quickfix config

" Press q to close the quickfix list.
nnoremap <silent> <buffer> q :quit<cr>

" When opening a quickfist list file
" keep the cursor in the quickfix list.
nnoremap <silent> <buffer> o <CR><C-w>p
nnoremap <silent> <buffer> <cr> <CR><C-w>p

" auto-close quickfix window if it's the only one left
" this makes it easier to :q quit with a file has e.g. syntactic errors
autocmd WinEnter * if &buftype ==# 'quickfix' && winnr('$') == 1 | quit | endif

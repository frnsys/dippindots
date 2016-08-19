" NERDComment toggle to Ctrl+x
:vmap <silent> <C-x> :call NERDComment(0,"toggle")<CR>
:nmap <silent> <C-x> :call NERDComment(0,"toggle")<CR>

let g:NERDCustomDelimiters = {
    \ 'julia': { 'left': '#'},
\ }

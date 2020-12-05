let g:racer_cmd = "/home/ftseng/.cargo/bin/racer"
let g:racer_experimental_completer = 1
augroup Racer
    autocmd!
    autocmd FileType rust nmap <buffer> gd         <Plug>(rust-doc)
    autocmd FileType rust nmap <buffer> <leader>gd <Plug>(rust-def)
    autocmd FileType rust nmap <buffer> <leader>gs <Plug>(rust-def-split)
    autocmd FileType rust nmap <buffer> <leader>gx <Plug>(rust-def-vertical)
    autocmd FileType rust nmap <buffer> <leader>gt <Plug>(rust-def-tab)
augroup END

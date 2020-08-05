command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg -Tcsv --smart-case --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
nnoremap <C-c> :Rg 

nnoremap <C-b> :Buffers<cr>
nnoremap <C-p> :Files .<cr>
nnoremap <C-l> :Lines<cr>

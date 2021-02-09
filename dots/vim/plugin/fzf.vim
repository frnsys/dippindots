" Args
"   - Ripgrep command
"   - Has column (set to 1 if `--column` is used)
"   - File preview
"   - Fullscreen
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg -Tcsv --smart-case --column --line-number --no-heading --color=always '.shellescape(<q-args>),
  \   1,
  \   fzf#vim#with_preview('up:60%'),
  \   1)
nnoremap <C-c> :Rg 

" Search for word under cursor
nnoremap <silent> <Leader>g :Rg <C-R><C-W><CR>

command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview('up:60%'), 1)
command! -bang -nargs=? -complete=dir Buffers call fzf#vim#buffers(fzf#vim#with_preview('up:60%'), 1)
command! -bang -nargs=? -complete=dir Notes call fzf#vim#files('~/notes', fzf#vim#with_preview('up:60%'), 1)

nnoremap <C-b> :Buffers<cr>
nnoremap <C-p> :Files .<cr>
nnoremap <C-l> :Lines<cr>
nnoremap <C-n> :Notes<cr>

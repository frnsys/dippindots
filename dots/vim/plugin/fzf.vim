" let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }

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
" command! -bang -nargs=? -complete=dir Notes call fzf#vim#files('~/notes', fzf#vim#with_preview('up:60%'), 1)

nnoremap <C-b> :Buffers<cr>
nnoremap <C-p> :Files .<cr>
nnoremap <C-l> :Lines<cr>
" nnoremap <C-n> :Notes<cr>

" Table of Contents (for markdown files, see binding below)
" Jump to line match from ripgrep
" Expects that the line is delimited with ':'
" and the first field is the line number.
function! s:line_handler(line)
    let keys = split(a:line, ':')
    execute "normal! " . keys[0] . "gg"
endfunction

" Args
" - Source: user ripgrep to search for one or more '#' at the start of a line
"   in the current file
" - Sink: use the line hanlder function above to jump to the selected line
" - Options:
"   - reverse output
"   - split on ':' and take all fields from the 2nd on
"   (i.e. skip the line number)
command! -bang -complete=dir -nargs=? TOC
    \ call fzf#run(fzf#wrap('toc', {
        \'source': 'rg -Tcsv --line-number --no-heading "^#+" '.expand('%:p'),
        \'sink': function('s:line_handler'),
        \'options': '--reverse --delimiter=: --with-nth=2..'
    \}, <bang>0))

nnoremap <C-n> :TOC<cr>

" File path completion with tab
imap <c-s> <plug>(fzf-complete-path)

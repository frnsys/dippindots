let g:unite_enable_start_insert = 1
let g:unite_split_rule = "botright"
let g:unite_force_overwrite_statusline = 0
let g:unite_winheight = 10

if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nocolor --nogroup --hidden --ignore-case --ignore tags'
    let g:unite_source_grep_recursive_opt = ''
endif

call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
      \ 'ignore_pattern', join([
      \ '\.git/',
      \ '\.hg/',
      \ '\.svn/',
      \ '\.pyc',
      \ '\.pyo',
      \ '\.meta',
      \ '\.asset',
      \ '\.prefab',
      \ '\.dll',
      \ '\.png',
      \ '\.json',
      \ 'node_modules/',
      \ ], '\|'))

call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])

" Ctrlp replacement
nnoremap <C-p> :<C-u>Unite -buffer-name=files -start-insert -force-redraw buffer file_rec/async:! -auto-resize -marked-icon="~>"<cr>

" Content searching
nnoremap <C-c> :Unite grep:.<cr>

" Better searching in file
nnoremap <C-l> :Unite line<cr>

" Cycle through results from previous search
nnoremap <Leader>m :UniteNext<cr>
nnoremap <Leader>n :UnitePrevious<cr>


" Yank history
let g:unite_source_history_yank_enable = 1
nnoremap <C-y> :Unite history/yank<cr>

autocmd FileType unite call s:unite_settings()

function! s:unite_settings()
  let b:SuperTabDisabled=1
  " Navigation in the Unite buffer.
  imap <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
  imap <silent><buffer><expr> <C-x> unite#do_action('split')
  imap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  imap <silent><buffer><expr> <C-t> unite#do_action('tabopen')

  nmap <buffer> <ESC> <Plug>(unite_exit)
endfunction

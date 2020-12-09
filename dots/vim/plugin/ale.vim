" show list of errors
" let g:ale_open_list = 1
" let g:ale_list_window_size = 3

" don't lint after every text change,
" just after we leave insert mode
let g:ale_lint_on_text_changed = 'normal' " always, insert, normal, never
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 0

let g:ale_rust_analyzer_config = {
  \'rust-analyzer.diagnostics.disabled': ['unresolved-import']
\}
let g:ale_linters = {
  \'python': ['pyflakes'],
  \'javascript': [],
  \'rust': ['analyzer']
\}

" gutter sign config
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '>>'
hi ALEErrorSign ctermbg=none ctermfg=196
hi ALEWarningSign ctermbg=none ctermfg=3

" navigate between errors
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" use ale for omnicompletion
set omnifunc=ale#completion#OmniFunc

" go to documentation
" Opens the docs or source preview window
" Use <c-w>z to close it
nmap gd <Plug>(ale_hover)

" go to definition
" <C-o> jumps back after going to defintion
nmap <c-g> <Plug>(ale_go_to_definition)

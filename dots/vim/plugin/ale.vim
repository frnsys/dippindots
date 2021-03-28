" show list of errors
" let g:ale_open_list = 1
" let g:ale_list_window_size = 3

" need neovim for this
let g:ale_cursor_detail = 1
let g:ale_floating_preview = 1
" let g:ale_virtualtext_cursor = 1 " doesn't work?

" don't lint after every text change,
" lint only on save and
" when opening a file
let g:ale_lint_on_text_changed = 'never' " always, insert, normal, never
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 1

" diagnostics giving a lot of headache, so disabling for now,
" but later can replace with these lines:
" 'diagnostics': { 'disabled': ['unresolved-import'] },
" 'procMacro': { 'enable': v:true },
let g:ale_rust_analyzer_config = {
  \ 'diagnostics': { 'enable': v:false },
  \ 'cargo': { 'loadOutDirsFromCheck': v:true },
  \ 'checkOnSave': { 'command': 'clippy', 'enable': v:true }
\ }
let g:ale_linters = {
  \'python': ['pyflakes'],
  \'javascript': ['tsserver'],
  \'rust': ['analyzer']
\}

" gutter sign config
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '>>'
hi ALEErrorSign ctermbg=none ctermfg=196
hi ALEWarningSign ctermbg=none ctermfg=3

" navigate between errors
" press enter to view error details
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
nmap <silent> <leader>m <Plug>(ale_detail)

" use ale for omnicompletion
set omnifunc=ale#completion#OmniFunc

" go to documentation
" Opens the docs or source preview window
" Use <c-w>z to close it
nmap <c-g> <Plug>(ale_hover)

" go to definition
" <C-o> jumps back after going to defintion
nmap gd <Plug>(ale_go_to_definition)

" Use the ruler to indicate linting status
augroup ALEProgress
    autocmd!
    autocmd User ALELintPre  set rulerformat=%l,%c:%P%=🔸
    autocmd User ALELintPost set rulerformat=%l,%c:%P
augroup END

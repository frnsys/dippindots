" show list of errors
let g:ale_open_list = 1
let g:ale_list_window_size = 3

" don't lint after every text change,
" just after we leave insert mode
let g:ale_lint_on_text_changed = 'normal' " always, insert, normal, never
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 0

let g:ale_linters = {
  \'python': ['pyflakes'],
\}

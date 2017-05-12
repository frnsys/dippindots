" don't override my existing syntax highlighting
let g:pymode_syntax = 0

" auto-check for venv
let g:pymode_virtualenv = 1

" disable rope
let g:pymode_rope = 0

" disable linting, it is not well updated
" using syntastic instead
let g:pymode_lint = 0

" disable pymode folding, it conflicts with neocomplete
let g:pymode_folding = 0

" hide the color column
let g:pymode_options_colorcolumn = 0

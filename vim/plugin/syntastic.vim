" show signs in the gutter
let g:syntastic_enable_signs = 1

" check errors when file is openedlet g:syntastic_check_on_open = 1
let g:syntastic_check_on_open = 1

" show errors when detected
let g:syntastic_auto_loc_list = 1
let g:syntastic_loc_list_height = 5

" use python 3.5 syntax checking
let g:syntastic_python_python_exec = 'python3.5'
let g:syntastic_python_checkers = ['pyflakes']

" let g:syntastic_rust_checkers = ['rustc']

let g:syntastic_quiet_messages = {'level': 'warnings'}

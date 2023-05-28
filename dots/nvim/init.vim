" Has to be defined first
let mapleader=";"

lua require('plugins')
lua require('verses')

" navigation
set number            			" Show line numbers
set nostartofline 				" Don't reset cursor to start of line when moving
set cursorline 				    " Highlight current line
set scrolloff=3 				" Start scrolling three lines before border
set showmatch 					" Show matching brackets
let &showbreak='↳ '             " Show this at the start of wrapped lines
set laststatus=0                " Never show the status bar
set relativenumber 			    " Use relative line numbering

" whitespace
set wrap                          " Wrap lines
set tabstop=4                     " Set tab spaces
set shiftwidth=4                  " Set autoindent (with <<) spaces
set expandtab                     " Use spaces, not tabs
set list                          " Show invisible characters
set smartindent
set autoindent
set backspace=indent,eol,start    " Backspace through everything in insert mode

" search
set incsearch   " Search as pattern is typed
set ignorecase  " Case insensitive searches...
set smartcase   " Unless they contain 1+ capital letters
set hlsearch    " Highlight search matches
set gdefault 	" Global search/replace by default

" misc config
set conceallevel=1
set noerrorbells 				" Disable error bells
set novisualbell                " Disable visual bells
set showmode 					" Show the current mode
set showcmd 					" Show the command as it's typed
set shortmess=atI 				" Hide Vim intro message
set wrap                        " Wrap long lines
set hidden
set textwidth=0 wrapmargin=0 formatoptions=cq
set display+=lastline
set updatetime=750
set switchbuf+=usetab
set clipboard^=unnamed,unnamedplus " Use OS clipboard
set completeopt=menu,menuone,noselect   " Autocomplete settings
set noeol " Don’t add empty newlines at the end of files

" Shorter timeout to avoid lag,
" this is used for multi-key bindings,
" e.g. how long to wait to see if another key is coming
" for bindings like `<leader>db`.
set timeoutlen=250

" list chars (i.e. hidden characters)
set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " A tab should display as "  "
set listchars+=trail:.            " Show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen

" centralize backup, swap, & undo files
set backupdir^=~/.vim/.backup// 	" Backup files
set directory^=~/.vim/.temp// 		" Swap files
if exists("&undodir")
	set undodir=~/.vim/.undo 		" Undo files
    set undofile
    set undolevels=500
    set undoreload=500
endif

" webbrowser for `gx`
let g:netrw_browsex_viewer='firefox'

" specify how vim saves files
" so it works better with processes
" that watch files for changes
set backupcopy=yes

" automatically trim trailing whitespace on save.
autocmd BufWritePre * :%s/\s\+$//e

" bind return to clear last search highlight.
nnoremap <CR> :noh<CR><CR>

" tabs
map gr gT
nnoremap [t :tabprevious<cr>
nnoremap ]t :tabnext<cr>

" bind jk to escape
imap jk <Esc>
xnoremap jk <Esc>

" open new line from insert mode
imap <C-o> <esc>o

" bind | and _ to vertical and horizontal splits
nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _  !v:count ? "<C-W>s<C-W><Down>"  : '_'

" command flubs
command WQ wq
command Wq wq
command W w
command Q q

" more convenient 'anchoring'
" hit `mm` to drop a mark named 'A'
" hit `;m` to return to that mark
nnoremap mm mA
nnoremap <leader>m `A

" filetypes
filetype plugin indent on
if has("autocmd")
  " make Python follow PEP8 for whitespace (http://www.python.org/dev/peps/pep-0008/)
  au FileType python setlocal softtabstop=4 tabstop=4 shiftwidth=4

  " other filetype specific settings
  au FileType crontab setlocal backupcopy=yes
  au FileType css setlocal tabstop=2 shiftwidth=2
  au FileType sass setlocal tabstop=2 shiftwidth=2
  au FileType javascript setlocal tabstop=2 shiftwidth=2
  au FileType typescript setlocal tabstop=2 shiftwidth=2
  au FileType typescriptreact setlocal tabstop=2 shiftwidth=2

  " for text
  au FileType text setlocal nocursorcolumn spell complete+=kspell

  " remember last location in file, but not for commit messages.
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif

  " gliss scripts
  autocmd BufNewFile,BufRead *.script set filetype=script
  au FileType script setlocal tabstop=2 shiftwidth=2
endif

" Delete no name, empty buffers when leaving a buffer
" to keep the buffer list clean
function! CleanNoNameEmptyBuffers()
    let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])')
    if !empty(buffers)
        exe 'bd '.join(buffers, ' ')
    endif
endfunction
autocmd BufLeave * :call CleanNoNameEmptyBuffers()

" When using c/C don't copy
" to the system clipboard,
" but to the black hole register instead
nnoremap c "_c
nnoremap C "_C

" Configure vimdiff
" to force line-by-line comparison,
" instead of trying to figure out
" what lines should go together.
set diffexpr=LineDiff()
function LineDiff()
   let opt = ""
   if &diffopt =~ "icase"
     let opt = opt .. "-i "
   endif
   if &diffopt =~ "iwhite"
     let opt = opt .. "-b "
   endif
   silent execute "!diff <(nl -ba " .. v:fname_in .. ") <(nl -ba " .. v:fname_new .. ") > " .. v:fname_out
   redraw!
endfunction
set diffopt+=followwrap " Preserve line-wrapping settings when using vimdiff

" Jump to after the next closing delimiter
func! AutoPairsJump()
  call search('["\]'')}]','W')
endf
inoremap <silent> <c-l> <ESC>:call AutoPairsJump()<CR>a
noremap <silent> <c-l> :call AutoPairsJump()<CR>

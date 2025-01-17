" Has to be defined first
let mapleader="'"
set shell=fish

lua <<EOF
-- Automatically install Lazy plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

--- Note: must be loaded before plugins
require('ignore')

require('lazy').setup('plugins', {
  ui = { border = "single" }
})

require('breeze')
require('abbrevs')
require('bindings')
require('filetype/markdown')
require('filetype/rust')

-- For nvim 0.11
-- require('completion')

EOF

colorscheme futora

" navigation
set nonumber
set norelativenumber
set nostartofline 				" Don't reset cursor to start of line when moving
set cursorline 				    " Highlight current line
set scrolloff=3 				" Start scrolling three lines before border
set showmatch 					" Show matching brackets
let &showbreak=' '              " Show this at the start of wrapped lines

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
set conceallevel=0
set noerrorbells 				" Disable error bells
set novisualbell                " Disable visual bells
set showmode 					" Show the current mode
set showcmd 					" Show the command as it's typed
set wrap                        " Wrap long lines
set hidden
set textwidth=0 wrapmargin=0 formatoptions=cq
set display+=lastline
set switchbuf+=usetab
set clipboard=unnamedplus " Use OS clipboard
set completeopt=menu,menuone,noselect   " Autocomplete settings
set noeol " Don’t add empty newlines at the end of files
set mouse= " Disable mouse

" Shorter timeout to avoid lag,
" this is used for multi-key bindings,
" e.g. how long to wait to see if another key is coming
" for bindings like `<leader>db`.
" 200 feels like a good value;
" 100 is too fast.
set timeoutlen=160

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

" specify how vim saves files
" so it works better with processes
" that watch files for changes
set backupcopy=yes

" webbrowser for `gx`
let g:netrw_browsex_viewer='qutebrowser'

" bind | and _ to vertical and horizontal splits
nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _  !v:count ? "<C-W>s<C-W><Down>"  : '_'
set splitright " open vsplits on the right by default

" When using c/C don't copy
" to the system clipboard,
" but to the black hole register instead
nnoremap c "_c
nnoremap C "_C

" Hide the command line, use the status line instead
" The downside with this is frequent "ENTER to continue" prompts
" This is a hack that sets the `cmdheight=1` when entering a command,
" then right after leaving, sets it back to 0, thus avoiding the ENTER prompt.
set cmdheight=0
au CmdlineEnter * setlocal cmdheight=1 laststatus=0
au CmdlineLeave * call timer_start(1, { tid -> execute('setlocal cmdheight=0 laststatus=2')})
set shortmess=WnoOcIatTF " Limit command line messaging

" The command line *is* useful when recording macros, though.
lua <<EOF
-- Show macro recording status when recording a macro
vim.api.nvim_create_autocmd("RecordingEnter", {
  callback = function(ctx)
    vim.opt.cmdheight = 1
  end
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  callback = function()
    vim.opt.cmdheight = 0
  end
})
EOF

" Hack to suppress the ENTER prompt
" when writing a file.
cnoreabbrev w silent write

" filetypes
filetype plugin indent on
au FileType crontab setlocal backupcopy=yes
au FileType css setlocal tabstop=2 shiftwidth=2
au FileType sass setlocal tabstop=2 shiftwidth=2
au FileType javascript setlocal tabstop=2 shiftwidth=2
au FileType typescript setlocal tabstop=2 shiftwidth=2
au FileType typescriptreact setlocal tabstop=2 shiftwidth=2
au FileType python setlocal softtabstop=4 tabstop=4 shiftwidth=4
au FileType lua setlocal softtabstop=2 tabstop=2 shiftwidth=2
au FileType markdown setlocal softtabstop=2 tabstop=2 shiftwidth=2
au FileType markdown setlocal spell spelllang=fr,en_us complete+=kspell
au FileType text setlocal spell spelllang=fr,en_us complete+=kspell

" Unity USS/UXML files
au BufNewFile,BufRead *.uss set filetype=css
au BufNewFile,BufRead *.uxml set filetype=html

" Gliss tooling
au BufNewFile,BufRead *.script lua require('gliss/verses')
au BufNewFile,BufRead *.md lua require('gliss/loom')

" Automatically trim trailing whitespace on save.
au BufWritePre * :%s/\s\+$//e

" Remember last location in file, but not for commit messages.
au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
\| exe "normal! g`\"" | endif

" Delete no name, empty buffers when leaving a buffer
" to keep the buffer list clean
function! CleanNoNameEmptyBuffers()
    let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])')
    if !empty(buffers)
        exe 'bd '.join(buffers, ' ')
    endif
endfunction
autocmd BufLeave * :call CleanNoNameEmptyBuffers()

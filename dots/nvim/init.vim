" Has to be defined first
let mapleader=","
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

-- Show error count in status line.
local default_status = "%f %m %r %= %l,%c %p%%"
vim.o.statusline = default_status
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function()
    local diagnostics = vim.diagnostic.get(0, {
        severity = vim.diagnostic.severity.ERROR
    })
    local errors = #diagnostics
    if errors > 0 then
        vim.o.statusline = "%#StatusLineError# E:" .. errors .. " %* " .. default_status
    else
        vim.o.statusline = default_status
    end
  end,
})

-- Show errors and warnings in a floating window
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        -- Skip if another floating window is open
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
                return
            end
        end
        -- Show diagnostics if no other floating windows are present
        vim.diagnostic.open_float(nil, { focusable = false, source = true })
    end,
})

-- Note: must be loaded before plugins
require('ignore')

require('lazy').setup('plugins')

require('lsp')
require('abbrevs')
require('bindings')
require('francais')
require('filetype/markdown')

EOF

colorscheme futora

set updatetime=500
set scrolloff=3 				" Start scrolling three lines before border
set showmatch 					" Show matching brackets
let &showbreak=' '              " Show this at the start of wrapped lines
set tabstop=4                   " Set tab spaces
set shiftwidth=4                " Set autoindent (with <<) spaces
set expandtab                   " Use spaces, not tabs
set smartindent                 " Indent based on language
set backspace=indent,eol,start  " Backspace through everything in insert mode
set ignorecase                  " Case insensitive searches...
set smartcase                   " ...unless they contain capital letters
set gdefault 	                " Global search/replace by default
set display+=lastline           " Show as much of the last line as possible
set clipboard=unnamedplus       " Use OS clipboard
set noeol                       " Don’t add newlines at the end of files
set splitright                  " Open vsplits on the right by default
set splitbelow                  " Open hsplits on below by default
set jumpoptions=stack,view,clean

set list                        " Show invisible characters:
set listchars=""                " - Reset the listchars
set listchars=tab:\ \           " - A tab should display as "  "
set listchars+=trail:.          " - Show trailing spaces as dots

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
let g:netrw_browsex_viewer='qutebrowser'

" Hide the command line, use the status line instead
set cmdheight=0
set shortmess=WnoOcIatTFA " Limit command line messaging

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
cnoreabbrev qw wq

" filetypes
filetype plugin indent on
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

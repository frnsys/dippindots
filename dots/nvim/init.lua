-- Has to be defined first
vim.g.mapleader = ","
vim.opt.shell = "fish"

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("motion")
require("search")
require("nav")
require('lsp')
require('util')
require('abbrevs')
require('bindings')
require('filetypes')

local ok, mod = pcall(require, "gliss/verses-map")
if ok then
  mod.setup()
end

vim.cmd([[colorscheme futora]])

--- Show this at the start of wrapped lines
vim.o.showbreak = "  "

--- Use spaces, not tabs
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

--- Case insensitive searches unless they contain capitals
vim.o.ignorecase = true
vim.o.smartcase = true

--- Global search/replace by default
vim.o.gdefault = true

--- SSH-compatible clipboard
vim.g.clipboard = 'osc52'

--- Use OS clipboard
vim.o.clipboard = "unnamedplus"

--- Open vsplits on the right by default
--- Open hsplits on below by default
vim.o.splitright = true
vim.o.splitbelow = true

--- Set the jumplist to behave like a stack,
--- restore view, and clean unloaded buffers
vim.o.jumpoptions = "stack,view,clean"

--- Use filename as title
vim.o.title = true
vim.o.titlestring = "%t"

--- webbrowser for `gx`
vim.g.netrw_browsex_viewer = "qutebrowser"

--- Hide the command line, use the status line instead
vim.o.cmdheight = 0
vim.o.shortmess = "WnoOcIatTFA" -- Limit command line messaging

--- The command line *is* useful when recording macros, though.
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

--- Automatically trim trailing whitespace on save.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

--- Remember last location in file, but not for commit messages.
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    if ft:lower():match("^git") then
      return
    end

    local last_pos = vim.fn.line([['"]])
    local last_line = vim.fn.line("$")

    -- Jump only if the mark is valid
    if last_pos > 0 and last_pos <= last_line then
      vim.cmd([[normal! g`"]])
    end
  end,
})

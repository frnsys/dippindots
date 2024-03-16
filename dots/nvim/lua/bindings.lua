--- Easier text objects
vim.keymap.set("o", "ar", "a]") -- [r]ectangular bracket
vim.keymap.set("o", "ac", "a}") -- [c]urly brace
vim.keymap.set("o", "aq", 'a"') -- [q]uote
vim.keymap.set("o", "ir", "i]") -- [r]ectangular bracket
vim.keymap.set("o", "ic", "i}") -- [c]urly brace
vim.keymap.set("o", "iq", 'i"') -- [q]uote

--- Easier window navigation
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

--- Use up/down arrows to expand/contract
--- visual selection symmetrically
vim.keymap.set('v', '<up>', 'j$ok0o')
vim.keymap.set('v', '<down>', 'k$oj0o')

--- Minor movements in insert mode
vim.keymap.set('i', '<c-j>', '<down>')
vim.keymap.set('i', '<c-k>', '<up>')

--- Buffer navigation
vim.keymap.set("n", "<c-'>", ":bn<cr><cr>")
vim.keymap.set("n", "<c-;>", ":bp<cr><cr>")

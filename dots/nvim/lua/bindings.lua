--- Easier text objects
vim.keymap.set("o", "ac", "a)") -- parentheses
vim.keymap.set("o", "ar", "a]") -- [r]ectangular bracket
vim.keymap.set("o", "ab", "a}") -- curly [b]race
vim.keymap.set("o", "aq", 'a"') -- [q]uote
vim.keymap.set("o", "ic", "i)") -- parentheses
vim.keymap.set("o", "ir", "i]") -- [r]ectangular bracket
vim.keymap.set("o", "ib", "i}") -- curly [b]race
vim.keymap.set("o", "iq", 'i"') -- [q]uote

--- Easier window navigation
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

--- Expand/contract visual selection symmetrically
vim.keymap.set('v', '<c-k>', 'j$ok0o')
vim.keymap.set('v', '<c-j>', 'k$oj0o')

--- Minor movements in insert mode
vim.keymap.set('i', '<c-j>', '<down>')
vim.keymap.set('i', '<c-k>', '<up>')

--- Quickfix navigation
vim.keymap.set("n", "<C-n>", ":cnext<cr><cr>")
vim.keymap.set("n", "<C-p>", ":cprev<cr><cr>")

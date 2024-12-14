--- Easier text objects
---
--- Notes:
--- * Not using `p` b/c it's already "paragraph"
--- * Not using `b` b/c it's already "block"
--- * Avoid `hjkl` and other operator keys, e.g. `t`, `/`
--- * Make sure these don't conflict with the
---   mappings in `plugins/treesitter.lua`
local remappings = {
  { "o", "(", ")" },
  { "r", "[", "]" },
  { "c", "{", "}" },
  { "q", '"', '"' },
}

for _, map in ipairs(remappings) do
  local key = map[1]
  local target = map[2]
  local target_close = map[3]

  -- Around
  vim.keymap.set({"o", "v"}, "a" .. key, "a" .. target)

  -- Inside
  vim.keymap.set({"o", "v"}, "i" .. key, "i" .. target)

  -- To
  vim.keymap.set({"o", "v"}, "t" .. key, "t" .. target_close)

  -- Convenience binding that assumes "inside"
  vim.keymap.set({"o", "v"}, key, "i" .. target)

  -- Convenience jump to
  vim.keymap.set("n", "." .. key, "f" .. target, { noremap = true })
  vim.keymap.set("n", "," .. key, "F" .. target, { noremap = true })
end

--- To next empty line
-- vim.keymap.set({"o", "v"}, "<space>", "}")

vim.keymap.set("n", "<S-t>", ":tabnew<cr><cr>")

--- Easier jumping between matching brackets
vim.keymap.set({"n", "o"}, ",.", "%", { noremap = true })
vim.keymap.set({"n", "o"}, ".,", "%", { noremap = true })

--- Easier window navigation
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

--- Expand/contract visual selection symmetrically
vim.keymap.set('v', '<c-k>', 'j$ok0o')
vim.keymap.set('v', '<c-j>', 'k$oj0o')

--- Minor movements in insert mode
-- vim.keymap.set('i', '<c-j>', '<down>')
-- vim.keymap.set('i', '<c-k>', '<up>')

--- Quickfix navigation
vim.keymap.set("n", "<C-n>", ":cnext<cr><cr>")
vim.keymap.set("n", "<C-p>", ":cprev<cr><cr>")

--- Terminals
vim.keymap.set(
    'n',
    '<leader>vt',
    [[<cmd>vsplit | term<cr>]],
    { desc = 'Open terminal in vertical split' }
)
vim.keymap.set(
    'n',
    '<leader>ht',
    [[<cmd>belowright split | term<cr>]],
    { desc = 'Open terminal in horizontal split' }
)

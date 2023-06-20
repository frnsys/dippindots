-- Two new text objects by default:
-- - `a`: argument
-- - `f`: function call (name and args)
require('mini.ai').setup({
  -- Note: "|" indicates cursor position
  -- See: <https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-ai.txt#L225>
  custom_textobjects = {
    -- CamelCase or pascalCase subword
    -- e.g. fo|oBar
    -- e.g. Fo|oBar
    -- "ciS" will change "foo" and "Foo" respectively
    S = { {
      '^()%u?[%l%d]+()',
      '[%s%p]()%u?[%l%d]+()',
      '[%l%u]()%u+[%l%d]+()'
    } },
  },
})

-- substitute
vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
vim.keymap.set("n", "ss", require('substitute').line, { noremap = true })
vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })

-- portal
require('portal').setup({
  window_options = {
    height = 5,
  },
})
vim.keymap.set("n", "<leader>o", "<cmd>Portal jumplist backward<cr>")
vim.keymap.set("n", "<leader>i", "<cmd>Portal jumplist forward<cr>")

-- hopping
local hop = require('hop')
vim.keymap.set('n', 'f', function()
  hop.hint_char1({ direction = nil, current_line_only = false })
end)

-- smarter visual selection
local treehopper = require('tsht')
vim.keymap.set('n', 'vv', treehopper.nodes)

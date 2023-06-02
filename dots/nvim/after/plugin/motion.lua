require('mini.jump').setup({
  delay = {
    highlight = 0
  }
})

require('mini.jump2d').setup({
  mappings = {
    start_jumping = '<c-f>',
  },
})

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

-- Treat underscore as a word delimiter,
-- so `w` doesn't skip over them.
-- Makes dealing with snake case way easier
vim.api.nvim_command("set iskeyword-=_")

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

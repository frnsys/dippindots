require("nvim-tree").setup({
  -- don't disable netrw
  -- so `gx` still works
  disable_netrw = false,
  hijack_netrw = false,
  renderer = {
    icons = {
      show = {
        git = false,
        file = false,
        folder = false,
        folder_arrow = true,
      },
      glyphs = {
        folder = {
          arrow_closed = "⏵",
          arrow_open = "⏷",
        },
      },
    },
  },
})

local api = require('nvim-tree.api')
vim.keymap.set('n', '-', api.tree.toggle, { buffer = bufnr, desc = "Open tree" })

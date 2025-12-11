vim.pack.add({
  "https://github.com/mikesmithgh/kitty-scrollback.nvim",
})
require('kitty-scrollback').setup({
  {
    status_window = {
      style_simple = true
    },
    paste_window = {
      yank_register_enabled = false,
    },
  }
})

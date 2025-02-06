vim.cmd([[
  augroup neovim_terminal
      autocmd!
      " Enter Terminal-mode (insert) automatically,
      " but not if the terminal is opening from the kitty scrollback plugin.
      if $KITTY_SCROLLBACK_NVIM != 'true'
        autocmd TermOpen * startinsert
      endif
      " Disables number lines on terminal buffers
      autocmd TermOpen * :set nonumber norelativenumber
      " allows you to use Ctrl-c on terminal window
      autocmd TermOpen * nnoremap <buffer> <C-c> i<C-c>
  augroup END
]])

return {
  {
    --- Colorize ANSI escape sequences.
    "m00qek/baleia.nvim",
    version = "*",
    event = { 'BufEnter *.trm' },
    config = function()
      vim.g.baleia = require("baleia").setup({})

      -- Load automatically for .trm files.
      vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        pattern = "*.trm",
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          vim.g.baleia.once(buffer)
          vim.api.nvim_set_option_value("modified", false, { buf = buffer })
          vim.api.nvim_set_option_value("modifiable", false, { buf = buffer })
        end,
      })
      vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
        pattern = "*.trm",
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          vim.api.nvim_set_option_value("modifiable", true, { buf = buffer })
          vim.g.baleia.once(buffer)
          vim.api.nvim_set_option_value("modified", false, { buf = buffer })
          vim.api.nvim_set_option_value("modifiable", false, { buf = buffer })
        end,
      })
    end,
  },
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
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
    end,
  },
}

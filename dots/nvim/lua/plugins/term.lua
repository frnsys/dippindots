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

  {
    'akinsho/toggleterm.nvim',
    config = true,
    enabled = false,
  },
}

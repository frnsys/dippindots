return {
  --- Nicer markdown headings.
  {
    'lukas-reineke/headlines.nvim',
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "markdown" },
    opts = {
      markdown = {
        bullets = {},
      }
    }
  },

  {
    'junegunn/goyo.vim',
    ft = { "markdown" },
    config = function()
    end
  },

  --- LSP status
  {
    "j-hui/fidget.nvim",
    opts = {},
  },

  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },

  {
    'mikesmithgh/kitty-scrollback.nvim',
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    version = '*', -- latest stable version, may have breaking changes if major version changed
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

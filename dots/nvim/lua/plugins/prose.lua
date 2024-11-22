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

  --- Zen mode for markdown editing.
  {
    "folke/zen-mode.nvim",
    ft = { "markdown" },
    opts = {
      window = {
        backdrop = 1,
        width = 80,
        options = {
          number = false,
          relativenumber = false,
        }
      },
      plugins = {
        -- this will change the font size on kitty when in zen mode
        -- to make this work, you need to set the following kitty options:
        -- - allow_remote_control socket-only
        -- - listen_on unix:/tmp/kitty
        kitty = {
          enabled = true,
          font = "+2", -- font size increment
        },
      }
    }
  },
}

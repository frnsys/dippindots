return {
  --- Faster movement within buffers
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      search = {
        multi_window = false,
        mode = 'fuzzy',
      },
      label = {
        after = true,
        before = true,
        rainbow = {
          enabled = true
        }
      },
      modes = {
        char = {
          enabled = false,
        }
      },
      prompt = {
        enabled = false,
      }
    },
    keys = {
      {
        "<c-f>",
        mode = { "n" },
        function()
          require("flash").jump({
            label = {
              before = false,
              after = true,
            },
            mode = "char",
            search = {
              wrap = true,
              mode = "exact",
              max_length = 1,
            }
          })
        end,
        desc = "Flash jump visible buffer",
      },
    },
  },

  --- Surround motion
  {
    'echasnovski/mini.surround',
    event = 'VeryLazy',
    opts = {}
  },

  --- Substitute motion
  {
    'gbprod/substitute.nvim',
    opts = {},
    keys = {
      { 's', function()
        require('substitute').operator()
      end },

      { 'ss', function()
        require('substitute').line()
      end },

      { 's', function()
        require('substitute').visual()
      end, { 'x' } }
    },
  },

  {
    'jinh0/eyeliner.nvim',
    config = function()
      require("eyeliner").setup({ highlight_on_key = true, dim = true })
      vim.api.nvim_set_hl(0, 'EyelinerPrimary',
        { fg = "#da9604", bold = true, underline = true })
      vim.api.nvim_set_hl(0, 'EyelinerSecondary',
        { fg = "#3d3d3d" })
    end
  }
}

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
        "<c-space>",
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
      {
        "<space><space>",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },

  --- Faster movement through jumplist
  {
    'cbochs/portal.nvim',
    keys = {
      { 'K', '<cmd>Portal jumplist backward<cr>' },
      { 'J', '<cmd>Portal jumplist forward<cr>' },
    },
    opts = {
      window_options = {
        relative = "cursor",
        width = 80,
        height = 6,
        col = 2,
        focusable = false,
        border = "single",
        noautocmd = true,
      },
    }
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

  --- Symbol navigation
  {
    'stevearc/aerial.nvim',
    keys = {
      {
        '<leader>s',
        function()
          require('aerial').toggle()
        end,
        desc = 'Open symbol navigation'
      },
    },
    opts = {
      layout = {
        default_direction = "prefer_left",
      }
    },
    config = function(_, opts)
      require('aerial').setup(opts)

      --- Use <esc> to jump back to the previous window
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'aerial',
        callback = function(opts)
          vim.keymap.set('n', '<esc>', function()
            local prev_window = vim.fn.winnr('#')
            local win_id = vim.fn.win_getid(prev_window)
            vim.api.nvim_set_current_win(win_id)
          end, {
            silent = true,
            buffer = opts['buffer']
          })
        end
      });
    end
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

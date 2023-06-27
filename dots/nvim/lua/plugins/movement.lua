return {
  --- Faster movement
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      highlight = {
        label = {
          after = true,
          before = true,
        }
      },
      modes = {
        char = {
          enabled = false,
        }
      }
    },
    keys = {
      {
        "f",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            highlight = {
              label = {
                before = false,
                after = true,
              },
            },
            mode = "char",
            search = {
              wrap = true,
              mode = "exact",
              max_length = 1,
            }
          })
        end,
        desc = "Flash",
      },
      {
        "vv",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      { -- Chain this with operators like "y", "d", etc, e.g. "dr"
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
    },
  },

  { 'cbochs/portal.nvim',
    keys = {
      {'<leader>o', '<cmd>Portal jumplist backward<cr>'},
      {'<leader>i', '<cmd>Portal jumplist forward<cr>'},
    },
    opts = {
      window_options = {
        height = 5,
      },
    }
  },

  --- Better text objects/motions
  { 'echasnovski/mini.ai',
    event = 'VeryLazy',
    -- Two new text objects by default:
    -- - `a`: argument
    -- - `f`: function call (name and args)
    opts = {
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
    }
  },

  --- Surround motion
  { 'echasnovski/mini.surround',
    event = 'VeryLazy',
    opts = {} },

  --- Substitute motion
  { 'gbprod/substitute.nvim',
    opts = {},
    keys = {
      {'s', function()
        require('substitute').operator()
      end},

      {'ss', function()
        require('substitute').line()
      end},

      {'ss', function()
        require('substitute').line()
      end},

      {'s', function()
        require('substitute').visual()
      end, {'x'}}
    },
  },

  --- Symbol navigation
  { 'stevearc/aerial.nvim',
    keys = {
      {'<leader>j', function()
        require('aerial').toggle()
      end, desc = 'Open symbol navigation'},
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
}

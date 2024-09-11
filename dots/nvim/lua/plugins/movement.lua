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
        search = {
          enabled = true,
        },
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
            search = {
              wrap = true,
              mode = "exact",
              multi_window = false,
            }
          })
        end,
        desc = "Flash jump visible buffer",
      },

      {
        "f",
        mode = { "n" },
        function()
          require("flash").jump({
            label = {
              before = false,
              after = true,
            },
            mode = "char",
            search = {
              wrap = false,
              mode = "exact",
              max_length = 1,
              forward = true,
            }
          })
        end,
        desc = "Flash jump visible buffer",
      },
      {
        "F",
        mode = { "n" },
        function()
          require("flash").jump({
            label = {
              before = false,
              after = true,
            },
            mode = "char",
            search = {
              wrap = false,
              mode = "exact",
              max_length = 1,
              forward = false,
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
    opts = {
      mappings = {
        add = 'sa',     -- e.g. saw'
        delete = 'sd',  -- e.g. sd'
        replace = 'sr', -- e.g. sr'"
      }
    }
  },

  --- Substitute motion
  {
    'gbprod/substitute.nvim',
    opts = {},
    keys = {
      -- e.g. siw
      { 's', function()
        require('substitute').operator()
      end, { 'n' } },

      { 'ss', function()
        require('substitute').line()
      end },
    },
  },
}

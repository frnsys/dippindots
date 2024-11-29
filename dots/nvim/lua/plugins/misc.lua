return {
  {
    'numToStr/Comment.nvim',
    keys = { { '<c-/>', mode = { 'n', 'v' } } },
    opts = {
      toggler = {
        --- Line-comment toggle keymap
        line = '<c-/>',
      },
      opleader = {
        --- Line-comment keymap (visual mode)
        line = '<c-/>',
      },
    }
  },

  --- Show git gutter signs,
  --- and also populate qflist/trouble with changes using `:Gitsigns setqflist`.
  {
    'lewis6991/gitsigns.nvim',
    lazy = false,
    opts = {},
    keys = {
      {
        "gn",
        function()
          require("gitsigns").nav_hunk("next")
        end,
        desc = 'Jump to next git hunk'
      },
      {
        "gp",
        function()
          require("gitsigns").nav_hunk("prev")
        end,
        desc = 'Jump to prev git hunk'
      },

    },
  },

  --- ['t]: Show to do items
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    keys = {
      {
        "<leader>t",
        function()
          require("trouble").toggle("todo")
        end,
        desc = 'Search TODO items'
      },
    },
    opts = {
      keywords = {
        TODO = { icon = " ", color = "warning" },
      },
      merge_keywords = false,
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*]],
      },
      search = {
        pattern = [[\b(KEYWORDS)\b]],
      }
    }
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
          }
        }
      })
    end,
  }
}

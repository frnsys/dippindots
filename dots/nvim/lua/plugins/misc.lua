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
        width = 100,
      },
    }
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
  }
}

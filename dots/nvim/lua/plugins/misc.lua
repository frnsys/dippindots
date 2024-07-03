return {
  {
    'numToStr/Comment.nvim',
    keys = { { '<c-/>', mode = { 'n', 'v' } } },
    opts = {
      toggler = {
        ---Line-comment toggle keymap
        line = '<c-/>',
      },
      opleader = {
        ---Line-comment keymap (visual mode)
        line = '<c-/>',
      },
    }
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {}
  },
  {
    'lukas-reineke/headlines.nvim',
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      markdown = {
        bullets = {},
      }
    }
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        backdrop = 1,
        width = 100,
      },
    }
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "'t",
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

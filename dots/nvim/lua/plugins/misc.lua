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
    opts = {
      markdown = {
        bullets = {},
      }
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
    opts = {}
  }
}

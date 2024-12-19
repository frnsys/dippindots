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
  }
}

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

  --- Surround motion
  ---
  --- [S']: Add quotes around visual selection
  {
    'kylechui/nvim-surround',
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({})
    end
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

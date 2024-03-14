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
    'echasnovski/mini.clue',
    opts = {},
    config = function(_, opts)
      require('mini.clue').setup({
        triggers = {
          { mode = 'n', keys = '<Leader>d' },
          { mode = 'n', keys = '<space>' }
        },
        window = {
          delay = 10,
        }
      })
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {}
  },
  {
    'dhruvasagar/vim-table-mode',
  },
  {
    'rhaiscript/vim-rhai'
  }
}

return {
  {
    'numToStr/Comment.nvim',
    keys = { {'<c-_>', mode = {'n', 'v'}} },
    opts = {
      toggler = {
        ---Line-comment toggle keymap
        line = '<c-_>', -- Note: this is <c-/>
      },
      opleader = {
        ---Line-comment keymap
        line = '<c-_>', -- Note: this is <c-/>
      },
    }
  },
}

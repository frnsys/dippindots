return {
  --- Like <c-i> and <c-o> but
  --- goes across buffers instead of
  --- within a buffer.
  {
    'kwkarlwang/bufjump.nvim',
    config = function()
      require("bufjump").setup({
        forward_key = "<S-j>",
        backward_key = "<S-k>",
        on_success = nil
      })
    end,
  },
}

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

  {
    'j-morano/buffer_manager.nvim',
    config = function()
      require("buffer_manager").setup({
        short_file_names = true,
      })
    end,
    keys = {
      {
        "''",
        function()
          require("buffer_manager.ui").toggle_quick_menu()
        end,
        desc = 'Jump to buffer'
      },
    }
  }
}

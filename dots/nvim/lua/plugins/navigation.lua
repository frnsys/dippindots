return {
  {
    --- Like <c-i> and <c-o> but
    --- goes across buffers instead of
    --- within a buffer.
    'kwkarlwang/bufjump.nvim',
    config = function()
      require("bufjump").setup({
        forward = "<S-j>",
        backward = "<S-k>",
        on_success = nil
      })
    end,
  },

  {
    --- Like <c-i> and <c-o> but
    --- moves through edit history
    --- rather than the jump list.
    'bloznelis/before.nvim',
    config = function()
      local before = require('before')
      before.setup()

      -- Jump to previous entry in the edit history
      vim.keymap.set('n', '<C-o>', before.jump_to_last_edit, {})

      -- Jump to next entry in the edit history
      vim.keymap.set('n', '<C-i>', before.jump_to_next_edit, {})
    end
  },

  --- Symbol navigation
  {
    'stevearc/aerial.nvim',
    config = function(_, opts)
      require('aerial').setup(opts)
    end
  },

  {
    --- For bookmarking files
    'otavioschwanck/arrow.nvim',
    opts = {
      show_icons = false,
      leader_key = '\\'
    }
  }
}

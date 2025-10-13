return {
  {
    'kwkarlwang/bufjump.nvim',
    config = function()
        require("bufjump").setup({
            forward_key = "+",
            backward_key = "L",
        })
    end,
  },

  {
    "yorickpeterse/nvim-window",
    keys = {
      { ",t", function()
        local win_count = vim.fn.winnr('$')

        -- If there are only two windows,
        -- jump to the other one.
        if win_count == 2 then
            -- Switch to the other window
            vim.cmd('wincmd w')

        -- Otherwise use the picker.
        else
          require('nvim-window').pick()
        end
      end, desc = "nvim-window: Jump to window" },
    },
    config = function()
      require('nvim-window').setup({
        -- The characters available for hinting windows.
        chars = {
          't', 'r', 's',
        },
        normal_hl = 'WindowTarget',
        border = 'none',
      })
    end,
  },
}

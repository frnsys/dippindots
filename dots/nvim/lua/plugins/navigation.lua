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

  --- Syntax highlighting in the quickfix window,
  --- easy toggling, ...
  {
    "stevearc/quicker.nvim",
    config = function()
      vim.keymap.set("n", "<leader>q", function()
        require("quicker").toggle({
          focus = true
        })
      end, {
        desc = "Toggle quickfix",
      })
      require("quicker").setup()
    end
  },

  --- Better quickfix preview and behaviors.
  ---
  --- Bindings:
  ---
  --- Default:
  --- [o]: open item and close qf
  --- [ctrl-p]: prev item
  --- [ctrl-n]: next item
  {
    "kevinhwang91/nvim-bqf",
    config = function()
    end
  },

  {
    "yorickpeterse/nvim-window",
    keys = {
      { ",,", function()
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
          'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'
        },
        normal_hl = 'WindowTarget',
        border = 'none',
      })
    end,
  },

  {
    'declancm/maximize.nvim',
    config = true,
    keys = {
      {
        "mm",
        function()
          require('maximize').toggle()
        end,
        desc = 'Toggle maximize'
      }
    }
  },
}

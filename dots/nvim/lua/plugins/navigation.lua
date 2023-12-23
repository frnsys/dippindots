return {
  {
    'kevinhwang91/nvim-bqf',
  },
  {
    'kwkarlwang/bufjump.nvim',
    config = function()
      require("bufjump").setup({
        forward = "<S-j>",
        backward = "<S-k>",
        on_success = nil
      })
    end,
  },

  --- Symbol navigation
  {
    'stevearc/aerial.nvim',
    keys = {
      {
        '<leader>s',
        function()
          require('aerial').toggle()
        end,
        desc = 'Open symbol navigation'
      },
    },
    opts = {
      layout = {
        default_direction = "prefer_left",
      }
    },
    config = function(_, opts)
      require('aerial').setup(opts)

      --- Use <esc> to jump back to the previous window
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'aerial',
        callback = function(opts)
          vim.keymap.set('n', '<esc>', function()
            local prev_window = vim.fn.winnr('#')
            local win_id = vim.fn.win_getid(prev_window)
            vim.api.nvim_set_current_win(win_id)
          end, {
            silent = true,
            buffer = opts['buffer']
          })
        end
      });
    end
  },
}

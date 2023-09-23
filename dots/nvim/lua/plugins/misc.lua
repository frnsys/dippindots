return {
  {
    'numToStr/Comment.nvim',
    keys = { { '<c-_>', mode = { 'n', 'v' } } },
    opts = {
      toggler = {
        ---Line-comment toggle keymap
        line = '<c-_>', -- Note: this is <c-/>
      },
      opleader = {
        ---Line-comment keymap (visual mode)
        line = '<c-_>', -- Note: this is <c-/>
      },
    }
  },

  {
    "folke/zen-mode.nvim",
    cmd = 'ZenMode',
    opts = {
      window = {
        width = 80,
        backdrop = 1.0,
      }
    }
  },

  {
    "luckasRanarison/nvim-devdocs",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { '\'h',
        function()
          require('nvim-devdocs').open_doc_current_file(true)
        end
      },
    },
    config = function()
      require("nvim-devdocs").setup({
        ensure_installed = { 'rust' },
        telescope = {
          attach_mappings = function(_, map)
            map('i', "<CR>", require("telescope.actions").select_default)
            return true
          end
        },
        after_open = function(bufnr)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', ':close<CR><CR>', {})
        end
      })
    end
  }
}

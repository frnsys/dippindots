return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    opts = {
      keymaps = {
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["g."] = "actions.toggle_hidden",
        ["q"] = "actions.close",
      },
      use_default_keymaps = false,
      float =  {

      },
      preview_win = {
        preview_method = "load",
      },
      view_options = {
        -- Check against ignore patterns to
        -- determine what files to hide
        is_hidden_file = function(name, bufnr)
          if vim.startswith(name, ".") then
            return true
          end
          if name == "target" then
            return true
          end
          for _, pat in ipairs(edit_file_ignore_patterns) do
            if name:match(pat) then
              return true
            end
          end
          return false
        end,
      },
    },
    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Open parent directory"
      }
    }
  },

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
    "yorickpeterse/nvim-window",
    keys = {
      { ",f", function()
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
}

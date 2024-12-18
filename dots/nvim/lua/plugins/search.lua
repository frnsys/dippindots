--- Keymap prefix: '

return {
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

  --- Bindings:
  ---
  --- Custom:
  --- [ctrl-q]: send results to quickfix list
  ---
  --- Default:
  --- [ctrl-u]: clear search query
  --- [ctrl-g]: fuzzy search results
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup({
        defaults = {
          file_icons = false,
        },
        files = {
          formatter = "path.filename_first",
          no_header = true,
          no_header_i = true,
          actions = { ["ctrl-q"] = { fn = require("fzf-lua").actions.file_sel_to_qf, prefix = "select-all" } }
        },
        grep = {
          no_header = true,
          no_header_i = true,
          actions = {
            ["ctrl-q"] = {
              fn = require("fzf-lua").actions.file_edit_or_qf, prefix = 'select-all+'
            },
          }
        },
        buffers = {
          formatter = "path.filename_first",
          no_header = true,
          no_header_i = true,
        },
        previewers = {
          bat = {
            cmd   = "bat",
            args  = "--color=always --style=numbers,changes",
            theme = '1337',
          },
        },

        -- Cherry-picking some config from the 'max-perf' profile.
        winopts = { width = 0.5, preview = { default = "bat", layout = "vertical", vertical = 'down:70%' } },
      })
    end,
    keys = {
      {
        "<leader>f",
        function()
          require('fzf-lua').files()
        end,
        desc = 'Search files by name'
      },
      {
        "<leader>s",
        function()
          require('fzf-lua').live_grep_glob()
        end,
        desc = 'Search by grep'
      },
      {
        "<leader><c-s>",
        function()
          require('fzf-lua').live_grep_glob({
            resume = true
          })
        end,
        desc = 'Search by grep (resume)'
      },
      {
        "<leader><leader>",
        function()
          require('fzf-lua').lines()
        end,
        desc = 'Search buffer lines'
      },
      {
        "<leader>r",
        function()
          require('fzf-lua').lsp_references()
        end,
        desc = 'Find references for word under cursor'
      },
      {
        "<leader>i",
        function()
          require('fzf-lua').complete_path()
        end,
        desc = 'Complete path'
      },
    },
  }
}

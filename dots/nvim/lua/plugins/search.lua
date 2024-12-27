--- Keymap prefix: '

return {
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
          no_header = true,
          no_header_i = true,

          -- Required to use the fzf highlight
          -- groups defined below.
          fzf_colors = true,
        },
        files = {
          formatter = "path.filename_first",
          actions = { ["ctrl-q"] = { fn = require("fzf-lua").actions.file_sel_to_qf, prefix = "select-all" } },
        },
        grep = {
          formatter = "path.filename_first",
          rg_opts = "--no-heading --color=always --colors 'match:fg:0xff,0x5c,0x5c' --smart-case --max-columns=4096 -e",
          actions = {
            ["ctrl-q"] = {
              fn = require("fzf-lua").actions.file_edit_or_qf, prefix = 'select-all+'
            },
          },
        },
        previewers = {
          bat = {
            cmd   = "bat",
            args  = "--color=always --style=plain",
            theme = '1337',
          },
        },
        winopts = {
          width = 38,
          preview = {
            default = "bat",
            layout = "vertical",
            vertical = "down:70%",
            border = "border-top",
          },
        },
        hls = {
          border = "Keyword",
          fzf = {
            info = "Special",
            query = "Normal",
            prompt = "Keyword",
            pointer = "Function",
            match = "@property",
            separator = "Keyword",
            border = "Keyword",
          },
        },
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

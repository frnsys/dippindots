--- Keymap prefix: '

return {
    {
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup({
        defaults = {
          file_icons = false,
        },
        files = {
          formatter = "path.filename_first",
        },

        -- Cherry-picking some config from the 'max-perf' profile.
        winopts = { preview = { default = "bat" } },
        lsp = { code_actions = { previewer = "codeaction_native" } },
      })
    end,
    keys = {
      {
        "'f",
        function()
          require('fzf-lua').files()
        end,
        desc = 'Search files by name'
      },
      {
        "'s",
        function()
          require('fzf-lua').live_grep_native()
        end,
        desc = 'Search by grep'
      },
      {
        "''",
        function()
          require('fzf-lua').buffers()
        end,
        desc = 'List buffers'
      },
      {
        "'b",
        function()
          require('fzf-lua').lgrep_curbuf()
        end,
        desc = 'Fuzzily search in current buffer'
      },
      {
        "'r",
        function()
          require('fzf-lua').lsp_references()
        end,
        desc = 'Find references for word under cursor'
      },
      {
        "'g",
        function()
          require('fzf-lua').lsp_live_workspace_symbols()
        end,
        desc = 'Search workspace symbols'
      },
      {
        "'a",
        mode = "i",
        function()
          require('fzf-lua').complete_path()
        end,
        desc = 'Complete path'
      },
    },
  }
}

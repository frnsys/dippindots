local function ra_flycheck()
  local clients = vim.lsp.get_clients({
    name = 'rust_analyzer',
  })
  for _, client in ipairs(clients) do
    local params = vim.lsp.util.make_text_document_params()
    client.notify('rust-analyzer/runFlycheck', params)
  end
end

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
          previewer = false,
          formatter = "path.filename_first",
          actions = { ["ctrl-q"] = { fn = require("fzf-lua").actions.file_sel_to_qf, prefix = "select-all" } },
        },
        grep = {
          formatter = "path.filename_first",
          rg_opts = "--no-heading --line-number --column --color=always --colors 'match:fg:0xff,0x5c,0x5c' --smart-case --max-columns=4096 -e",
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
          width = 64,
          preview = {
            default = "bat",
            layout = "vertical",
            vertical = "down:70%",
            border = "border-top",
          },
        },
        hls = {
          border = "Keyword",
          live_prompt = "Normal",
          live_sym = "Normal",
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
        "<leader>b",
        function()
          require('fzf-lua').buffers({
            sort_lastused = true,
            previewer = false,
          })
        end,
        desc = 'Search buffers'
      },
      {
        "<space>f",
        function()
          require('fzf-lua').lines()
        end,
        desc = 'Search buffer lines'
      },
      {
        "<space>e",
        function()
          require('fzf-lua').lsp_document_symbols({
            regex_filter = function(item)
              return not item.text:find("Variable")
            end,
            symbol_style = 3,
          })
        end,
        desc = 'Search document symbols'
      },
      {
        "<space>d",
        function()
          ra_flycheck();
          require('fzf-lua').diagnostics_workspace({
            previewer = false,
            severity_only = 1,
            winopts = {
              split = "belowright new",
            },
          })
        end,
        desc = 'Search workspace diagnostics'
      },
      {
        "<space>s",
        function()
          require('fzf-lua').lsp_live_workspace_symbols({
            regex_filter = function(item)
              -- Limit to structs, enums, and traits.
              -- Hacky, but it looks like types from proc macros
              -- always have a `col` of 1, and explicitly-defined
              -- types don't.
              --
              -- To check what else we could filter on:
              --   vim.print(item)
              return
                item.col ~= 1
                -- Filter out leptos proc macro expansions.
                -- NOTE: Not necessary if the `col` hack is working.
                -- not (item.text:match("Builder$")
                --   or item.text:match("Props$")
                --   or item.text:match("PropsBuilder"))
                and
                  (item.kind == "Struct"
                  or item.kind == "Enum"
                  or item.kind == "Interface")
            end,
            symbol_style = 3,
          })
        end,
        desc = 'Search workspace diagnostics'
      },
      {
        "<space>r",
        function()
          require('fzf-lua').lsp_references()
        end,
        desc = 'Find references for word under cursor'
      },
    },
  },
}

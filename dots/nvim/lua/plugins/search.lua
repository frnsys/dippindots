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
        },
        grep = {
          formatter = "path.filename_first",
          rg_opts = "--no-heading --line-number --column --color=always --colors 'match:fg:0xff,0x5c,0x5c' --smart-case --max-columns=4096 -e",
        },
        previewers = {
          bat = {
            cmd   = "bat",
            args  = "--color=always --style=plain",
            theme = '1337',
          },
        },
        winopts = {
          fullscreen = true,
          border = "none",
          preview = {
            default = "bat",
            layout = "horizontal",
            border = "border-left",
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
        "&",
        function()
          require('fzf-lua').files()
        end,
        desc = 'Search files by name'
      },
      {
        "<tab>",
        function()
          require('fzf-lua').live_grep_glob()
        end,
        desc = 'Search by grep'
      },
      {
        "#",
        function()
          require('fzf-lua').grep_cword()
        end,
        desc = 'Grep current word'
      },
      {
        "Y",
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
            severity_only = 1,
          })
        end,
        desc = 'Search workspace diagnostics'
      },
      {
        "T",
        function()
          require('fzf-lua').blines({
            winopts = {
              preview = { hidden = true }
            }
          })
        end,
        desc = 'Search current buffer lines'
      },
      {
        "L",
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
                and
                  (item.kind == "Struct"
                  or item.kind == "Enum"
                  or item.kind == "Interface")
            end,
            symbol_style = 3,
          })
        end,
        desc = 'Search workspace symbols'
      },
      {
        "R",
        function()
          require('fzf-lua').lsp_references()
        end,
        desc = 'Find references for word under cursor'
      },
    },
  },
}

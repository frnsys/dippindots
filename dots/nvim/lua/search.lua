vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/elanmed/fzf-lua-frecency.nvim",
})

local function ra_flycheck()
  local clients = vim.lsp.get_clients({
    name = 'rust_analyzer',
  })
  for _, client in ipairs(clients) do
    local params = vim.lsp.util.make_text_document_params()
    client.notify('rust-analyzer/runFlycheck', params)
  end
end

local function get_root()
  return require("fzf-lua").path.git_root({}, true) or vim.loop.cwd()
end

local function search_files()
  require('fzf-lua-frecency').frecency({
    cwd_only = true,
    cwd = get_root(),
    display_score = false,
    fzf_opts = { ["--scheme"] = "path", ["--tiebreak"] = "index" },
    previewer = false,
    formatter = "path.dirname_first",
    winopts = {
      fullscreen = false,
      width = 64,
      col = 0.5,
    }
  })
end

-- Auto-launch fzf-lua when opening a directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    -- If nvim was started with a directory
    if vim.fn.isdirectory(data.file) == 1 then
      search_files()
    end
  end
})

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
    formatter = "path.dirname_first",
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

--- Search files by name
vim.keymap.set("n", "-", search_files)

--- Open buffers
vim.keymap.set("n", "<c-t>", function()
  require('fzf-lua').buffers({
    winopts = {
      preview = { hidden = true },
      fullscreen = false,
      width = 64,
      col = 0.5,
    }
  })
end)

--- Grep current word
vim.keymap.set("n", "&", function()
  require('fzf-lua').grep_cword({
    cwd = get_root(),
  })
end)

--- Search by grep
vim.keymap.set("n", "j", function()
  require('fzf-lua').live_grep({
    cwd = get_root(),
  })
end)

--- Resume grep search
vim.keymap.set("n", "J", function()
  require('fzf-lua').live_grep({
    resume = true,
    cwd = get_root(),
  })
end)

--- Grep open buffer lines
vim.keymap.set("n", "\\", function()
  require('fzf-lua').lines({
    winopts = {
      preview = { hidden = true }
    }
  })
end)

--- Find references for word under cursor
vim.keymap.set("n", "R", require('fzf-lua').lsp_references)

--- Search workspace diagnostics
vim.keymap.set("n", "<c-d>", function()
  ra_flycheck();
  require('fzf-lua').diagnostics_workspace({
    severity_only = 1,
  })
end)

--- Warnings
vim.keymap.set("n", ",w", function()
  require('fzf-lua').diagnostics_workspace({
    severity_only = 2,
  })
end)

--- Search symbols
vim.keymap.set("n", "+", function()
  if vim.bo.filetype == "markdown" then
    require('fzf-lua').lsp_document_symbols({
      fzf_opts = {
        -- Necessary to stop tabs from messing up indent levels.
        ['--tabstop'] = '1',
      },
      symbol_fmt = function(s, opts) return "" end,
      winopts = {
        fullscreen = false,
      },
    })
  else
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
        or item.kind == "Key"
        or item.kind == "Enum"
        or item.kind == "EnumMember"
        or item.kind == "Function"
        or item.kind == "Interface"
        or item.kind == "Object")
      end,
      symbol_style = 3,
    })
  end
end)

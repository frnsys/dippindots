vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua"
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

-- Auto-launch fzf-lua when opening a directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    -- If nvim was started with a directory
    if vim.fn.isdirectory(data.file) == 1 then
      require('fzf-lua').files({
        cwd = require("fzf-lua").path.git_root({}),
        cmd = "rg --files --hidden --ignore --glob='!.git'",
        fzf_opts = { ["--scheme"] = "path", ["--tiebreak"] = "index" },
        winopts = {
          fullscreen = false,
          width = 64,
          col = 0.5,
        }
      })
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
vim.keymap.set("n", "-", function()
  require('fzf-lua').files({
    cwd = require("fzf-lua").path.git_root({}, true),

    -- Modified command which puts current dir descendents up top
    cmd = (function()
      local base = "rg --files --hidden --ignore --glob '!.git'"

      -- root of the project
      local root = require("fzf-lua").path.git_root({}, true)

      -- no git root, use current dir
      if not root or #root == 0 then
        return base
      end

      -- dir of the current buffer relative to root
      local curfile = vim.api.nvim_buf_get_name(0)
      local curdir = vim.fn.fnamemodify(curfile, ":h")
      local rel = curdir:gsub("^" .. vim.pesc(root) .. "/?", "")

      -- escaping and whatnot
      local rel_ere = rel:gsub("([%%%[%]().*^$?+|{}\\-])", "\\%1")
      local pfx     = "^" .. rel_ere .. "/"
      local pfx_q   = vim.fn.shellescape(pfx)

      -- at root, so use unmodified command
      if rel == "" then
        return base
      end

      -- build rg command
      -- output files, but prepend ones under current dir with "0 " and others with "1 "
      -- then sort, then strip the prefix
      return table.concat({
        base,
        "awk -v p=" .. pfx_q .. " '{print (($0 ~ p)?\"0 \":\"1 \") $0}'",
        "sort -k1,1",
        "cut -d' ' -f2-",
      }, " | ")
    end)(),
    fzf_opts = { ["--scheme"] = "path", ["--tiebreak"] = "index" },
    winopts = {
      fullscreen = false,
      width = 64,
      col = 0.5,
    }
  })
end)

--- Grep current word
vim.keymap.set("n", "&", function()
  require('fzf-lua').grep_cword({
    cwd = require("fzf-lua").path.git_root({})
  })
end)

--- Search by grep
vim.keymap.set("n", "j", function()
  require('fzf-lua').live_grep({
    cwd = require("fzf-lua").path.git_root({})
  })
end)

--- Resume grep search
vim.keymap.set("n", "J", function()
  require('fzf-lua').live_grep({
    resume = true,
    cwd = require("fzf-lua").path.git_root({})
  })
end)

--- Grep buffer lines
vim.keymap.set("n", "\\", function()
  require('fzf-lua').blines({
    winopts = {
      preview = { hidden = true }
    }
  })
end)

--- Search workspace diagnostics
vim.keymap.set("n", "D", function()
  ra_flycheck();
  require('fzf-lua').diagnostics_workspace({
    severity_only = 1,
  })
end)

--- Find references for word under cursor
vim.keymap.set("n", "R", require('fzf-lua').lsp_references)

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

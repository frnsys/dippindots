--- LSP status
vim.pack.add({
  "https://github.com/j-hui/fidget.nvim",
})
require("fidget").setup({
  notification = {
    override_vim_notify = true,
  },
})

-- https://github.com/neovim/neovim/issues/23291
local ok, wf = pcall(require, "vim.lsp._watchfiles")
if ok then
  -- disable lsp watcher. Too slow on linux
  wf._watchfunc = function()
    return function() end
  end
end

--- Lower priority for LSP semantic token highlighting.
vim.highlight.priorities.semantic_tokens = 95

--- Completion settings:
--- * show menu
--- * show popup with more info
--- * don't auto-insert the first match
vim.o.completeopt = "menuone,noinsert"
vim.o.pumheight = 10        -- Max height of completion menu.
vim.o.winborder = "single"  -- Single border on all floating windows.

--- Manually trigger completion if needed.
vim.keymap.set('i', '<c-n>', function()
  local function feedkeys(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
  end

  -- Is the completion menu open?
  local pumvisible = tonumber(vim.fn.pumvisible()) ~= 0
  if pumvisible then
    feedkeys '<C-n>'
  else
    if next(vim.lsp.get_clients { bufnr = 0 }) then
      vim.lsp.completion.get()
    else
      if vim.bo.omnifunc == '' then
        feedkeys '<C-x><C-n>'
      else
        feedkeys '<C-x><C-o>'
      end
    end
  end
end)

--- Accept current completion.
vim.keymap.set('i', '<c-e>', '<c-y>')

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    client.server_capabilities.completionProvider.triggerCharacters =
      vim.split("qwertyuiopasdfghjklzxcvbnm. @/[", "")
    vim.lsp.completion.enable(true,
      ev.data.client_id, ev.buf, {
        autotrigger = true,
        convert = function(item)
          return {
            -- Remove function params to save space.
            abbr = item.label:gsub('%b()', ''),

            -- Also remove the "Method", "Function", etc column.
            kind = "",
          }
        end,
      })

    local bind = function(desc, keys, func)
      vim.keymap.set('n', keys, func,
      { buffer = ev.buf, desc = desc, noremap = true })
    end

    bind("Go to previous diagnostic message",
      '<c-l>', function()
        vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
      end)
    bind("Go to next diagnostic message",
      '<c-c>', function()
        vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
      end)
    bind('Code action',
      'tr', function()
        vim.lsp.buf.code_action({
          -- Filter out code actions I never use
          -- and often crowd the list.
          filter = function(action)
            local title = vim.fn.trim(action.title)
            return not vim.startswith(title, "Generate delegate")
          end,
        })
      end)
    bind('Hover documentation',
      'tt', vim.lsp.buf.hover)
    bind('Go to definition',
      'ts', vim.lsp.buf.definition)
    bind('Rename symbol',
      'tw', vim.lsp.buf.rename)
    bind('Show diagnostics',
      'tn', function()
        vim.diagnostic.open_float(0, { scope = "line", focus = false })
      end)

    vim.keymap.set('v', "<c-u>", function() vim.lsp.buf.selection_range(1) end,
      { buffer = ev.buf, desc = desc, noremap = true })
    vim.keymap.set('v', "<c-o>", function() vim.lsp.buf.selection_range(-1) end,
      { buffer = ev.buf, desc = desc, noremap = true })

    -- Format on write
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = ev.buf,
      callback = function()
        vim.lsp.buf.format()
      end
    })
  end,
})

vim.lsp.config["rust"] = {
  filetypes = { 'rust' },
  root_markers = { ".git", "Cargo.lock" },
  cmd = { "rustup", "run", "nightly", "rust-analyzer" },
  settings = {
    ["rust-analyzer"] = {
      check = {
        -- Ignore tests when flychecking.
        allTargets = false,
      },
      files = {
        excludeDirs = {
          ".git",
          ".cargo",
          ".direnv",
          "node_modules",
          "target",
        },
      },
      completion = {
        -- Don't really use this;
        -- would use my own snippets instead
        postfix = {
          enable = false
        },

        -- Show private fields in completion
        privateEditable = {
          enable = true,
        },
      },
      workspace = {
        symbol = {
          search = {
            -- Or "all_symbols".
            kind = "only_types",
          },
        },
      },
    }
  }
}
vim.lsp.enable('rust')

-- pip install ty
vim.lsp.config["python"] = {
  cmd = { "ty", "server" },
  filetypes = { "python" },
  root_markers = {
    "requirements.txt",
    "pyproject.toml",
    "mise.toml",
    ".git",
  },
  settings = {
    ty = {
      diagnosticMode = "workspace",
    }
  },
}
vim.lsp.enable('python')

vim.lsp.config["markdown"] = {
  cmd = { '/usr/local/bin/marksman', 'server' },
  filetypes = { "markdown" },
  root_markers = { ".git" },
  single_file_support = true,
}
vim.lsp.enable('markdown')

require('gliss/unity')

vim.filetype.add({
  extension = {
    script = "verses",
  },
})
vim.lsp.config["verses"] = {
  -- Debugging
  -- cmd = { '/home/francis/projects/fugue/lib/target/debug/verses', 'lsp' },
  cmd = { 'verses', 'lsp' },
  filetypes = { "verses" },
  root_markers = { ".git" },
}
vim.lsp.enable('verses')

-- Show errors and warnings in a floating window
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        -- Skip if another floating window is open
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
                return
            end
        end
        -- Show diagnostics if no other floating windows are present
        vim.diagnostic.open_float(nil, { focusable = false, source = true })
    end,
})


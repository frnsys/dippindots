-- https://github.com/neovim/neovim/issues/23291
local ok, wf = pcall(require, "vim.lsp._watchfiles")
if ok then
  -- disable lsp watcher. Too slow on linux
  wf._watchfunc = function()
    return function() end
  end
end

--- Completion settings:
--- * show menu
--- * show popup with more info
--- * use fuzzy matching
--- * don't auto-insert the first match
vim.o.completeopt = "menu,menuone,fuzzy,noinsert,popup"
vim.o.pumheight = 10        -- Max height of completion menu.
vim.o.winborder = "single"  -- Single border on all floating windows.

--- Manually trigger completion if needed.
vim.keymap.set('i', '<C-n>', function()
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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(ev)
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
      '<<', vim.diagnostic.goto_prev)
    bind("Go to next diagnostic message",
      '>>', vim.diagnostic.goto_next)
    bind('Code action',
      'ga', function()
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
      'gw', vim.lsp.buf.hover)
    bind('Go to definition',
      'gd', vim.lsp.buf.definition)
    bind('Rename symbol',
      'gr', vim.lsp.buf.rename)

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

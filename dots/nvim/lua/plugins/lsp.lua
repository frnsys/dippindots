-- https://github.com/neovim/neovim/issues/23291
local ok, wf = pcall(require, "vim.lsp._watchfiles")
if ok then
  -- disable lsp watcher. Too slow on linux
  wf._watchfunc = function()
    return function() end
  end
end

return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      vim.diagnostic.config({
        float = {
          border = "single"
        }
      })
      local handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
      }

      --- Diagnostic keymaps
      vim.keymap.set('n', ',,', vim.diagnostic.goto_prev,
        { desc = "Go to previous diagnostic message" })
      vim.keymap.set('n', '..', vim.diagnostic.goto_next,
        { desc = "Go to next diagnostic message" })

      --- LSP settings.
      --- This function gets run when an LSP connects to a particular buffer.
      local on_attach = function(client, bufnr)
        local bind = function(desc, keys, func)
          vim.keymap.set('n', keys, func,
            { buffer = bufnr, desc = desc, noremap = true })
        end

        bind('Rename symbol',
          'gr', vim.lsp.buf.rename)
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

        --- Format on write
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format()
          end
        })
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      --- Use my copy of rust-analyzer, to ensure consistency
      require('lspconfig').rust_analyzer.setup({
        handlers = handlers,
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'rust' },
        cmd = { "rustup", "run", "nightly", "rust-analyzer" },
        settings = {
          ["rust-analyzer"] = {
            numThreads = 4,
            cargo = {
              allFeatures = true,
              extraArgs = { "--jobs", "4" },
            },

            files = {
              excludeDirs = {
                ".cargo",
                ".direnv",
                ".git",
                "node_modules",
                "target",
              },
            },

            -- Ignore tests when flychecking.
            check = {
              allTargets = false,
            },

            completion = {
              -- Don't really use this;
              -- would use my own snippets instead
              postfix = {
                enable = false
              },

              -- Show private fields
              -- in completion
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

            checkOnSave = true,
            diagnostics = {
              enable = true,
              experimental = {
                enable = true,
              },
            },
          },
        },
      })

      --- Omnisharp/C#/Unity
      local pid = vim.fn.getpid()
      local omnisharp_bin = "/opt/omnisharp-roslyn/run"
      require('lspconfig').omnisharp.setup {
        handlers = handlers,
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'cs' },
        flags = {
          debounce_text_changes = 150,
        },
        cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
      }
    end
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000, -- needs to be loaded in first
    config = function()
      require('tiny-inline-diagnostic').setup({
        preset = "simple",
      })
      vim.diagnostic.config({ virtual_text = true })
    end
  },
  {
    "j-hui/fidget.nvim",
    opts = {},
  },

  {
    -- NOTE: If something breaks with the binary, you can recompile it:
    -- cd /home/francis/.local/share/nvim/lazy/blink.cmp
    -- cargo build --release
    'saghen/blink.cmp',
    enabled = true,
    lazy = false, -- lazy loading handled internally
    version = 'v0.*',
    opts = {
      keymap = {
        ['<c-p>'] = { 'select_prev' },
        ['<c-n>'] = { 'select_next' },
        ['<c-d>'] = { 'scroll_documentation_up' },
        ['<c-f>'] = { 'scroll_documentation_down' },
      },
      completion = {
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        accept = {
          auto_brackets = { enabled = true }
        },
        menu = {
          auto_show = true,
          draw = {
            columns = {
              { "label", "label_description", gap = 1 }
            },
          }
        }
      },
    }
  },
}

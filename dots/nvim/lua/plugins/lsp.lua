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
      vim.keymap.set('n', ',d', vim.diagnostic.goto_prev,
        { desc = "Go to previous diagnostic message" })
      vim.keymap.set('n', '.d', vim.diagnostic.goto_next,
        { desc = "Go to next diagnostic message" })

      --- LSP settings.
      --- This function gets run when an LSP connects to a particular buffer.
      local on_attach = function(client, bufnr)
        local bind = function(desc, keys, func)
          vim.keymap.set('n', keys, func,
            { buffer = bufnr, desc = desc })
        end

        bind('Rename symbol',
          'gr', vim.lsp.buf.rename)
        bind('Code action',
          'ga', vim.lsp.buf.code_action)
        bind('Hover documentation',
          'gw', vim.lsp.buf.hover)
        bind('Signature documentation',
          'gs', vim.lsp.buf.signature_help)
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

      --- Create a command to open docs for thing under cursor
      --- in rust.
      vim.api.nvim_create_user_command("OpenDocs", function()
        vim.lsp.buf_request(vim.api.nvim_get_current_buf(),
          'experimental/externalDocs',
          vim.lsp.util.make_position_params(),
          function(err, url)
            if err then
              error(tostring(err))
            elseif url['local'] ~= nil then
              vim.cmd([[!qutebrowser ]] .. vim.fn.fnameescape(url['local']))
            else
              vim.print('No documentation found')
            end
          end)
      end, {})
      vim.keymap.set('n',
        'gh', function() vim.cmd('OpenDocs') end,
        { desc = "Open rust docs" })

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
              snippets = {
                custom = {}
              },

              -- Show private fields
              -- in completion
              privateEditable = {
                enable = true,
              },
            },

            checkOnSave = false,
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
    "folke/trouble.nvim",
    opts = {
      icons = {},
      warn_no_results = false, -- show a warning when there are no results
      open_no_results = true,  -- open the trouble window when there are no results
      action_keys = {
        close = "q",                   -- close the list
        cancel = "<esc>",              -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r",                 -- manually refresh
        open_split = { "_" },          -- open buffer in new split
        open_vsplit = { "|" },         -- open buffer in new vsplit
        open_tab = { "<c-t>" },        -- open buffer in new tab
        jump_close = { "o", "<cr>" },  -- jump to the diagnostic and close the list
        switch_severity = "s",         -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
        toggle_preview = "P",          -- toggle auto_preview
        preview = "p",                 -- preview the diagnostic location
        open_code_href = "c",          -- if present, open a URI with more information about the diagnostic error
        previous = "k",                -- previous item
        next = "j",                    -- next item
        help = "?"                     -- help menu
      },
    },
    keys = {
      {
        "<leader>d",
        function()
          local clients = vim.lsp.get_clients({
            name = 'rust_analyzer',
          })
          for _, client in ipairs(clients) do
            local trouble = require("trouble");
            if trouble.is_open() then
              trouble.close()
            else
              local params = vim.lsp.util.make_text_document_params()
              client.notify('rust-analyzer/runFlycheck', params)
              require("trouble").open({
                mode = "diagnostics",
                filter = {
                  severity = vim.diagnostic.severity.ERROR
                },
                win = {
                  position = "bottom"
                }
              })
            end
          end
        end,
        desc = 'List diagnostics'
      },
    }
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = function()
      require('tiny-inline-diagnostic').setup()
    end
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
        ['<c-x>'] = { 'show', 'hide' },
        ['<c-space>'] = { 'accept' },
        ['<c-p>'] = { 'select_prev' },
        ['<c-n>'] = { 'select_next' },
        ['<c-d>'] = { 'scroll_documentation_up' },
        ['<c-f>'] = { 'scroll_documentation_down' },
        ['<c-;>'] = { 'snippet_forward' },
        ['<c-l>'] = { 'snippet_backward' },
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

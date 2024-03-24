--- Keymap prefix: g

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        'j-hui/fidget.nvim',
        branch = "legacy",
        opts = {}
      },
    },
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
      vim.keymap.set('n', 'd[', vim.diagnostic.goto_prev,
        { desc = "Go to previous diagnostic message" })
      vim.keymap.set('n', 'd]', vim.diagnostic.goto_next,
        { desc = "Go to next diagnostic message" })
      vim.keymap.set('n', 'dm', function()
          vim.diagnostic.open_float({ scope = "cursor" })
        end,
        { desc = "Open floating diagnostic message" })

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

        -- Semantic tokens not well supported,
        -- suggested to have it disabled for now.
        client.server_capabilities.semanticTokensProvider = nil
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
              vim.cmd([[!firefox ]] .. vim.fn.fnameescape(url['local']))
            else
              vim.print('No documentation found')
            end
          end)
      end, {})
      vim.keymap.set('n',
        'gh', function() vim.cmd('OpenDocs') end,
        { desc = "Open rust docs" })

      --- Enable the following language servers
      local servers = {
        pyright = {},
        marksman = {},
        rust_analyzer = {
          ["rust-analyzer"] = {
            numThreads = 4,

            completion = {
              limit = 50,

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

            cachePriming = {
              enable = false,
            },

            -- Disable check on save,
            -- instead trigger manually
            checkOnSave = {
              command = "clippy",
              extraArgs = {
                "--target-dir=target/analyzer"
              }
            },
          },
        },
        tsserver = {},
        cssls = {},
      }

      require('lspconfig').rust_analyzer.setup({
        cmd = { "rustup", "run", "nightly", "rust-analyzer" },
      })

      --- Ensure the servers above are installed
      local mason_lspconfig = require 'mason-lspconfig'
      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      mason_lspconfig.setup_handlers {
        function(server_name)
          --- nvim-cmp supports additional completion capabilities, so broadcast that to servers
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

          --- Open local docs instead of internet docs
          -- if server_name == "rust_analyzer" then
          --   capabilities['experimental'] = { ['localDocs'] = true }
          -- end

          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            handlers = handlers,
          }
        end,
      }

      --- Omnisharp/C#/Unity
      local pid = vim.fn.getpid()
      -- local omnisharp_bin = "/opt/omnisharp-roslyn/run"
      require('lspconfig').omnisharp_mono.setup {
        on_attach = on_attach,
        handlers = handlers,
        flags = {
          debounce_text_changes = 150,
        },
        -- cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
      }
    end
  },
  {
    "folke/trouble.nvim",
    opts = {
      icons = false,
      position = "top",
      severity = vim.diagnostic.severity.ERROR,
      signs = {
        error = "(X)",
        warning = "(!)",
        hint = "(?)",
        information = "(?)"
      },
      action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q",                                 -- close the list
        cancel = "<esc>",                            -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r",                               -- manually refresh
        jump = { "<cr>", "<tab>", "<2-leftmouse>" }, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" },                    -- open buffer in new split
        open_vsplit = { "<c-v>" },                   -- open buffer in new vsplit
        open_tab = { "<c-t>" },                      -- open buffer in new tab
        jump_close = { "o" },                        -- jump to the diagnostic and close the list
        toggle_mode = "m",                           -- toggle between "workspace" and "document" diagnostics mode
        switch_severity = "s",                       -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
        toggle_preview = "P",                        -- toggle auto_preview
        hover = "K",                                 -- opens a small popup with the full multiline message
        preview = "p",                               -- preview the diagnostic location
        open_code_href = "c",                        -- if present, open a URI with more information about the diagnostic error
        close_folds = { "zM", "zm" },                -- close all folds
        open_folds = { "zR", "zr" },                 -- open all folds
        toggle_fold = { "zA", "za" },                -- toggle fold of current file
        previous = "k",                              -- previous item
        next = "j",                                  -- next item
        help = "?"                                   -- help menu
      },
    },
    keys = {
      {
        "'d",
        function()
          require("trouble").toggle()
        end,
        desc = 'List diagnostics'
      },
    }
  }
}

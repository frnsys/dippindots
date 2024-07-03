--- Keymap prefix: g

-- https://github.com/neovim/neovim/issues/23725
local ok, wf = pcall(require, "vim.lsp._watchfiles")
if ok then
  -- disable lsp watcher. Too slow on linux
  wf._watchfunc = function()
    return function() end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
});

local function ra_flycheck()
  local clients = vim.lsp.get_clients({
    name = 'rust_analyzer',
  })
  for _, client in ipairs(clients) do
    local params = vim.lsp.util.make_text_document_params()
    client.notify('rust-analyzer/runFlycheck', params)
    require("trouble").open()
  end
end
vim.keymap.set({ 'n' }, ';d', ra_flycheck)

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
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
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      --- Use my copy of rust-analyzer, to ensure consistency
      require('lspconfig').rust_analyzer.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { "rustup", "run", "nightly", "rust-analyzer" },
        settings = {
          ["rust-analyzer"] = {
            numThreads = 4,
            cargo = {
              allFeatures = true,
              extraArgs = { "--jobs", "4" },
            },

            -- Leptos `view!` macro formatting.
            rustfmt = {
              overrideCommand = { "leptosfmt", "-m", "64", "--stdin", "--rustfmt" }
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

            checkOnSave = false,
            diagnostics = {
              enable = true,
              experimental = {
                enable = true,
              },
            },
          },
        },
        handlers = handlers,
      })

      --- Ensure the servers above are installed
      local mason_lspconfig = require 'mason-lspconfig'
      mason_lspconfig.setup {
        ensure_installed = { 'pyright' },
      }

      mason_lspconfig.setup_handlers {
        function(server_name)
          --- nvim-cmp supports additional completion capabilities, so broadcast that to servers
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

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
      local omnisharp_bin = "/opt/omnisharp-roslyn/run"
      require('lspconfig').omnisharp_mono.setup {
        on_attach = on_attach,
        handlers = handlers,
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
      icons = false,
      position = "top",
      severity = vim.diagnostic.severity.ERROR,
      signs = {
        error = "(X)",
        warning = "(!)",
        hint = "(?)",
        information = "(?)"
      },
      action_keys = {
        close = "q",                   -- close the list
        cancel = "<esc>",              -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r",                 -- manually refresh
        open_split = { "_" },          -- open buffer in new split
        open_vsplit = { "|" },         -- open buffer in new vsplit
        open_tab = { "<c-t>" },        -- open buffer in new tab
        jump_close = { "o", "<cr>" },  -- jump to the diagnostic and close the list
        toggle_mode = "m",             -- toggle between "workspace" and "document" diagnostics mode
        switch_severity = "s",         -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
        toggle_preview = "P",          -- toggle auto_preview
        hover = "K",                   -- opens a small popup with the full multiline message
        preview = "p",                 -- preview the diagnostic location
        open_code_href = "c",          -- if present, open a URI with more information about the diagnostic error
        previous = "k",                -- previous item
        next = "j",                    -- next item
        help = "?"                     -- help menu
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

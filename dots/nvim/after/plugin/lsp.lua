vim.diagnostic.config({
  float = {
    border = "single"
  }
})

--- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
  { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
  { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>e', function()
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
    '<leader>rn', vim.lsp.buf.rename)
  bind('Code action',
    '<leader>aa', vim.lsp.buf.code_action)
  bind('Go to definiton',
    'gd', vim.lsp.buf.definition)
  bind('Hover documentation',
    'K', vim.lsp.buf.hover)
  bind('Signature documentation',
    '<C-k>', vim.lsp.buf.signature_help)

  -- Semantic tokens not well supported,
  -- suggested to have it disabled for now.
  client.server_capabilities.semanticTokensProvider = nil
end

--- Enable the following language servers
local servers = {
  pyright = {},
  rust_analyzer = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },
  tsserver = {},
  cssls = {},
}

--- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

--- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

--- Omnisharp/C#/Unity
local pid = vim.fn.getpid()
local omnisharp_bin = "/opt/omnisharp-roslyn/run"
require('lspconfig').omnisharp.setup{
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) };
}

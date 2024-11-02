return {
  {
    -- NOTE: If something breaks with the binary, you can recompile it:
    -- cd /home/francis/.local/share/nvim/lazy/blink.cmp
    -- cargo build --release
    'saghen/blink.cmp',
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
      accept = {
        auto_brackets = { enabled = true }
      },
      trigger = {
        signature_help = { enabled = true }
      },
      windows = {
        documentation = {
          border = "solid"
        },
        signature_help = {
          border = "none"
        },
        autocomplete = {
          selection = "auto_insert",
          draw = "minimal",
        },
      },
    }
  }
}

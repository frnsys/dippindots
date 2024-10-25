return {
  {
    'saghen/blink.cmp',
    lazy = false, -- lazy loading handled internally
    version = 'v0.*',
    opts = {
      keymap = {
        -- show = '<c-space>',
        -- hide = '<c-e>',
        accept = "''",
        select_prev = { '<c-p>' },
        select_next = { '<c-n>' },

        show_documentation = {},
        hide_documentation = {},
        scroll_documentation_up = '<c-d>',
        scroll_documentation_down = '<c-f>',

        snippet_forward = '<Tab>',
        snippet_backward = '<S-Tab>',
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

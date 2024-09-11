return {
  {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'dcampos/nvim-snippy',
      'dcampos/cmp-snippy'
    },
    config = function(plugin, opts)
      local cmp = require('cmp')
      local snippy = require('snippy')
      local opts = {
        snippet = {
          expand = function(args)
            snippy.expand_snippet(args.body)
          end,
        },
        window = {
          documentation = {
            border = 'single',
          }
        },
        preselect = cmp.PreselectMode.None, -- Don't preselect items
        mapping = {
          ['<c-d>'] = cmp.mapping.scroll_docs(-4),
          ['<c-f>'] = cmp.mapping.scroll_docs(4),

          -- Select and confirm the first completion item
          ["''"] = cmp.mapping(function(fallback)
            if not cmp.visible() then
              cmp.complete()
            end
            if not cmp.get_selected_entry() then
              cmp.select_next_item()
            end
            cmp.confirm()
          end, { 'i', 's' }),

          -- Select prev item or start completion
          ['<c-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif snippy.can_jump(-1) then
              snippy.previous()
            else
              cmp.complete()
            end
          end, { 'i', 's' }),

          -- Select next completion option or start completion
          ['<c-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif snippy.can_jump(1) then
              snippy.next()
            else
              cmp.complete()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = 'snippy' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
        }),
      }

      cmp.setup(opts)
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
      })
    end
  }
}

return {
  {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function(plugin, opts)
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local opts = {
        performance = {
          throttle = 30,
          debounce = 60,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
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
            else
              cmp.complete()
            end
          end, { 'i', 's' }),

          -- Select next completion option or start completion
          ['<c-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              cmp.complete()
            end
          end, { 'i', 's' }),

          -- If an entry is selected, complete
          -- otherwise jump to next snippet position
          ['<c-l>'] = cmp.mapping(function(fallback)
            if cmp.get_selected_entry() then
              cmp.confirm()
            elseif luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              cmp.complete()
            end
          end, { 'i', 's' }),

          -- Jump to previous snippet position
          ['<c-h>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' })

        },
        sources = cmp.config.sources({
          { name = 'luasnip' },
          {
            name = 'nvim_lsp',
            keyword_length = 3
          },
          { name = 'nvim_lsp_signature_help' },
        }),
      }

      require('luasnip').setup({
        history = true,
        update_events = "TextChanged,TextChangedI",
      })
      require('cmp').setup(opts)
      require('snippets')

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
      })
    end
  }
}

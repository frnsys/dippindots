local cmp = require('cmp')
local luasnip = require('luasnip')

luasnip.setup({
	history = true,
	update_events = "TextChanged,TextChangedI",
})

cmp.setup({
  performance = {
    throttle = 0,
    debounce = 0,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  preselect = cmp.PreselectMode.None, -- Don't preselect items
  mapping = cmp.mapping.preset.insert {
    ['<c-d>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),

    -- Select and confirm the first completion item
    ['<leader><leader>'] = cmp.mapping(function(fallback)
      if not cmp.visible() then
        cmp.complete()
      end
      if not cmp.get_selected_entry() then
        cmp.select_next_item()
      end
      cmp.confirm()
    end, { 'i', 's' }),

    -- Select prev item or start completion
    ['<c-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        cmp.complete()
      end
    end, { 'i', 's' }),

    -- Select next completion option
    ['<c-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
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
        fallback()
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
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'buffer', keyword_length = 3 },
  },
})

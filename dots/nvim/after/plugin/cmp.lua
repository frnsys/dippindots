local cmp = require('cmp')
local luasnip = require('luasnip')

luasnip.setup({
	history = true,
	update_events = "TextChanged,TextChangedI",
})

cmp.setup({
  performance = {
    throttle = 0
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

    -- Confirm the currently selected completion item
    ['<cr>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },

    -- Select and confirm the first completion item
    ['<leader><leader>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if not cmp.get_selected_entry() then
            cmp.select_next_item()
        end
        cmp.confirm()
      else
        fallback()
      end
    end, { 'i', 's' }),

    -- Either select next previous completion option
    -- or jump to next position in snippet
    ['<c-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { 'i', 's' }),

    -- Either select previous completion option
    -- or jump to previous position in snippet
    ['<c-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'buffer', keyword_length = 3 },
  },
})

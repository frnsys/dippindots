local cmp = require('cmp')
local luasnip = require('luasnip')

luasnip.setup({
	history = true,
	update_events = "TextChanged,TextChangedI",
})

local s = luasnip.s
local i = luasnip.insert_node
local f = luasnip.function_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

-- i(1) means insert at the first position
-- i(0) means insert at the last position
luasnip.add_snippets("all", {
    -- Insert current datetime
    s("now", f(function()
        return os.date("%m.%d.%Y %H:%M")
    end))
})
luasnip.add_snippets("html", {
    s("<a>", fmt("<a href=\"{}\">{}</a>", { i(1), i(2) } ))
})
luasnip.add_snippets("cs", {
    s("log", fmt("Debug.Log(\"{}\");", { i(1) })),
    s("logv", fmt("Debug.Log(\"{}: \" + {});", { i(1), i(2) })),
})
luasnip.add_snippets("rust", {
    s("tests", fmt([[
        #[cfg(test)]
        mod tests {{
            use super::*;

            {}
        }}
    ]], { i(0) } )),

    s("test", fmt([[
        #[test]
        fn test_{}() {{
            {}
        }}
    ]], { i(1), i(0) }))
})

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  preselect = cmp.PreselectMode.None, -- Don't preselect items
  mapping = cmp.mapping.preset.insert {
    ['<c-p>'] = cmp.mapping.select_prev_item(),
    ['<c-d>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-n>'] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_next_item()
		else
			cmp.complete {}
		end
	end, {"i","s" }),
    ['<cr>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    ['<c-k>'] = cmp.mapping(function(fallback)
      -- <c-n> selects without confirming,
      -- <c-k> selects and confirms first
      -- and then expand it
      if cmp.visible() then
        if not cmp.get_selected_entry() then
            cmp.select_next_item()
        end
        cmp.confirm()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
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

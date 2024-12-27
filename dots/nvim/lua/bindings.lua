local function _(modes, key, cmd)
  vim.keymap.set(modes, key, cmd, {
    noremap = true,
    silent = true,
  })
end

--- Easier text objects
---
--- Notes:
--- * Not using `p` b/c it's already "paragraph"
--- * Not using `b` b/c it's already "block"
--- * Not using `s` b/c it's already "sentence"
--- * Avoid `hjkl` and other operator keys, e.g. `t`, `/`
--- * Make sure these don't conflict with the
---   mappings in `plugins/treesitter.lua`
local remappings = {
  { "c", "(", ")" },
  { "r", "[", "]" },
  { "z", "{", "}" },
  { "q", '"', '"' },
}
for i, map in ipairs(remappings) do
  local key = map[1]
  local target = map[2]
  local target_close = map[3]

  -- Around
  _({"o", "v"}, "a" .. key, "a" .. target)

  -- Inside
  _({"o", "v"}, "i" .. key, "i" .. target)

  -- To
  _({"o", "v"}, "t" .. key, "t" .. target_close)

  -- Convenience binding that assumes "inside"
  _({"o", "v"}, key, "i" .. target)

  -- Convenience jump to
  _("n", "." .. key, "/" .. target .. "<cr><cmd>noh<cr>")
  _("n", "," .. key, "?" .. target .. "<cr><cmd>noh<cr>")
end

--- To next empty line
_({"o", "v", "n"}, "<space>", "}")

--- Easier jumping between matching brackets
_({"n", "o"}, ",.", "%")
_({"n", "o"}, ".,", "%")

--- Tabs
_("n", "T", ":tabnew<cr>")
_("n", "L", ":tabnext<cr>")
_("n", "H", ":tabprevious<cr>")

--- Bind return to clear last search highlight.
_("n", "<cr>", ":noh<cr>")

--- Toggle b/w alternative buffer
_("n", "<bs>", "<c-^>")

--- Bind jk/kj to escape
_("i", "jk", "<esc>")
_("i", "jk", "<esc>")

--- Don't leave visual mode when changing indent
_("x", ">", ">gv")
_("x", "<", "<gv")

--- Expand/contract visual selection symmetrically
_("v", "<c-k>", "j$ok0o")
_("v", "<c-j>", "k$oj0o")

--- Easily restore last visual selection with `vv`
_("n", "vv", "gv")

--- Keep search results in the screen center
_("n", "n", "nzz")
_("n", "N", "Nzz")

--- Quickfix navigation
_("n", "<c-n>", ":cnext<cr>")
_("n", "<c-p>", ":cprev<cr>")

--- Terminals
_("n", ",t", ":ToggleTerm<cr>")
_("t", "<esc>", "<c-\\><c-n>")

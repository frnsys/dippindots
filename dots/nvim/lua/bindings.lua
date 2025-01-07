local function _(key, cmd, modes)
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
  { "i", '"', '"' },
}
for i, map in ipairs(remappings) do
  local key = map[1]
  local target = map[2]
  local target_close = map[3]

  -- Around
  _("a" .. key, "a" .. target, {"o", "v"})

  -- Inside
  _("i" .. key, "i" .. target, {"o", "v"})

  -- To
  _("t" .. key, "t" .. target_close, {"o", "v"})

  -- Convenience binding that assumes "inside"
  -- _(key, "i" .. target, {"o", "v"})

  -- Convenience jump to
  _("." .. key, "/" .. target .. "<cr><cmd>noh<cr>", "n")
  _("," .. key, "?" .. target .. "<cr><cmd>noh<cr>", "n")
end

--- To next empty line
_("<space>", "}", {"o", "v", "n"})

--- Easier jumping between matching brackets
_(",.", "%", {"n", "o"})
_(".,", "%", {"n", "o"})

--- Tabs
_("T", ":tabnew<cr>", "n")
_("L", ":tabnext<cr>", "n")
_("H", ":tabprevious<cr>", "n")

--- Bind return to clear last search highlight.
_("<cr>", ":noh<cr>", "n")

--- Toggle b/w alternative buffer
_("<bs>", "<c-^>", "n")

--- Bind jk/kj to escape
_("jk", "<esc>", "i")
_("jk", "<esc>", "i")

--- Don't leave visual mode when changing indent
_(">", ">gv", "x")
_("<", "<gv", "x")

--- Expand/contract visual selection symmetrically
_("<c-k>", "j$ok0o", "v")
_("<c-j>", "k$oj0o", "v")

--- Easily restore last visual selection with `vv`
_("vv", "gv", "n")

--- Keep search results in the screen center
_("n", "nzz", "n")
_("N", "Nzz", "n")

--- Quickfix navigation
_("<c-n>", ":cnext<cr>", "n")
_("<c-p>", ":cprev<cr>", "n")

--- Terminals
_(",t", ":ToggleTerm<cr>", "n")
_("<esc>", "<c-\\><c-n>", "t")

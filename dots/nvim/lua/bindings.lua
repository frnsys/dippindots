--- Important keybinds:
---
--- # Movement
--- - { and } for moving b/w paragraphs
--- - ( and ) for moving b/w functions
--- - [ and ] for moving b/w classes
--- - .m and ,m for moving b/w blocks
--- - w and b for moving across identifiers
--- - W and B for moving across 2x identifiers
---
--- # Objects
--- - iu/au for any quote
--- - io/ao for any bracket
--- - ii/ai for lines w/ matching indentation
--- - ia/aa for a parameter or list item
--- - if/af for a function
--- - im/am for a block
--- - n for up to last char of line
--- - Q for up to next quote
--- - C for up to next bracket
--- - R for rest of lines w/ matching indentation

local function _(key, cmd, modes, remap)
  if remap == nil then
    remap = false
  end
  vim.keymap.set(modes, key, cmd, {
    remap = remap,
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
---   mappings in `plugins/motion.lua`
local remappings = {
  { "c", "(", ")" },
  { "r", "[", "]" },
  { "z", "{", "}" },
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
end

--- Tabs
_("T", ":tabnew<cr>", "n")
_("L", ":tabnext<cr>", "n")
_("H", ":tabprevious<cr>", "n")

--- Bind return to clear last search highlight.
_("<cr>", ":noh<cr>", "n")

--- Bind jk/kj to escape
_("jk", "<esc>", "i")
_("jk", "<esc>", "i")

--- Commenting
_("<leader>x", "gcc", "n", true)
_("<leader>x", "gc", "v", true)

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

--- Remap `"` to `?` as it matches my custom kbd layout.
_('"', '?', "n")

--- Insert common strings
_('<c-r>', ' {<cr>}<Esc>O', "i")
_('<c-t>', ' -> ', "i")
_('<c-e>', ' => ', "i")
_('<c-z>', 'println!("{:?}", );<Left><Left>', "i")
_('<c-b>', 'dbg!();<Left><Left>', "i")
_('<c-v>', '{:?}', "i")

--- Delete previous word
_('<c-backspace>', '<c-w>', "i")

--- Splits
_("|", ":vsplit<cr>", "n")
_("_", ":split<cr>", "n")

--- Since quote is used as the leader key,
--- this avoids conflicts with its default binding.
vim.keymap.set('n', "'", "<nop>")

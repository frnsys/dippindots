local function _(key, cmd, modes, remap)
  if remap == nil then
    remap = false
  end
  vim.keymap.set(modes, key, cmd, {
    remap = remap,
    silent = true,
  })
end

--- Tabs
_("T", ":tabnew<cr>", "n")
_("L", ":tabnext<cr>", "n")
_("H", ":tabprevious<cr>", "n")

--- Bind return to clear last search highlight.
_("<cr>", ":noh<cr>", "n")

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

--- Insert common strings
_('<c-t>', ' {<cr>}<Esc>O', "i")
_('<c-r>', ' ->', "i")
_('<c-e>', ' =>', "i")
_('<c-z>', 'println!("{:?}", );<Left><Left>', "i")
_('<c-b>', 'dbg!();<Left><Left>', "i")
_('<c-v>', 'Vec<_>', "i")
_('<c-o>', '{:?}', "i")
_('<c-k>', '<><Left>', "i")

_('<c-l>', '<Right>', "i")
_('<c-h>', '<Left>', "i")

--- Delete previous word
_('<c-backspace>', '<c-w>', "i")

--- Splits
_("|", ":vsplit<cr>", "n")
_("_", ":split<cr>", "n")

--- Modify `{` and `}`
--- to go to the start of the line for
--- each block, rather than the empty lines.
_('}', '}j^', "n")
_('{', 'k{j^', "n")

--- Since quote is used as the leader key,
--- this avoids conflicts with its default binding.
vim.keymap.set('n', "'", "<nop>")

--- This is necessary to avoid nvim's default
--- bindings (set in `neovim/runtime/ftplugin/rust.vim`)
--- which conflict with my treewalker `[` and `]` bindings.
vim.g.no_rust_maps = 1

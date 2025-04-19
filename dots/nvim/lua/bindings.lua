local function _(key, cmd, modes, remap)
  if remap == nil then
    remap = false
  end
  vim.keymap.set(modes, key, cmd, {
    remap = remap,
    silent = true,
  })
end

function delete_keymaps_w_prefix(prefix)
  local maps = vim.api.nvim_get_keymap('n')
  for _, map in ipairs(maps) do
    if map.lhs:sub(1, #prefix) == prefix then
      vim.keymap.del("n", map.lhs)
    end
  end
end

delete_keymaps_w_prefix('[')
delete_keymaps_w_prefix(']')

--- Tabs
_("<c-t>", ":tabnew<cr>", "n")
_("]", ":tabnext<cr>", "n")
_("[", ":tabprevious<cr>", "n")

--- Replace <c-i> and <c-o>
_("<c-h>", "<c-i>", "n")
_("<c-m>", "<c-o>", "n")

--- Bind return to clear last search highlight.
_("<cr>", ":noh<cr>", "n")

--- I hit `u` accidentally WAY too much.
_("<c-u>", "u", "n")
_("u", "<nop>", "n")

--- Insert and go to new line above.
_("<s-cr>", "<esc>O", "i")

--- Commenting
_("M", "gcc", "n", true)
_("M", "gc", "v", true)

--- Don't leave visual mode when changing indent
_(">", ">gv", "x")
_("<", "<gv", "x")

--- Easily restore last visual selection with `vv`
_("vv", "gv", "n")

--- Keep search results in the screen center
_("n", "nzz", "n")
_("N", "Nzz", "n")

--- Insert common strings
_('<c-t>', ' {<cr>}<Esc>O', "i")
_('<c-v>', 'println!("{:?}", );<Left><Left>', "i")
_('<c-b>', 'dbg!();<Left><Left>', "i")

--- Delete previous word
_('<c-backspace>', '<c-w>', "i")

--- With the neowords plugin, this
--- deletes a subword backwards.
_('<c-d>', '<esc>dbxi', "i", true)

--- Splits
_("|", ":vsplit<cr>", "n")
_("_", ":split<cr>", "n")

--- Modify `{` and `}`
--- to go to the start of the line for
--- each block, rather than the empty lines.
_('}', '}j^', "n")
_('{', 'k{j^', "n")

--- Moving up and down
_(')', 'j', {"n", "o", "x"})
_('(', 'k', {"n", "o", "x"})

--- Paging up and down
_('<PageDown>', '<c-d>', "n")
_('<PageUp>', '<c-u>', "n")


--- Format the document
_('#', function()
  local view = vim.fn.winsaveview()
  vim.cmd("normal! gg=G")
  vim.fn.winrestview(view)
end, "n")

--- Use "r" instead of "c";
--- easier with my layout.
_('r', 'c', "n")

_("<leader>ww", ":wqa<cr>", "n")

--- This is necessary to avoid nvim's default
--- bindings (set in `neovim/runtime/ftplugin/rust.vim`)
--- which conflict with some of my bindings.
vim.g.no_rust_maps = 1

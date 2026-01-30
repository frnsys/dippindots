local function _(key, cmd, modes, remap)
  if remap == nil then
    remap = false
  end
  vim.keymap.set(modes, key, cmd, {
    remap = remap,
    silent = true,
  })
end

-- Unused: ., F, L, <c-j>, <c-f>, {, }, <space>, -, <c-->, k, q, c, x, z

--- Tabs
_("B", ":tabnext<cr>", "n")
_("b", ":tabprevious<cr>", "n")

--- Replace <c-i> and <c-o>
_("<c-p>", "<c-i>", "n")
_("<c-h>", "<c-o>", "n")

_("D", "dd", "n")

--- Like `{` and `}`
--- but go to the start of the line for
--- each block, rather than the empty lines.
_('<c-i>', '5jzz', { "n", "x", "o" })
_('<c-o>', '5kzz', { "n", "x", "o" })

--- Prevent some motions from adding to the jumplist
vim.keymap.set({ "n" }, "gg", function()
  if vim.v.count == 0 then
    return ':keepjumps norm! gg<CR>'
  else
    --- Keep e.g. `10gg` working normally and adding
    --- to the jumplist.
    return 'gg'
  end
end, {
  remap = false,
  silent = true,
  expr = true,
})
_('G',  ':keepjumps norm! G<cr>',  { "n" })
_('n',  ':keepjumps norm! n<cr>',  { "n" })
_('N',  ':keepjumps norm! n<cr>',  { "n" })

--- Jump between matching delimiters
_('l', '%', {"n", "x", "o"})

--- Bind return to clear last search highlight.
_("<cr>", ":noh<cr>", "n")

--- Undo
_("<c-u>", "u", "n")

--- Insert and go to new line above.
_("<s-cr>", "<esc>O", {"i", "n"})

--- Commenting
_("-", "gcc", "n", true)
_("-", "gc", "v", true)

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

--- Delete previous subword
_('<c-d>', '<esc>dmxi', "i", true)

--- Splits
_("|", ":vsplit<cr>", "n")

--- Terminal
_("<Esc>", "<C-\\><C-n>", "t")

--- This is necessary to avoid nvim's default
--- bindings (set in `neovim/runtime/ftplugin/rust.vim`)
--- which conflict with some of my bindings.
vim.g.no_rust_maps = 1

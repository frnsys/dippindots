-- When using space (`\s`) or enter/return (`\r`)
-- to expand an abbreviation,
-- this will eat that space or return.
--
-- To use, add `<C-R>=Eatchar()<CR>` to the end
-- of the expansion.
vim.api.nvim_exec([[
  func Eatchar()
    let pat = '\s\|\r'
    let c = nr2char(getchar(0))
    return (c =~ pat) ? '' : c
  endfunc
]], false)

-- Define an abbrevation where the space or return character
-- used to expand the abbrevation is eaten.
local eat_char = '<C-R>=Eatchar()<CR>'
local function abbrev(pat, expansion)
  vim.cmd('iabbrev ' .. pat .. ' ' .. expansion .. eat_char)
end

vim.cmd([[
  " Insert current datetime
  iabbrev <expr> ;d strftime('%m.%d.%Y %H:%M')

  " Insert todo item
  iabbrev ;x - [ ]

  " Other rust abbreviations
  iabbrev ;l println!("{:?}",);<Left><Left>
]])

-- Function body
abbrev(';b', '{<cr>}<Esc>O')

-- Match arrows
vim.cmd('iabbrev ;e =>')
abbrev(';E', '=> {<cr>}<Esc>O')

-- Return arrows
vim.cmd('iabbrev ;r ->')
abbrev(';R', '-> {<cr>}<Esc>O')

-- Closures
abbrev(';c', '(\\|\\| {<cr>})<Esc>O')

-- Option<...>
abbrev(';o', 'Option<><Left>')

-- Vec<..>
abbrev(';v', 'Vec<><Left>')

-- HashMap<..>
abbrev(';h', 'HashMap<><Left>')

-- derive attribute
abbrev(';#', '#[derive()]<Left><Left>')

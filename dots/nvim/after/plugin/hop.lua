local hop = require('hop')
local directions = require('hop.hint').HintDirection

vim.keymap.set('', '<c-f>', function()
  hop.hint_char2({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, {remap=true})

vim.keymap.set('', '<c-b>', function()
  hop.hint_char2({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, {remap=true})

vim.keymap.set('', 's', function()
  hop.hint_patterns({})
end, {remap=true})

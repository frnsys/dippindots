local hop = require('hop')
local directions = require('hop.hint').HintDirection

vim.keymap.set('', 'f', function()
  hop.hint_char2({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, {remap=true})

vim.keymap.set('', 'F', function()
  hop.hint_char2({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, {remap=true})

vim.keymap.set('', 's', function()
  hop.hint_patterns({})
end, {remap=true})

vim.keymap.set('', '<c-y>', function()
  hop.hint_lines_skip_whitespace({})
end, {remap=true})

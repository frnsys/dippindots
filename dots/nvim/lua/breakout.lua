--- Breakout
-------------------------------------
--- Makes it easier to jump to the
--- the start/end of a delimiter pair
--- for the current scope.
---
--- For example, with the following:
---   fn example(a, b, |c, d)
--- Using this will jump to
---   fn example(a, b, c, d)|

local ts_utils = require('nvim-treesitter.ts_utils')

-- Helper function for print,
-- use `:messages` to see the log.
local function log(msg)
  vim.api.nvim_echo({{msg}}, true, {})
end

--- Define the delimiter pairs.
local delims = {
  {'[', ']'},
  {'{', '}'},
  {'(', ')'},
  {'\'', '\''},
  {'"', '"'},
  {'`', '`'},
  {'<', '>'},
}

--- Check if the node's end/start chars
--- match any of the provided delimiters.
local function is_match(node)
  local text = vim.treesitter.get_node_text(node, 0)
  local start_char = string.sub(text, 1, 1)
  local end_char = string.sub(text, -1, -1)
  for _, value in pairs(delims) do
    if value[1] == start_char and value[2] == end_char then
      return true
    end
  end
  return false
end

--- Determine which position we should
--- target based on the node and direction.
local function get_cursor_target(node, direction)
  if (direction == "backward") then
    local row, col, _ = node:start()
    return row, col
  else -- Assume forward
    local row, col, _ = node:end_()
    return row, col
  end
end

--- Main functionality
local function breakout(direction)
  if (direction ~= "forward" and direction ~= "backward") then
    vim.api.nvim_err_writeln("Direction must be either 'forward' or 'backward'.")
    return
  end

  local mode = vim.api.nvim_get_mode()["mode"]
  local is_insert = mode == "i"

  -- Search up the tree until we find
  -- a valid node (or exhaust the tree).
  local node = ts_utils.get_node_at_cursor()

  -- If the node is already a match
  -- and the cursor is already on its last position,
  -- move up to the parent node.
  if (is_match(node)) then
    local pos = vim.api.nvim_win_get_cursor(0)
    local cur_row, cur_col = pos[1], pos[2]

    local row, col = get_cursor_target(node, direction)

    -- What column we consider the "end" of the match
    -- depends on the mode we're in. This is because
    -- for insert mode, the following cursor position,
    -- denoted with "|" is considered the end:
    --   boo(x, y|)
    -- Whereas what should be the end is:
    --   boo(x, y)|
    -- So this adjusts what column is considered
    -- the end accordingly.
    local target_col
    if (is_insert) then
      target_col = col
    else
      target_col = col - 1
    end

    if (cur_row == row + 1 and cur_col == target_col) then
      node = node:parent()
    end
  end

  -- Keep searching up the tree until we find
  -- a node with valid delimiters.
  while (node ~= nil and not is_match(node)) do
    node = node:parent()
  end

  -- No match found, give up
  if (node == nil) then return end

  -- Otherwise, jump the cursor to the appropriate position.
  local row, col = get_cursor_target(node, direction)

  -- For non-insert modes, when moving forward decrement
  -- the column so we land on the delimiter.
  -- In insert mode this isn't an issue because
  -- we want the insertion to happen after the delimiter.
  if (not is_insert and direction == "forward") then
    col = col - 1
  end
  vim.api.nvim_win_set_cursor(0, {row+1, col})
end

--- Keybindings
vim.keymap.set({'n', 'i'}, '<c-l>', function() breakout('forward') end)
vim.keymap.set({'n', 'i'}, '<c-h>', function() breakout('backward') end)

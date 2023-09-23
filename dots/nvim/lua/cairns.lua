--- *Cairns*
-------------------------------------
--- A custom mark system to quickly navigate
--- across significant locations in the session.

local M = {}

--- Available labels for marks
local chars = "asdfghjkl;'qwertyuiop[]"

--- Name space for the ext marks
local ns = vim.api.nvim_create_namespace("cairns")

--- Trim leading/trailing whitespace of a string
local function trim_whitespace(s)
  return s:match("^%s*(.-)%s*$")
end

--- Track current marks
--- and available labels.
local marks = {}
local labels = {}
for i in string.gmatch(chars, ".") do
  table.insert(labels, i)
end

--- Get the current buffer, row, and col of the cursor
local function get_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1] - 1
  local col = pos[2]
  return buf, row, col
end

--- Get current mark position
local function get_mark_pos(mark)
  local pos = vim.api.nvim_buf_get_extmark_by_id(0, ns, mark['id'], {})
  -- row, col
  return pos[1], pos[2]
end

--- Find a mark for a given buffer and row
local function get_mark(buf, row)
  for i, mark in ipairs(marks) do
    local m_row, _ = get_mark_pos(mark)
    if mark['buf'] == buf and m_row == row then
      return mark
    end
  end
end

--- Given a mark, get its index in the jump order,
--- which is just its position in the `marks` table.
local function get_mark_idx(mark)
  for i, m in ipairs(marks) do
    if mark['label'] == m['label'] then
      return i
    end
  end
end

--- Delete a mark, releasing its label for re-use.
local function delete_mark(mark)
  local idx = get_mark_idx(mark)
  vim.api.nvim_buf_del_extmark(mark['buf'], ns, mark['id'])
  table.insert(labels, 1, mark['label'])
  table.remove(marks, idx)
end

--- Toggle a mark for a row
local function toggle_mark()
  local buf, row, col = get_cursor()

  -- Check if there's a mark for this line already
  local mark = get_mark(buf, row)
  if mark ~= nil then
    delete_mark(mark)
    return
  end

  -- No labels available, abort
  if #labels == 0 then
    return
  end

  -- Get the next available label
  -- and create the ext mark
  local label = table.remove(labels, 1)
  local id = vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
    sign_text = label,
    sign_hl_group = "LeyMark",
  })
  table.insert(marks, {
    id = id,
    label = label,
    buf = buf,
    row = row,
    col = col,
  })
end

--- Find the nearest mark to the cursor position
local function nearest_mark()
  local closest = nil
  local distance = 9999
  local buf, row, _ = get_cursor()
  for _, mark in pairs(marks) do
    if mark['buf'] == buf then
      local m_row, _ = get_mark_pos(mark)
      local dist = math.abs(row - m_row)
      if dist < distance then
        distance = dist
        closest = mark
      end
    end
  end
  return closest
end

--- Jump to a mark
local function jump_to_mark(mark)
  local row, col = get_mark_pos(mark)
  vim.api.nvim_win_set_buf(0, mark['buf'])
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

--- Cycle through the marks
local function cycle_mark(step)
  if #marks == 0 then return end

  -- Find the nearest mark
  local mark = nearest_mark()

  -- If no nearest mark, jump to
  -- the first mark in the list.
  if mark == nil then
    jump_to_mark(marks[1])
  else
    -- Jump to the nearest mark
    -- if we're not already on it
    local m_row, m_col = get_mark_pos(mark)
    local buf, row, col = get_cursor()
    if m_row ~= row then
      jump_to_mark(mark)

      -- Otherwise, jump to the next/prev
      -- mark in the list
    else
      local index = get_mark_idx(mark)
      local next_idx = index + step
      if next_idx > #marks then
        next_idx = 1
      elseif next_idx <= 0 then
        next_idx = #marks
      end
      jump_to_mark(marks[next_idx])
    end
  end
end
local function jump_to_next_mark()
  cycle_mark(1)
end
local function jump_to_prev_mark()
  cycle_mark(-1)
end

--- Use Telescope to manage and navigate to marks.
function M.telescope_marks(opts)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")

  opts = opts or {}

  -- How mark entries look in the Telescope listing
  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = 1 },
      { width = 12 },
      { remaining = true },
    },
  }
  local make_display = function(entry)
    local file_name = vim.fn.fnamemodify(entry.filename, ":p:t")
    local line = vim.api.nvim_buf_get_lines(entry.mark.buf, entry.lnum - 1, entry.lnum, false)
    return displayer {
      { entry.mark.label, "LeyMark" },
      { file_name,        "LeyFile" },
      trim_whitespace(line[1]),
    }
  end

  -- Create a finder for the marks
  local function make_finder()
    -- Get the marks with their indices,
    -- so we can display them in their jump order.
    local results = {}
    for i, mark in ipairs(marks) do
      table.insert(results, {
        idx = i,
        mark = mark,
      })
    end
    return finders.new_table {
      results = results,
      entry_maker = function(result)
        local mark = result['mark']
        local row, _ = get_mark_pos(mark)
        return {
          mark = mark,

          -- Sort by position in the `marks` table
          ordinal = tostring(result['idx']) .. mark['label'],
          display = make_display,

          -- For the previewer,
          -- so we can highlight the mark position
          -- in its buffer.
          col = 1,
          lnum = row + 1,
          filename = vim.api.nvim_buf_get_name(mark['buf'])
        }
      end
    }
  end

  pickers.new(opts, {
    prompt_title = "Cairns",
    previewer = conf.qflist_previewer(opts),
    finder = make_finder(),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      -- Jump to the mark on selection.
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        jump_to_mark(selection['mark'])
      end)

      --- Delete the selected mark.
      map({ 'i', 'n' }, '<c-x>', function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        current_picker:delete_selection(function(selection)
          delete_mark(selection['mark'])
        end)
      end)

      -- Shift the selected mark's position in the jump order.
      local function shift_mark(step)
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        -- Get current mark index and figure out
        -- the index after shifting.
        local idx = get_mark_idx(selection.mark)
        local next_idx = idx + step
        if next_idx > #marks or next_idx <= 0 then
          return
        end

        -- Move the mark to its new position
        local mark = table.remove(marks, idx)
        table.insert(marks, next_idx, mark)

        -- Refresh the picker so it shows
        -- the updated order.
        -- Temporarily register a callback which keeps selection on refresh
        local selection = current_picker:get_selection_row()
        local callbacks = { unpack(current_picker._completion_callbacks) } -- shallow copy
        current_picker:register_completion_callback(function(self)
          self:set_selection(selection - step)
          self._completion_callbacks = callbacks
        end)

        local finder = make_finder()
        current_picker:refresh(finder)
      end

      --- Use K/J to reorder marks,
      --- changing their jump sequence
      map({ 'i', 'n' }, 'K', function()
        shift_mark(1)
      end)
      map({ 'i', 'n' }, 'J', function()
        shift_mark(-1)
      end)

      return true
    end,
  }):find()
end

--- Keybindings
vim.keymap.set("n", "mm", toggle_mark)
vim.keymap.set("n", "<c-n>", jump_to_next_mark)
vim.keymap.set("n", "<c-p>", jump_to_prev_mark)

return M

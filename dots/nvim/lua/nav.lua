vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/yorickpeterse/nvim-window",
})

require("oil").setup({
  keymaps = {
    ["_"] = "actions.parent",
    ["<CR>"] = "actions.select",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-s>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["g."] = "actions.toggle_hidden",
    ["q"] = "actions.close",
  },
  default_file_explorer = false,
  use_default_keymaps = false,
  float = {
    max_width = 64,
  },
})
vim.keymap.set("n", "_", require("oil").open_float)

require("nvim-window").setup({
  -- The characters available for hinting windows.
  chars = {
    't', 'r', 's',
  },
  normal_hl = 'WindowTarget',
  border = 'none',
})
vim.keymap.set("n", ",t", function()
  -- Exclude floating windows and scratch buffers
  local function is_real_win(win)
    -- Floating window
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg and cfg.relative ~= "" then return false end

    -- Exclude scratch buffers
    local buf = vim.api.nvim_win_get_buf(win)
    local bt  = vim.bo[buf].buftype
    return bt ~= "nofile"
  end

  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_real_win(w) then table.insert(wins, w) end
  end

  if #wins == 1 then
    return

    -- If there are only two windows,
    -- jump to the other one.
  elseif #wins == 2 then
    local cur = vim.api.nvim_get_current_win()
    local target = (wins[1] == cur) and wins[2] or wins[1]
    vim.api.nvim_set_current_win(target)

    -- Otherwise use the picker.
  else
    require('nvim-window').pick()
  end
end)


-- Custom "jumplist"
local marks = {"A", "B", "C", "D", "E", "F", "G"}
local current_idx = 1

local ns = vim.api.nvim_create_namespace("mark_hl")

local function highlight_marks()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  for _, m in ipairs(vim.fn.getmarklist()) do
    local mark = m.mark
    if mark:match("[a-zA-Z]") then
      local row = m.pos[2] - 1
      local col = m.pos[3] - 1

      vim.api.nvim_buf_add_highlight(
        0,
        ns,
        "MarkMarker",
        row,
        col,
        col + 1
      )
    end
  end
end

local function _cursor_pos()
  local buf = vim.api.nvim_get_current_buf()
  local row, col0 = unpack(vim.api.nvim_win_get_cursor(0))
  return buf, row, col0 + 1
end

local function get_mark_pos(mark)
  local p = vim.fn.getpos("'" .. mark)
  return p[1], p[2], p[3]
end

local function find_mark_at_cursor()
  local cbuf, crow, ccol = _cursor_pos()
  for i, m in ipairs(marks) do
    local bufnr, row, col = get_mark_pos(m)
    if bufnr ~= 0 and bufnr == cbuf and row == crow and col == ccol then
      return i, m
    end
  end
  return nil
end

local function find_next_free_mark_idx(start_idx)
  for k = 0, #marks - 1 do
    local i = ((start_idx - 1 + k) % #marks) + 1
    local bufnr = get_mark_pos(marks[i])
    if bufnr == 0 then
      return i
    end
  end
  return nil -- none free
end

local function drop_mark_toggle()
  -- Remove mark if one already exists
  local i_at, m_at = find_mark_at_cursor()
  if m_at then
    vim.cmd("delmarks " .. m_at)
    current_idx = i_at -- Can reuse the mark
    highlight_marks()
    return
  end

  -- Otherwise, add a mark.
  local free_idx = find_next_free_mark_idx(current_idx)
  local i = free_idx or current_idx
  local mark = marks[i]
  vim.cmd("normal! m" .. mark)

  current_idx = (i % #marks) + 1
  highlight_marks()
end

vim.api.nvim_create_autocmd({ "TextChanged" }, {
  callback = highlight_marks,
})

local function _jump_to_mark(mark)
  local pos = vim.fn.getpos(mark)
  if pos[1] == 0 then return end -- mark doesn't exist

  local buf = pos[1]
  local row = pos[2]
  local col = pos[3] - 1

  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_win_set_cursor(0, { row, col })
end

local idx = 0
local function jump_to_mark(forward)
  local marks = vim.fn.getmarklist()
  local globals = {}

  for _, m in ipairs(marks) do
    if m.mark:match("%u") then
      table.insert(globals, m.mark)
    end
  end

  table.sort(globals)
  if #globals == 0 then return end

  if forward then
    idx = (idx % #globals) + 1
  else
    idx = (idx - 2) % #globals + 1
  end

  vim.cmd("normal! m'") -- Add departing position to jumplist
  _jump_to_mark(globals[idx])
end

-- Clear uppercase marks on quit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for c = string.byte("A"), string.byte("Z") do
      vim.cmd("delmarks " .. string.char(c))
    end
  end,
})

vim.keymap.set("n", "<space>", drop_mark_toggle)
vim.keymap.set("n", "-", function()
  jump_to_mark(true)
end)
vim.keymap.set("n", "<c-->", function()
  jump_to_mark(false)
end)

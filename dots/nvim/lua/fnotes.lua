--- Make it easier to insert and move around footnotes in markdown files.

--- Get TS node text.
local t = function(node)
  return vim.treesitter.get_node_text(node, 0)
end

--- Count entries in a table.
-- Insane that this has to be done manually
function count(tbl)
  local count = 0
  for _ in pairs(tbl) do count = count + 1 end
  return count
end

--- Insert the string at the current cursor.
function insert_at_cursor(str)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { str })
end

--- Insert the string at the end of the file,
--- creating a new line if the last one isn't empty.
function insert_at_end(str)
  local n_lines = vim.api.nvim_buf_line_count(0)
  local last_line = vim.api.nvim_buf_get_lines(0, n_lines - 1, n_lines, false)
  if #last_line[1] ~= 0 then
    vim.api.nvim_buf_set_lines(0, n_lines, n_lines, true, { '' })
  end

  local n_lines = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_buf_set_text(0, n_lines - 1, 0, n_lines - 1, 0, { str })
end

--- Get the word under the cursor, including punctuation.
local function get_cursor_word()
  return vim.fn.escape(vim.fn.expand('<cWORD>'), [[\/]])
end

--- Add a new footnote at the current cursor, automatically
--- incrementing the number.
local function add_footnote()
  local parser = vim.treesitter.get_parser(0, 'markdown_inline')
  local tree = parser:parse()
  local root = tree[1]:root()

  -- Query footnotes via treesitter.
  local query = vim.treesitter.query.parse('markdown_inline',
    [[((shortcut_link (link_text) @footnote_label) (#match? @footnote_label "^\\^"))]])

  -- Count unique footnote names/labels
  local fns = {}
  function insert_fn(str)
    fns[str] = true
  end

  for _, matches, _ in query:iter_matches(root, 0) do
    for _, match in ipairs(matches) do
      local label = t(match)
      insert_fn(label)
    end
  end

  -- Insert the new footnote
  local next_fn_id = count(fns) + 1
  local fn = "[^" .. tostring(next_fn_id) .. "]"
  insert_at_cursor(fn)
  insert_at_end(fn .. ":")
end

--- Get the footnote under the cursor, if any.
local function footnote_under_cursor()
  local word = get_cursor_word()
  local match = word:match('^%[%^%w+%]:?$')
  if not match then
    return nil
  elseif vim.startswith(word, match) then
    return match
  end
end

--- Toggle jump b/w the footnote under cursor
--- and its reference or definition.
local function jump_footnote()
  local match = footnote_under_cursor()
  if not match then return false end
  if vim.endswith(match, ":") then
    -- Already at the definition, go to the reference
    local label = string.sub(match, 3, #match - 2)
    local line_no = vim.fn.search("\\[\\^" .. label .. "\\]\\(:\\)\\@!")
  else
    -- At the reference, go to the definition
    local label = string.sub(match, 3, #match - 1)
    local line_no = vim.fn.search("^\\[\\^" .. label .. "\\]:")
  end
  return true
end

--- Current floating window id & footnote.
local winid = nil
local fnote = nil

--- Display the provided lines in a floating window.
local function show_float(title, lines)
  local joined = table.concat(lines, '')
  if #joined == 0 then
    return
  end

  -- Try to re-use existing buffer.
  local buf = vim.fn.bufnr('footnotes')
  if buf == -1 then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'footnotes')
  end

  -- Try to re-use the existing window
  local win = vim.fn.bufwinid("footnotes")
  if win == -1 then
    local opts = {
      style = "minimal",
      relative = "cursor",
      width = 64,
      height = 6,
      row = 1,
      col = 0,
      border = "single",
      title = { { " " .. title .. " ", "WinTitle" } }
    }

    win = vim.api.nvim_open_win(buf, false, opts)
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_set_option_value("filetype", "markdown", {
    buf = buf
  })
  vim.cmd([[setlocal nospell]])

  winid = win
end

--- Preview the current footnote definition in a floating window.
local function preview_footnote()
  local match = footnote_under_cursor()
  if not match or vim.endswith(match, ":") then
    if winid ~= nil then
      vim.api.nvim_win_close(winid, true)
      winid = nil
      fnote = nil
    end
    return
  else
    local label = string.sub(match, 3, #match - 1)
    if fnote == nil or fnote ~= label then
      local line_no = vim.fn.search("^\\[\\^" .. label .. "\\]:", 'n')
      local lines = vim.api.nvim_buf_get_lines(0, line_no - 1, line_no, false)
      show_float(label, lines)
      fnote = label
    end
  end
end

--- If we're on a footnote, jump to its reference/definition;
--- otherwise insert a new footnote.
local function handle_footnote()
  local jumped = jump_footnote()
  if not jumped then
    add_footnote()
  end
end

vim.keymap.set("n", ";f", handle_footnote)
vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = "*.md",
  callback = function()
    preview_footnote()
  end
})

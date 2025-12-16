-- To write more, use `:InspectTree`.
local ts_queries = {
  statement = [[
    (block
      (_) @statement.outer)
  ]],
  value = [[
    (for_expression
      value: (_) @value)

    (if_expression
      condition: (_) @value)
  ]],
  list_item = [[
    (arguments (_) @list_item)
    (use_list (_) @list_item)
    (tuple_type (_) @argument)
  ]],
  left_right = [[
    (let_declaration
      pattern: (_) @assignment.lhs
      value: (_) @assignment.rhs)

    (assignment_expression
      left: (_) @assignment.lhs
      right: (_) @assignment.rhs)

    (field_declaration
      name: (_) @assignment.lhs
      type: (_) @assignment.rhs)

    (field_pattern
      name: (_) @assignment.lhs
      pattern: (_) @assignment.rhs)

    (match_arm
      pattern: (_) @assignment.lhs
      value: (_) @assignment.rhs)

    (field_initializer
      field: (_) @assignment.lhs
      value: (_) @assignment.rhs)

    (binary_expression
      left: (_) @assignment.lhs
      right: (_) @assignment.rhs)
  ]]
}

-- Find matches in buffer for an arbitrary treesitter query.
local function find_ts_matches(win, ts_query)
  local bufnr = vim.api.nvim_win_get_buf(win)
  local ftype = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(ftype)
  if not lang then return {} end

  local parser = vim.treesitter.get_parser(bufnr, lang)
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Note: requires `nvim-treesitter/nvim-treesitter-textobjects`
  -- local query = vim.treesitter.query.get(lang, "textobjects")

  local query = vim.treesitter.query.parse(lang, ts_query)
  if not query then return {} end

  local matches = {}
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()
    table.insert(matches, {
      pos = { start_row + 1, start_col },
      end_pos = { end_row + 1, end_col - 1 },
    })
  end
  return matches
end

-- Check if the char at pos is escaped (assumes \ as escape char).
local function is_escaped(line, pos)
  local count = 0
  pos = pos - 1
  while pos > 0 and line:sub(pos, pos) == "\\" do
    count = count + 1
    pos = pos - 1
  end
  return (count % 2) == 1
end

-- Convert a flattened buffer index to the correct 2d buffer position.
local function index_to_row_col(pos, line_offsets, start_line)
  for i = #line_offsets, 1, -1 do
    if pos > line_offsets[i] then
      local row = start_line + i - 1 -- shift to real buffer line number
      local col = pos - line_offsets[i] - 1
      return row, col
    end
  end
  -- fallback to first visible line
  return start_line, pos - 1
end

--- Find balanced delimiter matches.
local function find_balanced_delimiters(delimiter_pairs, include_delimiters)
  local matches = {}

  -- Get all buffer lines and flatten into one string.
  local start_line = vim.fn.line("w0")
  local end_line = vim.fn.line("w$")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = table.concat(lines, "\n")

  -- Track the line offsets in the flattened string
  -- so we can reconstruct the correct buffer positions for selection.
  local line_offsets = {}
  local offset = 0
  for i, line in ipairs(lines) do
    line_offsets[i] = offset
    offset = offset + #line + 1 -- +1 for newline
  end

  -- For each delimiter pair, scan the text.
  for _, pair in ipairs(delimiter_pairs) do
    local open_delim, close_delim = pair[1], pair[2]
    local stack = {}
    local i = 1
    while i <= #text do
      local char = text:sub(i, i)

      if char == open_delim and not is_escaped(text, i) then
        -- Symmetric delimiters, e.g. "'" and "'".
        if open_delim == close_delim then
          if #stack > 0 then
            -- Closing
            local start_pos = table.remove(stack)
            local match_start, match_end
            if include_delimiters or i == start_pos + 1 then
              -- Empty delimiter pair, fallback to the start delimiter
              match_start = start_pos
              match_end = start_pos
            else
              match_start = start_pos + 1
              match_end = i - 1
            end
            table.insert(matches, { pos = match_start, end_pos = match_end })
          else
            -- Opening
            table.insert(stack, i)
          end

        -- Asymmetric opening
        else
          table.insert(stack, i)
        end

      -- Asymmetric delimiters, e.g. "(" and ")".
      elseif char == close_delim and not is_escaped(text, i) and open_delim ~= close_delim then
        -- Asymmetric closing
        local start_pos = table.remove(stack)
        if start_pos then
          local match_start, match_end
          if include_delimiters or i == start_pos + 1 then
            -- Empty delimiter pair, fallback to the start delimiter
            match_start = start_pos
            match_end = start_pos
          else
            match_start = start_pos + 1
            match_end = i - 1
          end
          table.insert(matches, { pos = match_start, end_pos = match_end })
        end
      end

      i = i + 1
    end
  end

  -- Calculate correct buffer positions for matches.
  local result_matches = {}
  for _, match in ipairs(matches) do
    local row1, col1 = index_to_row_col(match.pos, line_offsets, start_line)
    local row2, col2 = index_to_row_col(match.end_pos, line_offsets, start_line)
    table.insert(result_matches, { pos = { row1, col1 }, end_pos = { row2, col2 } })
  end

  return result_matches
end

local M = {}

--- Flash matcher for a balanced delimiters.
function M.delim_matcher(delimiter_pairs, include_delimiters)
  return function(win)
    return find_balanced_delimiters(delimiter_pairs, include_delimiters)
  end
end

--- Flash matcher for an arbitrary treesitter query.
function M.ts_matcher(ts_query_name)
  return function(win)
    return find_ts_matches(win, ts_queries[ts_query_name])
  end
end

return M

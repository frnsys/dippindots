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

-- Find list items
local function list_items_recursive(text, base_offset)
    local ranges = {}
    local i = 1
    local containers = { ['<'] = '>', ['('] = ')', ['['] = ']', ['{'] = '}' }

    while i <= #text do
        local char = text:sub(i, i)

        -- CASE 1: Strings (Quotes)
        if char == "'" or char == '"' then
            local quote = char
            local j = i + 1
            while j <= #text and text:sub(j, j) ~= quote do
                j = j + 1
            end

            -- Add the string as a single item ONLY if the parent scope is a list
            if has_top_level_comma(text) then
                table.insert(ranges, {pos = i + base_offset, end_pos = j + base_offset})
            end
            i = j + 1

        -- CASE 2: Nested Containers
        elseif containers[char] then
            local closer = containers[char]
            local depth = 1
            local j = i + 1

            while j <= #text and depth > 0 do
                local c = text:sub(j, j)
                -- We must still handle quotes inside brackets to avoid
                -- miscounting depth if a bracket is inside a string
                if c == "'" or c == '"' then
                    local q = c
                    j = j + 1
                    while j <= #text and text:sub(j, j) ~= q do j = j + 1 end
                elseif c == char then depth = depth + 1
                elseif c == closer then depth = depth - 1 end
                if depth > 0 then j = j + 1 end
            end

            local inner_content = text:sub(i + 1, j - 1)

            if has_top_level_comma(inner_content) then
                table.insert(ranges, {pos = i + base_offset, end_pos = j + base_offset})
            end

            -- Recurse into brackets (but not strings)
            local inner_results = list_items_recursive(inner_content, base_offset + i)
            for _, r in ipairs(inner_results) do
                table.insert(ranges, r)
            end
            i = j + 1

        -- CASE 3: Separators
        elseif char == "," or char:match("%s") then
            i = i + 1

        -- CASE 4: Plain words
        else
            local j = i
            while j <= #text and not containers[text:sub(j,j)] and text:sub(j,j) ~= "," and text:sub(j,j) ~= "'" and text:sub(j,j) ~= '"' do
                j = j + 1
            end
            if has_top_level_comma(text) then
                table.insert(ranges, {pos = i + base_offset, end_pos = j - 1 + base_offset})
            end
            i = j
        end
    end
    return ranges
end

local function has_top_level_comma(str)
    local depth = 0
    local i = 1
    local openers = { ['<'] = '>', ['('] = ')', ['['] = ']', ['{'] = '}' }
    local closers = { ['>'] = true, [')'] = true, [']'] = true, ['}'] = true }

    while i <= #str do
        local c = str:sub(i, i)

        -- Ignore whatever's inside quotes
        if c == "'" or c == '"' then
            local quote = c
            local j = i + 1
            while j <= #str and str:sub(j, j) ~= quote do
                j = j + 1
            end
            i = j
        elseif openers[c] then
            depth = depth + 1
        elseif closers[c] then
            depth = math.max(0, depth - 1)
        elseif c == "," and depth == 0 then
            return true
        end
        i = i + 1
    end
    return false
end

local function find_list_items()
    local start_line = vim.fn.line("w0")
    local end_line = vim.fn.line("w$")
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local text = table.concat(lines, "\n")

    -- Map character index back to {row, col}
    local line_offsets = {}
    local current_total = 0
    for idx, line in ipairs(lines) do
        line_offsets[idx] = current_total
        current_total = current_total + #line + 1
    end

    -- Helper to convert flat index to (row, col)
    local function index_to_row_col(idx)
        for row_idx = #line_offsets, 1, -1 do
            if idx > line_offsets[row_idx] then
                return (start_line + row_idx - 1), (idx - line_offsets[row_idx] - 1)
            end
        end
        return start_line, 0
    end

    -- Get the flat ranges
    local flat_ranges = list_items_recursive(text, 0)

    -- Convert to buffer positions
    local final_matches = {}
    for _, range in ipairs(flat_ranges) do
        local r1, c1 = index_to_row_col(range.pos)
        local r2, c2 = index_to_row_col(range.end_pos)
        table.insert(final_matches, { pos = {r1, c1}, end_pos = {r2, c2} })
    end

    return final_matches
end

local M = {}

--- Flash matcher for list items.
function M.list_item_matcher()
  return function(win)
    return find_list_items()
  end
end

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

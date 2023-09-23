--- ~Breeze~
-------------------------------------
--- Makes it easier to define new movements
--- based on Lua patterns.

--- Construct a lua pattern from a specification,
--- see below.
local function build_pattern(spec, forward)
  local capture = "(" .. spec[2] .. ")"
  if (forward) then
    return spec[1] .. capture
  else
    -- Reverse the pattern
    return capture .. spec[1]
  end
end

--- Get all indices of matches for the provided patterns
--- in the provided string, starting from the `start_index`.
local function find_match_indices(string, patterns, start_index)
  local indices = {}
  for _, pattern in ipairs(patterns) do
    local index = string.find(string, pattern, start_index)
    if (index ~= nil) then
      table.insert(indices, index)
    end
  end
  return indices
end

--- Find the closest match index (i.e. the lowest one).
local function find_closest_match_index(string, patterns, start_index)
  local indices = find_match_indices(string, patterns, start_index)
  if (#indices == 0) then return nil end
  return math.min(unpack(indices))
end

--- Patterns should be an array of pattern specs
--- with the structure:
---   { preceded, capture }
local function pattern_motion(pattern_specs, forward)
  local line = vim.api.nvim_get_current_line()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1], pos[2]

  -- Build the lua patterns
  local patterns = {}
  for _, spec in ipairs(pattern_specs) do
    table.insert(patterns, build_pattern(spec, forward))

    if (not forward) then
      -- When going backward we also check for the pattern
      -- at the start (i.e. end, when reversed) of the line
      table.insert(patterns, build_pattern({ "$", spec[2] }, false))
    end
  end

  -- Find the closest match index
  local target_col = 0
  if (forward) then
    target_col = find_closest_match_index(line, patterns, col + 1)
  else
    local line_start = string.sub(line, 0, col)
    local reversed = line_start:reverse()
    target_col = find_closest_match_index(reversed, patterns, 0)

    if (target_col ~= nil) then
      target_col = #reversed - target_col
    end
  end

  -- If a match was found...
  if (target_col ~= nil) then
    -- Handle operator pending mode;
    -- lifted from `nvim-spider`
    local mode = vim.api.nvim_get_mode().mode
    local isOperatorPending = mode == "no"
    if isOperatorPending then
      local lastCol = vim.fn.col("$")

      if lastCol - 1 == target_col then
        -- HACK columns are end-exclusive, cannot actually target the last character
        -- in the line otherwise without switching to visual mode?!
        vim.cmd.normal { "v", bang = true }
        target_col = target_col - 1 -- SIC indices in visual off-by-one compared to normal
      end
    end

    -- Set the cursor position
    vim.api.nvim_win_set_cursor(0, { row, target_col })
  end
end

--- Like `w`/`b`, but skips punctuation,
--- and treats "_" and "-" as part of a word.
--- For example:
---   a|bc.def.hij
---   abc.|def.hij
local function identifier(forward)
  pattern_motion({ { "[%s.,;:!&*=|/<>()%[%]{}'\"]", "%w" } }, forward)
end

--- Move by subword, e.g. each segment
--- of a camelcase or pascalcase word.
--- Otherwise like `identifier` above.
--- For example:
---   a|bcDef.hijk
---   abc|Def.hijk
local function subword(forward)
  pattern_motion({
    { "[%s%p%l]", "%u" },
    { "[%s%p]",   "%l" },
  }, forward)
end

--- Keybindings
vim.keymap.set({ 'n', 'o', 'x', 'i' }, '<c-w>', function()
  identifier(true)
end)
vim.keymap.set({ 'n', 'o', 'x', 'i' }, '<c-b>', function()
  identifier(false)
end)
vim.keymap.set({ 'n', 'o', 'x' }, 'W', function()
  subword(true)
end)
vim.keymap.set({ 'n', 'o', 'x' }, 'B', function()
  subword(false)
end)

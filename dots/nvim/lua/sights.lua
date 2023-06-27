--- This uses `flash`, `nvim-treesitter`, and `nvim-treesitter-textobjects`.

--- Get the range of visible lines.
local function visible_line_range()
  local start_lnum = vim.fn.line('w0') - 1
  local end_lnum = vim.fn.line('w$') - 1
  return start_lnum, end_lnum
end

--- Check if a table contains a value.
local function contains(table, val)
    for _, value in ipairs(table) do
        if value == val then
            return true
        end
    end
    return false
end

--- Takes a table of sight targets and
--- uses flash to handle them.
local function handle_targets(targets, key)
  -- Pass the targets to flash.
  require('flash').jump({
    matcher = function(win)
      return targets
    end,
    action = function(match, state)
      -- On selection, visually select the region
      vim.api.nvim_win_set_cursor(0, {match['pos'][1], match['pos'][2]})
      vim.cmd.normal { 'v', bang = true }
      vim.api.nvim_win_set_cursor(0, {match['end_pos'][1], match['end_pos'][2]})

      -- For visual selection (`v`), don't pass the key,
      -- since we're already selecting the region.
      -- Otherwise pass the key on.
      if key ~= 'v' then
        local keys = vim.api.nvim_replace_termcodes(
        key, true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
      end
    end
  })
end

--- Find all matches of pattern in a string.
--- Set `around` true to get the ranges of the entire match,
--- otherwise only the inner capture is considered, assuming
--- a lua pattern of the form `foo()(main capture)()bar`.
local function find_all(str, pattern, around)
  local results = {}
  local start_idx = 0
  local end_idx = 0
  while true do
    if around then
      start_idx, end_idx = str:find(pattern, start_idx+1)
    else
      start_idx, _, end_idx = str:match(pattern, start_idx+1)
    end
    if start_idx == nil then
      break
    end
    if not around then
      end_idx = end_idx - 1
    end
    table.insert(results, {start_idx, end_idx})
  end
  return results
end

--- Produce targets from a table of lua patterns,
--- applying the provided action key, e.g. `c` for "change".
--- `around=true` is the `a` match, otherwise it's `i`.
local function sights_pattern(patterns, key, around)
  -- Get visible line range.
  local start_lnum, end_lnum = visible_line_range()

  local targets = {}
  local lines = vim.api.nvim_buf_get_lines(0, start_lnum, end_lnum, true)
  for i, line in ipairs(lines) do
    for _, pattern in ipairs(patterns) do
      local results = find_all(line, pattern, around)
      for _, indices in ipairs(results) do
        local start_idx = indices[1]
        local end_idx = indices[2]
        -- Save the targets to pass to flash.
        table.insert(targets, {
          pos = { start_lnum + i, start_idx - 1 },
          end_pos = { start_lnum + i, end_idx - 1 }
        })
      end
    end
  end
  handle_targets(targets, key)
end

--- Produce targets for a treesitter text object,
--- e.g. "@parameter.inner", and apply the action key
--- to execute on the text object, e.g. `c` for "change".
--- The `shrink` parameter will cause the visual selection
--- to contract by one line on each side; this lets you exclude
--- the braces around a block/scope for example, if you just
--- want the interior contents.
local function sights_treesitter(textobj_name, key, shrink)
  -- Get visible line range.
  local start_lnum, end_lnum = visible_line_range()

  -- Query for the text object in the current buffer
  local results = require('nvim-treesitter.query').get_capture_matches_recursively(
    0, textobj_name, "textobjects")

  -- Iterate over matches
  local targets = {}
  for _, match in ipairs(results) do
    local start_row, start_col, end_row, end_col = match.node:range()

    -- Filter out nodes that aren't in the visible range.
    if start_row + 1 > start_lnum and start_row + 1 < end_lnum then
      if shrink then
        start_row = start_row + 1
        start_col = 0
        end_row = end_row - 1
        end_col = #vim.fn.getline(end_row + 1)
      end

      -- Save the targets to pass to flash.
      table.insert(targets, {
        pos = { start_row + 1, start_col },
        end_pos = { end_row + 1, end_col - 1 }
      })
    end
  end

  handle_targets(targets, key)
end


--- The actions to take on the selection.
local action_keys = {
  ['C'] = 'c',
  ['D'] = 'd',
  ['Y'] = 'y',
  ['S'] = 's',
  ['V'] = 'v',
}

--- The text objects to use (from `nvim-treesitter-textobjects`),
--- or lua patterns for defining other text objects.
--- You can also include treesitter text objects in `mappings.shrink`
--- to have them be shrunk by one line on each side.
--- This is a hack related to:
--- <https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/112>
--- It's fine for "@function.inner" but not yet for "@block.inner".
---
--- Patterns should be defined like so: `foo()(main capture)()bar`.
--- When `i` (inner) is used, the selection will be "main capture";
--- otherwise (i.e. for `a`/around) the full match is selected.
local mappings = {
  treesitter = {
    ['a'] = {
      '@parameter.inner',
      '@parameter.outer',
    },
    ['f'] = {
      '@function.inner',
      '@function.outer',
    },
    ['c'] = {
      '@call.inner',
      '@call.outer',
    },
    ['e'] = {
      '@assignment.inner',
      '@assignment.outer',
    },
    ['b'] = {
      '@block.inner',
      '@block.outer',
    },
  },
  pattern = {
    ['<'] = {
      [[<()([^>]+)()>]]
    },
    ["'"] = {
      [['()([^']+)()']],
      [["()([^"]+)()"]],
    },
    ['"'] = {
      [["()([^"]+)()"]],
      [['()([^']+)()']]
    },
    ['{'] = {
      [[{()([^}]+)()}]]
    },
    ['('] = {
      [[%(()([^%)]+)()%)]]
    },
    ['['] = {
      "%[()([^%]]+)()%]]"
    }
  },
  shrink = {
    '@block.inner',
  }
}

--- Setup the keybindings.
--- The keybindings consist of three keys:
--- 1. The action key, as defined in `action_keys`.
--- 2. `i` for inner or `a` for around
--- 3. The mapping key, as defined in `mappings`.
vim.api.nvim_create_autocmd({'BufEnter'}, {
  pattern = '*', callback = function(opts)
    for k, textobjs in pairs(mappings['treesitter']) do
      for key, akey in pairs(action_keys) do
        local shrink = contains(mappings['shrink'], textobjs[1]);
        vim.keymap.set('n', key .. 'i' .. k, function()
          sights_treesitter(textobjs[1], akey, shrink)
        end)

        shrink = contains(mappings['shrink'], textobjs[2]);
        vim.keymap.set('n', key .. 'a' .. k, function()
          sights_treesitter(textobjs[2], akey, shrink)
        end)
      end
    end

    for k, patterns in pairs(mappings['pattern']) do
      for key, akey in pairs(action_keys) do
        vim.keymap.set('n', key .. 'a' .. k, function()
          sights_pattern(patterns, akey, true)
        end)
        vim.keymap.set('n', key .. 'i' .. k, function()
          sights_pattern(patterns, akey, false)
        end)
      end
    end
  end
});

--- This uses `hop`, `nvim-treesitter`, and `nvim-treesitter-textobjects`.
local hop = require("hop")
local queries = require "nvim-treesitter.query"
local ns = vim.api.nvim_create_namespace("sights")

--- Highlight group for visualizing the target regions.
vim.api.nvim_command('highlight default SightsPreview guibg=#262626 guifg=#888888')

--- TODO need a better solution here.
--- When hop quits without making a selection,
--- the SightsPreview highlight group isn't cleared.
--- There's no event or callback for when hop quits.
--- This is an inadequate hack to clear the SightsPreview
--- highlight group on `<esc>`, which is hop's default
--- quit button. The problems it that hop captures
--- the quit button, so you have to press `<esc>` twice:
--- once to quit hop, and once to clear the SightsPreview highlighting.
vim.keymap.set('n', '<esc>', function()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end, {})

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
--- uses hop to handle them.
local function handle_targets(targets, key)
  -- Add highlights for the node ranges.
  for _, target in ipairs(targets) do
    vim.api.nvim_buf_set_extmark(0, ns,
      target['line'],
      target['column'], {
        hl_group = "SightsPreview",
        end_row = target['node_end']['row'],
        end_col = target['node_end']['col'],
        priority = 65534, -- High priority so it's drawn over hop
      })
  end

  -- Pass the targets to hop.
  local gen = function(opts)
    return {
      jump_targets = targets
    }
  end
  hop.hint_with_callback(gen, nil, function(t)
    -- On selection, visually select the region
    -- and clear highlighting.
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    vim.api.nvim_win_set_cursor(0, {t['line'] + 1, t['column'] - 1})
    vim.cmd.normal { 'v', bang = true }
    vim.api.nvim_win_set_cursor(0, {t['node_end']['row'] + 1, t['node_end']['col'] - 1})

    -- For visual selection (`v`), don't pass the key,
    -- since we're already selecting the region.
    -- Otherwise pass the key on.
    if key ~= 'v' then
      local keys = vim.api.nvim_replace_termcodes(
        key, true, false, true)
      vim.api.nvim_feedkeys(keys, 'n', false)
    end
  end)
end

--- Find all matches of pattern in a string.
--- Set `around` true to get the ranges of the entire match,
--- otherwise only the inner capture is considered (assuming
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
  -- Reset highlights.
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

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
        -- Save the targets to pass to hop.
        table.insert(targets, {
          line = start_lnum + i - 1,
          column = start_idx,
          window = 0,
          node_end = {
            row = start_lnum + i - 1,
            col = end_idx,
          }
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
  -- Reset highlights.
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  -- Get visible line range.
  local start_lnum, end_lnum = visible_line_range()

  -- Query for the text object in the current buffer
  local results = queries.get_capture_matches_recursively(
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

      -- Save the targets to pass to hop.
      table.insert(targets, {
        line = start_row,
        column = start_col + 1,
        window = 0,
        node_end = {
          row = end_row,
          col = end_col,
        }
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

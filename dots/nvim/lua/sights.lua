--- +Sights+
-------------------------------------
--- A system for better targeting text objects.
--- This requires `flash`, `nvim-treesitter`, and `nvim-treesitter-textobjects`.

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
local function handle_targets(targets)
  -- Pass the targets to flash.
  require('flash').jump({
    matcher = function(win, state)
      -- Have to manually assign the labels
      -- for some reason.
      local labels = state:labels()
      for i = 1, #targets do
        targets[i].label = table.remove(labels, 1)
      end
      return targets
    end,
    labeler = function() end,
    action = function(match, state)
      -- On selection, visually select the region
      vim.api.nvim_win_set_cursor(0, { match['pos'][1], match['pos'][2] })
      vim.cmd.normal { 'v', bang = true }
      vim.api.nvim_win_set_cursor(0, { match['end_pos'][1], match['end_pos'][2] })
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
      start_idx, end_idx = str:find(pattern, start_idx + 1)
    else
      start_idx, _, end_idx = str:match(pattern, start_idx + 1)
    end
    if start_idx == nil then
      break
    end
    if not around then
      end_idx = end_idx - 1
    end
    table.insert(results, { start_idx, end_idx })
  end
  return results
end

--- Produce targets from a table of lua patterns.
--- `around=true` is the `a` match, otherwise it's `i`.
--- If `select=true` it means we're selecting and not applying
--- an operator.
local function sights_pattern(patterns, around)
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
  handle_targets(targets)
end

--- Produce targets for a treesitter text object,
--- e.g. "@parameter.inner", and apply the op
--- to execute on the text object, e.g. `c` for "change".
--- The `shrink` parameter will cause the visual selection
--- to contract by one line on each side; this lets you exclude
--- the braces around a block/scope for example, if you just
--- want the interior contents.
local function sights_treesitter(queries, shrink)
  -- Get visible line range.
  local start_lnum, end_lnum = visible_line_range()

  -- Query for the text object in the current buffer
  local results = {}

  for _, q in ipairs(queries) do
    local matches = require('nvim-treesitter.query')
        .get_capture_matches_recursively(0, q.query, q.query_group)
    for _, match in ipairs(matches) do
      table.insert(results, match)
    end
  end

  -- Iterate over matches
  local targets = {}
  for _, match in ipairs(results) do
    if match.node ~= nil then
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
  end

  handle_targets(targets)
end


--- The text objects to use (from `nvim-treesitter-textobjects`),
--- or lua patterns for defining other text objects.
--- You can also include treesitter text objects in `mappings.shrink`
--- to have them be shrunk by one line on each side.
--- This is a hack related to:
--- <https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/112>
--- It's fine for "@function.inner" but not yet for "@block.inner".
---
--- Patterns should be defined like so: `foo()(main capture)()bar`.
--- The inner selection will be "main capture";
--- otherwise (i.e. for around) the full match is selected.
--- Patterns reference: <https://www.lua.org/manual/5.3/manual.html#6.4.1>
local mappings = {
  treesitter = {
    ['a'] = {
      label = '[a]rg',
      inner = '@parameter.inner',
      outer = '@parameter.outer',
    },
    ['f'] = {
      label = '[f]unc',
      inner = '@function.inner',
      outer = '@function.outer',
    },
    ['c'] = {
      label = '[c]all',
      inner = '@call.inner',
      outer = '@call.outer',
    },
    ['e'] = {
      label = 'd[e]fine',
      inner = '@assignment.inner',
      outer = '@assignment.outer',
    },
    ['k'] = {
      label = 'bloc[k]',
      inner = '@block.inner',
      outer = '@block.outer',
    },
    ['v'] = {
      label = '[v]ar',
      inner = {
        {
          query = "@field", -- property
          query_group = "highlights"
        },
        {
          query = "@variable",
          query_group = "highlights"
        },
      }
    },
    ['n'] = {
      label = '[n]um',
      inner = '@number.inner'
    },
    ['t'] = {
      label = '[t]ype',
      inner = {
        {
          query = "@type",
          query_group = "highlights"
        },
        {
          query = "@type.builtin",
          query_group = "highlights"
        }
      }
    }
  },
  pattern = {
    ['q'] = {
      label = '[q]uote',
      patterns = {
        [["()([^"]+)()"]],
        [['()([^']+)()']],
      }
    },
    ['b'] = {
      label = '[b]race',
      patterns = {
        [[{()([^}]+)()}]],
        [[%(()([^%)]+)()%)]],
        "%[()([^%]]+)()%]]",
        [[<()([^>]+)()>]]
      }
    },
    ['u'] = {
      label = '[u]rl',
      patterns = {
        [[()(https?://%g+)()$]],
        [[()(https?://%g+)()%s]]
      }
    },

    -- TODO this leads to too many options
    ['w'] = {
      label = '[w]ord',
      patterns = {
        [[%s()(%S+)()%s]],
        [[%s()(%S+)()$]],
      }
    }
  },
  shrink = {
    '@block.inner',
  }
}

--- Returns true if the character is uppercase
local function is_upper(char)
  return vim.fn.toupper(char) == char
end

--- Convert either a text object name
--- or a text object query into a treesitter query.
local function to_query(t_obj)
  if type(t_obj) == "table" then
    return t_obj
  else
    return {
      query = t_obj,
      query_group = "textobjects"
    }
  end
end

vim.keymap.set({ 'n' }, '<space>', function()
  -- Display hints for possible objects
  -- local keys = {}
  -- for key, spec in pairs(mappings['treesitter']) do
  --   table.insert(keys, spec.label)
  -- end
  -- for key, spec in pairs(mappings['pattern']) do
  --   table.insert(keys, spec.label)
  -- end
  -- print(table.concat(keys, " "))

  -- Wait for a character input to figure out
  -- what we're looking for.
  local ok, char = pcall(vim.fn.getcharstr)
  if not ok or char == '\27' then return nil end

  -- Uppercase input is considered "around"
  local around = is_upper(char)
  char = vim.fn.tolower(char)

  -- See if any defined object matches this character.
  if mappings['treesitter'][char] ~= nil then
    local textobjs = mappings['treesitter'][char]

    -- Either use the "inner" or "around" definition.
    local t_obj
    if around then
      t_obj = textobjs.outer
    else
      t_obj = textobjs.inner
    end
    if t_obj == nil then return end

    local queries = {}
    if type(t_obj) == "table" then
      -- Array
      if t_obj[1] ~= nil then
        for _, to in ipairs(t_obj) do
          table.insert(queries, to_query(to))
        end
      else
        table.insert(queries, t_obj)
      end
    else
      table.insert(queries, to_query(t_obj))
    end

    local shrink = contains(mappings['shrink'], t_obj)
    sights_treesitter(queries, shrink)
  elseif mappings['pattern'][char] ~= nil then
    local spec = mappings['pattern'][char]
    sights_pattern(spec.patterns, around)
  end
end)

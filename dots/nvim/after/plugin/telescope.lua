require("ignore")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

local function bind(desc, keys, func, modes)
  vim.keymap.set(modes or {'n'}, keys, func, {desc=desc})
end

require("telescope").setup({
    defaults = require('telescope.themes').get_dropdown({
      previewer = false,
      mappings = {
        i = {
          -- exit on first esc
          ["<esc>"] = actions.close,
          ["<C-j>"] = {
            actions.move_selection_next, type = "action",
            opts = { nowait = true, silent = true }
          },
          ["<C-k>"] = {
            actions.move_selection_previous, type = "action",
            opts = { nowait = true, silent = true }
          },

          -- If file is already open,
          -- switch to its window.
          -- Otherwise open the selected file
          -- in a new tab.
          ["<c-t>"] = actions.select_tab_drop,

          -- If file is already open,
          -- switch to its window.
          -- Otherwise replace the current window
          -- with the selected file.
          ["<CR>"] = actions.select_drop,
        },
      },
      file_ignore_patterns = edit_file_ignore_patterns,
    }),
    pickers = {
      current_buffer_fuzzy_find = {
        previewer = false,
      },
      find_files = {
        previewer = false,
        find_command = { "fd", "-t=f" },
      },
      live_grep = {
        disable_coordinates = true,
      },
      buffers = {
        previewer = false,
        mappings = {
          i = {
            ["<c-x>"] = "delete_buffer",
          },
        },
        show_all_buffers = false,

        -- So the previously used buffer
        -- is always at top
        ignore_current_buffer = true,
        sort_mru = true,
      },
      diagnostics = {
        previewer = false,
        layout_config = {
          width = 0.9,
        }
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
      },
      aerial = {
        show_lines = false,
        show_nesting = {
          ['_'] = true, -- This key will be the default
        }
      }
    }
  })

-- Extensions
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'aerial')

--- Insert file path
local action_state = require("telescope.actions.state")
local function insert_selection(prompt_bufnr, map)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)

    local selection = action_state.get_selected_entry()
    local path = selection[1]

    -- Insert the path
    local cursor_pos_visual_start = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local new_line
    local text_before = line:sub(1, cursor_pos_visual_start[2])
    new_line = text_before .. path .. line:sub(cursor_pos_visual_start[2] + 1)
    cursor_pos_visual_start[2] = text_before:len()
    vim.api.nvim_set_current_line(new_line)

    -- Position the cursor at the end of the path
    local cursor_pos_visual_end = { cursor_pos_visual_start[1], cursor_pos_visual_start[2] + path:len() }
    vim.api.nvim_win_set_cursor(0, cursor_pos_visual_end)

    -- Go to insert mode after the path
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a',true,false,true),'m',true)
  end)
  return true
end

--- Keybindings
bind('Search and insert filepath',
  '<c-s>', function()
    builtin.find_files({
      attach_mappings = insert_selection,
    })
  end, {'n', 'i'})

bind('Search files',
  '<c-p>', builtin.find_files)

bind('Search TODO items',
  '<leader>t', function()
    builtin.grep_string({
      search = "TODO",
    })
  end)

bind('List buffers',
  '<leader><leader>', builtin.buffers)

bind('Fuzzily search in current buffer',
  '<leader>b', builtin.current_buffer_fuzzy_find)

bind('Find references for word under cursor',
  '<leader>r', builtin.lsp_references)

bind('Search by grep',
  '<c-c>', builtin.live_grep)

bind('Search local symbols',
  '<leader>l', function()
    require("telescope").extensions.aerial.aerial(require('telescope.themes').get_dropdown({
      previewer = false,
      sorting_strategy = "descending",
    }))
  end)

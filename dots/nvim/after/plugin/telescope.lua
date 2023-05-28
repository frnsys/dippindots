require("ignore")
local actions = require("telescope.actions")

local common_config = {
    theme = "dropdown",
    previewer = false,
}
local common_files_config = {
    mappings = {
        i = {
            -- If file is already open,
            -- switch to its window.
            -- Otherwise replace the current window
            -- with the selected file.
            ["<CR>"] = actions.select_drop,

            -- If file is already open,
            -- switch to its window.
            -- Otherwise open the selected file
            -- in a new tab.
            ["<c-t>"] = actions.select_tab_drop,
        },
    },
    theme = "dropdown",
    previewer = false,
}

require("telescope").setup({
    defaults = {
        path_display = function(opts, path)
          local tail = require("telescope.utils").path_tail(path)
          return string.format("%s (%s)", tail, path)
        end,
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
            },
        },
        file_ignore_patterns = edit_file_ignore_patterns,
    },
    pickers = {
        current_buffer_fuzzy_find = common_config,
        oldfiles = common_files_config,
        find_files = common_files_config,
        buffers = {
            mappings = {
                i = {
                    ["<c-t>"] = actions.select_tab_drop,
                    ["<c-x>"] = "delete_buffer",
                },
            },
            theme = "dropdown",
            previewer = false,
        },
        grep_string = common_config,
        live_grep = { theme = "dropdown", },
        diagnostics = {
            theme = "dropdown",
            previewer = false,
            layout_config = {
                width = 0.9,
            }
        },
        lsp_workspace_symbols = { theme = "ivy" },
    },
    extensions = {
        fzf = {
          fuzzy = true,                    -- false will only do exact matching
          override_generic_sorter = true,  -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
          case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
        },
    }
})

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

vim.keymap.set({'n', 'i'}, '<leader><leader>', function()
    require('telescope.builtin').oldfiles({
        prompt_title = "Recent Files",
        cwd_only = true,
        include_current_session = true,
    })
end, { desc = 'Search files' })

vim.keymap.set({'n', 'i'}, '<C-p>', function()
  require('telescope.builtin').find_files({
      find_command = { "fd", "-t=f" },
  })
end, { desc = 'Search files' })

vim.keymap.set({'n', 'i'}, '<leader>t', function()
  require('telescope.builtin').grep_string({
      search = "TODO",
  })
end, { desc = 'Search TODO items' })

-- vim.keymap.set({'n'}, '<leader><leader>', function()
--     require('telescope.builtin').buffers({
--         show_all_buffers = false,
--
--         -- So the previously used buffer
--         -- is always at top
--         ignore_current_buffer = true,
--         sort_mru = true,
--     })
-- end, { desc = '[ ] Find existing [B]uffers' })

vim.keymap.set('n', '<C-h>', require('telescope.builtin').current_buffer_fuzzy_find, { desc = 'Fuzzily search in current buffer' })
vim.keymap.set('n', '<C-c>', require('telescope.builtin').live_grep, { desc = 'Search by grep' })

-- Insert file path
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

vim.keymap.set({'n', 'i'}, '<C-s>', function()
  require('telescope.builtin').find_files({
    find_command = { "fd", "-t=f" },
    attach_mappings = insert_selection,
  })
end, { desc = 'Search and insert filepath' })

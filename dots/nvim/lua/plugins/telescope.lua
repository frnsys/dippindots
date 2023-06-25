return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/aerial.nvim',

      { -- Requires make
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end
      },
    },
    keys = {
      {'<c-p>', function()
        require('telescope.builtin').find_files()
      end, desc = 'Search files by name'},

      {'<c-c>', function()
        require('telescope.builtin').live_grep()
      end, desc = 'Search by grep'},

      {'<leader>t', function()
        require('telescope.builtin').grep_string({
          prompt_title = "TODO Items",
          search = "TODO",
        })
      end, desc = 'Search TODO items'},

      {'<leader><leader>', function()
        require('telescope.builtin').buffers()
      end, desc = 'List buffers'},

      {'<leader>b', function()
        require('telescope.builtin').current_buffer_fuzzy_find()
      end, desc = 'Fuzzily search in current buffer'},

      {'<leader>f', function()
        require('telescope.builtin').live_grep({
          prompt_title = "Search in Buffers",
          grep_open_files = true,
        })
      end, desc = 'Search by grep in buffers'},

      {'<leader>r', function()
        require('telescope.builtin').lsp_references()
      end, desc = 'Find references for word under cursor'},

      {'<leader>d', function()
        require('telescope.builtin').diagnostics({
          line_width = 120,
          no_sign = true,
          severity = 'error', -- Only show errors
        })
      end, desc = 'List diagnostics'},

      {'<leader>s', function()
        require("telescope").extensions.aerial.aerial(
        require('telescope.themes').get_dropdown({
          previewer = false,
          sorting_strategy = "descending",
        }))
      end, desc = 'Search local symbols'},

      --- Keybindings
      {'<c-y>', function()
        require('telescope.builtin').find_files({
          prompt_title = "Insert Path",
          attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            map({"i", "n"}, "<CR>", function()
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
        })
      end, {'i'}, desc = 'Search and insert filepath'},
    },
    config = function()
      local actions = require("telescope.actions")
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
            path_display = { "tail" },
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
    end
  },
}

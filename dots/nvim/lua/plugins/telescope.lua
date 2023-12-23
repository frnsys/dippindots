--- Keymap prefix: '

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
      { "'m", function()
        require('cairns').telescope_marks()
      end },

      {
        "'f",
        function()
          require('telescope.builtin').find_files()
        end,
        desc = 'Search files by name'
      },

      {
        "'s",
        function()
          require('telescope.builtin').live_grep()
        end,
        desc = 'Search by grep'
      },

      {
        "'t",
        function()
          require('telescope.builtin').grep_string({
            prompt_title = "TODO Items",
            search = "TODO",
          })
        end,
        desc = 'Search TODO items'
      },

      {
        "''",
        function()
          require('telescope.builtin').buffers()
        end,
        desc = 'List buffers'
      },

      {
        "'b",
        function()
          require('telescope.builtin').current_buffer_fuzzy_find()
        end,
        desc = 'Fuzzily search in current buffer'
      },

      {
        "'r",
        function()
          require('telescope.builtin').lsp_references()
        end,
        desc = 'Find references for word under cursor'
      },

      {
        "'d",
        function()
          require('telescope.builtin').diagnostics({
            line_width = 120,
            no_sign = true,
            severity = 'error', -- Only show errors
          })
        end,
        desc = 'List diagnostics'
      },

      {
        "'z",
        function()
          require("telescope").extensions.aerial.aerial({
            sorting_strategy = "descending",
          })
        end,
        desc = 'Search local symbols'
      },

      {
        "'g",
        function()
          require('telescope.builtin').lsp_dynamic_workspace_symbols({
            fname_width = 0,
          })
        end,
        desc = 'Search workspace symbols'
      },

      --- Keybindings
      {
        "'a",
        function()
          require('telescope.builtin').find_files({
            prompt_title = "Insert Path",
            attach_mappings = function(prompt_bufnr, map)
              local actions = require("telescope.actions")
              local action_state = require("telescope.actions.state")
              map({ "i", "n" }, "<CR>", function()
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
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a', true, false, true), 'm', true)
              end)
              return true
            end
          })
        end,
        { 'i' },
        desc = 'Search and insert filepath'
      },
    },
    config = function()
      local actions = require("telescope.actions")

      --- Use flash to jump to telescope resluts
      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            multi_window = true,
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end

      require("telescope").setup({
        defaults = {
          layout_strategy = "bottom_pane",
          layout_config = {
            mirror = true,
            width = 0.95,
            preview_width = 0.4,
          },
          borderchars = {
            prompt = { "-", " ", " ", " ", "-", "-", " ", " " },
            results = { " " },
            preview = { " ", " ", " ", " ", " ", " ", " ", " " },
          },
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

              -- Open the selected file
              -- in a new tab.
              ["<c-n>"] = actions.select_tab,

              -- Use flash to jump to telescope resluts
              ["''"] = flash,
            },
          },
          file_ignore_patterns = edit_file_ignore_patterns,
        },
        pickers = {
          find_files = {
            find_command = { "fd", "-t=f" },
          },
          live_grep = {
            disable_coordinates = true,
          },
          buffers = {
            path_display = { "smart" },
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
            layout_config = {
              width = 0.9,
            }
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
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

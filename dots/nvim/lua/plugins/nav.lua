return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    opts = {
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["q"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["g."] = "actions.toggle_hidden",
      },
      use_default_keymaps = false,
      view_options = {
        -- Check against ignore patterns to
        -- determine what files to hide
        is_hidden_file = function(name, bufnr)
          if vim.startswith(name, ".") then
            return true
          end
          if name == "target" then
            return true
          end
          for _, pat in ipairs(edit_file_ignore_patterns) do
            if name:match(pat) then
              return true
            end
          end
          return false
        end,
      },
    },
    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Open parent directory"
      }
    }
  },

  --- Bindings:
  ---
  --- Custom:
  --- [ctrl-q]: send results to quickfix list
  ---
  --- Default:
  --- [ctrl-u]: clear search query
  --- [ctrl-g]: fuzzy search results
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup({
        defaults = {
          file_icons = false,
          no_header = true,
          no_header_i = true,

          -- Required to use the fzf highlight
          -- groups defined below.
          fzf_colors = true,
        },
        files = {
          formatter = "path.filename_first",
          actions = { ["ctrl-q"] = { fn = require("fzf-lua").actions.file_sel_to_qf, prefix = "select-all" } },
        },
        grep = {
          formatter = "path.filename_first",
          rg_opts = "--no-heading --color=always --colors 'match:fg:0xff,0x5c,0x5c' --smart-case --max-columns=4096 -e",
          actions = {
            ["ctrl-q"] = {
              fn = require("fzf-lua").actions.file_edit_or_qf, prefix = 'select-all+'
            },
          },
        },
        previewers = {
          bat = {
            cmd   = "bat",
            args  = "--color=always --style=plain",
            theme = '1337',
          },
        },
        winopts = {
          width = 64,
          preview = {
            default = "bat",
            layout = "vertical",
            vertical = "down:70%",
            border = "border-top",
          },
        },
        hls = {
          border = "Keyword",
          fzf = {
            info = "Special",
            query = "Normal",
            prompt = "Keyword",
            pointer = "Function",
            match = "@property",
            separator = "Keyword",
            border = "Keyword",
          },
        },
      })
    end,
    keys = {
      {
        "<leader>f",
        function()
          require('fzf-lua').files()
        end,
        desc = 'Search files by name'
      },
      {
        "<leader>s",
        function()
          require('fzf-lua').live_grep_glob()
        end,
        desc = 'Search by grep'
      },
      {
        "<leader><leader>",
        function()
          require('fzf-lua').lines()
        end,
        desc = 'Search buffer lines'
      },
      {
        "<leader>r",
        function()
          require('fzf-lua').lsp_references()
        end,
        desc = 'Find references for word under cursor'
      },
      {
        "<leader>i",
        function()
          require('fzf-lua').complete_path()
        end,
        desc = 'Complete path'
      },
    },
  },

  --- Like <c-i> and <c-o> but
  --- goes across buffers instead of
  --- within a buffer.
  {
    'kwkarlwang/bufjump.nvim',
    config = function()
      require("bufjump").setup({
        forward_key = "<S-j>",
        backward_key = "<S-k>",
        on_success = nil
      })
    end,
  },

  {
    "yorickpeterse/nvim-window",
    keys = {
      { ",,", function()
        local win_count = vim.fn.winnr('$')

        -- If there are only two windows,
        -- jump to the other one.
        if win_count == 2 then
            -- Switch to the other window
            vim.cmd('wincmd w')

        -- Otherwise use the picker.
        else
          require('nvim-window').pick()
        end
      end, desc = "nvim-window: Jump to window" },
    },
    config = function()
      require('nvim-window').setup({
        -- The characters available for hinting windows.
        chars = {
          'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'
        },
        normal_hl = 'WindowTarget',
        border = 'none',
      })
    end,
  },

  {
    'declancm/maximize.nvim',
    config = true,
    keys = {
      {
        "mm",
        function()
          require('maximize').toggle()
        end,
        desc = 'Toggle maximize'
      }
    }
  },
}

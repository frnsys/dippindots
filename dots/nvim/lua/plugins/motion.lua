return {
  --- Substitute motion
  {
    'gbprod/substitute.nvim',
    opts = {},
    keys = {
      -- e.g. siw
      { 's', function()
        require('substitute').operator()
      end, { 'n' } },

      { 'ss', function()
        require('substitute').line()
      end },
    },
  },

  {
    "chrisgrieser/nvim-various-textobjs",
    lazy = false,
    config = function()
      require("various-textobjs").setup({
        keymaps = {
          -- io/ao: any bracket
          -- n: end of line excluding last character
          -- Q: to next quote
          -- C: to next bracket
          -- ii/ai: lines w/ matching indentation
          -- R: rest of lines w/ matching indentation
          -- See: https://github.com/chrisgrieser/nvim-various-textobjs?tab=readme-ov-file#list-of-text-obj
          useDefaults = true
        }
      })

      -- iu/au: any quote
      vim.keymap.set({ "o", "x" }, "au", '<cmd>lua require("various-textobjs").anyQuote("outer")<CR>')
      vim.keymap.set({ "o", "x" }, "iu", '<cmd>lua require("various-textobjs").anyQuote("inner")<CR>')
    end
  },

  --- Faster movement within buffers
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      search = {
        multi_window = false,
        incremental = false,
        mode = 'fuzzy',
      },
      label = {
        after = true,
        before = true,
        rainbow = {
          enabled = true,
          shade = 5,
        }
      },
      modes = {
        search = {
          enabled = true,
        },
        char = {
          enabled = false,
        }
      },
      prompt = {
        enabled = false,
      }
    },
    keys = {
      {
        "<c-f>",
        mode = { "n" },
        function()
          require("flash").jump({
            label = {
              before = false,
              after = true,
            },
            search = {
              wrap = true,
              mode = "exact",
              multi_window = false,
            }
          })
        end,
        desc = "Flash jump visible buffer",
      },

      {
        "f",
        mode = { "n" },
        function()
          require("flash").jump({
            label = {
              before = false,
              after = true,
            },
            mode = "char",
            search = {
              wrap = false,
              mode = "exact",
              max_length = 1,
              forward = true,
            }
          })
        end,
        desc = "Flash jump visible buffer",
      },
      {
        "F",
        mode = { "n" },
        function()
          require("flash").jump({
            label = {
              before = false,
              after = true,
            },
            mode = "char",
            search = {
              wrap = false,
              mode = "exact",
              max_length = 1,
              forward = false,
            }
          })
        end,
        desc = "Flash jump visible buffer",
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    main = 'nvim-treesitter.configs',
    opts = {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        'c', 'cpp', 'python', 'rust', 'tsx',
        'typescript', 'c_sharp', 'css', 'scss', 'toml',
        'markdown', 'markdown_inline', 'bash', 'lua',
        'html', 'javascript', 'json', 'yaml', 'comment' },

      -- Autoinstall languages that are not installed.
      auto_install = true,

      highlight = { enable = true },
      indent = { enable = false },
      incremental_selection = {
        enable = false,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['im'] = '@block.inner',
            ['am'] = '@block.outer',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']'] = '@class.outer',
            [')'] = '@function.outer',
            ['>'] = '@block.inner',
            ['.a'] = '@parameter.inner',
            ['.n'] = '@number.inner',
            ['.s'] = '@comment.outer',
          },
          goto_previous_start = {
            ['['] = '@class.outer',
            ['('] = '@function.outer',
            ['<'] = '@block.inner',
            [',a'] = '@parameter.inner',
            [',n'] = '@number.inner',
            [',s'] = '@comment.outer',
          },
        },
      },
    }
  }
}

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
        mode = 'exact',
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
              wrap = true,
              mode = "exact",
              multi_window = false,
            }
          })
        end,
        desc = "Flash jump visible buffer",
      },
      {
        "<space>t",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter"
      },

      --- Select word.
      {
        "<space>w",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            pattern = "\\<\\w*",
            search = { wrap = true, mode = "search", max_length = 0 },
            label = {
              before = true,
              after = false,
            },
            jump = { pos = "range" },
            -- Use this to jump to start:
            -- jump = { pos = "start" },
          })
        end,
      },

      --- Select between two delimiters.
      -- NOTE: This doesn't work well with
      -- nested delimiters...
      {
        "F",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            -- Note: `\zs` and `\ze` indicate
            -- the start/end of the selection.
            pattern = "[\\[<{(|]\\zs[^\\[{(<|>)}\\]]*\\ze[|)}>\\]]",
            search = { wrap = true, mode = "search", max_length = 0 },
            label = {
              before = true,
              after = true,
            },
            jump = { pos = "range" },
          })
        end,
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
            [','] = '@statement.outer',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']'] = '@class.outer',
            [')'] = '@function.outer',
            ['.m'] = '@block.inner',
            ['.a'] = '@parameter.inner',
            ['.s'] = '@comment.outer',
            ['<c-f>'] = '@statement.outer',
          },
          -- TODO perhaps use exclaation and semicolon
          -- tab & ampersand
          -- octothorpe & backslash
          goto_previous_start = {
            ['['] = '@class.outer',
            ['('] = '@function.outer',
            [',m'] = '@block.inner',
            [',a'] = '@parameter.inner',
            [',s'] = '@comment.outer',
            ['<c-e>'] = '@statement.outer',
          },
        },
      },
    }
  }
}

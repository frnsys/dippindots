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
    "backdround/neowords.nvim",
    config = function()
      --- https://github.com/backdround/neowords.nvim/blob/main/lua/neowords/pattern-presets.lua
      local neowords = require("neowords")
      local p = neowords.pattern_presets

      local bigword_hops = neowords.get_word_hops(
        p.any_word,
        "\\v$", -- Also stop at the end of the line
        "\\v^", -- Also stop at the start of the line
        "\\v%([[:blank:]])@<=[[:punct:]]{2,}" -- Treat sequences of 2 or more punct as a word, preceded by whitespace
      )
      vim.keymap.set({ "n", "x" }, "R", bigword_hops.forward_start)
      vim.keymap.set({ "n", "x" }, "M", bigword_hops.backward_start)
      vim.keymap.set({ "n", "x" }, "E", bigword_hops.forward_end)

      local bigword_change = neowords.get_word_hops(
        "[-_[:lower:][:upper:][:digit:]]+",
        "[[:punct:]]"
      )
      vim.keymap.set({ "o" }, "R", bigword_change.forward_start)
      vim.keymap.set({ "o" }, "M", bigword_change.backward_start)
      vim.keymap.set({ "o" }, "E", bigword_change.forward_end)

      local subword_hops = neowords.get_word_hops(
        p.snake_case,
        p.camel_case,
        p.upper_case,
        p.number,
        p.hex_color,
        "\\v$", -- Also stop at the end of the line
        "\\v^", -- Also stop at the start of the line
        "\\v[[:punct:]]{2,}" -- Treat sequences of 2 or more punct as a word
      )
      vim.keymap.set({ "n", "x", "o" }, "r", subword_hops.forward_start)
      vim.keymap.set({ "n", "x", "o" }, "m", subword_hops.backward_start)
      vim.keymap.set({ "n", "x", "o" }, "e", subword_hops.forward_end)
    end
  },

  {
    "echasnovski/mini.ai",
    config = function()
      local ai = require('mini.ai')
      ai.setup({
        custom_textobjects = {
          ['r'] = { { "%b''", '%b""', '%b``' }, '^.().*().$' },
          ['t'] = { { '%b()', '%b[]', '%b{}', '%b<>', '%b||' }, '^.().*().$' } },

          ['a'] = ai.gen_spec.argument(),
          ['f'] = ai.gen_spec.function_call(),
      })
    end
  },

  --- `i` indent scope object
  {
    "echasnovski/mini.indentscope",
    config = function()
      require('mini.indentscope').setup()
    end
  },

  --- Faster movement within buffers
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "nrtscbwhaeimldpfoumk",
      label = {
        after = true,
        before = true,
      },
      modes = {
        char = {
          enabled = true,
          jump_labels = true,
        },
        search = {
          enabled = true,
          multi_window = false,
          incremental = true,
          mode = 'exact',
        },
      },
      prompt = { enabled = false },
    },
    keys = {
      -- Unused: Y, w, b, k, =, \, H

      --- Jump to (start of) line.
      {
        "<c-a>",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            search = { mode = "search", max_length = 0 },
            label = { after = { 0, 0 }, before = false },
            pattern = "^\\s*\\zs\\S"
          })
        end
      },

      {
        "'",
        mode = { "n", "x", "o" },
        function()
          local matchers = require("../matchers")
          require("flash").jump({
            matcher = matchers.ts_matcher("assignment"),
            search = { mode = "search", max_length = 0 },
            jump = { pos = "range", autojump = true },
          })
        end
      },

      {
        "\"",
        mode = { "n", "x", "o" },
        function()
          local matchers = require("../matchers")
          require("flash").jump({
            matcher = matchers.ts_matcher("statement"),
            search = { mode = "search", max_length = 0 },
            jump = { pos = "range", autojump = true },
          })
        end
      },

      {
        "U",
        mode = { "n", "x", "o" },
        function()
          local matchers = require("../matchers")
          require("flash").jump({
            matcher = matchers.delim_matcher({
                { '"', '"' },
                { "'", "'" },
                { '`', '`' },
            }, false),
            search = { mode = "search", max_length = 0 },
            jump = { pos = "range", autojump = true },
          })
        end
      },

      {
        "u",
        mode = { "n", "x", "o" },
        function()
          local matchers = require("../matchers")
          require("flash").jump({
            matcher = matchers.delim_matcher({
                { '(', ')' },
                { '[', ']' },
                { '<', '>' },
                { '{', '}' },
                { '|', '|' },
            }, false),
            search = { mode = "search", max_length = 0 },
            jump = { pos = "range", autojump = true },
          })
        end
      },

      --- Jump to word.
      {
        "h",
        mode = { "n", "x", "o" },
        function()
          local flash = require("flash")

          local function format(opts)
            -- always show first and second label
            return {
              { opts.match.label1, "FlashLabel" },
              { opts.match.label2, "FlashLabel" },
            }
          end

          flash.jump({
            search = { mode = "search" },
            label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
            pattern = [[\<]],
            action = function(match, state)
              state:hide()
              flash.jump({
                search = { max_length = 0 },
                highlight = { matches = false },
                label = { after = false, before = { 0, 0 }, format = format },
                matcher = function(win)
                  -- limit matches to the current label
                  return vim.tbl_filter(function(m)
                    return m.label == match.label and m.win == win
                  end, state.results)
                end,
                labeler = function(matches)
                  for _, m in ipairs(matches) do
                    m.label = m.label2 -- use the second label
                  end
                end,
              })
            end,
            labeler = function(matches, state)
              local labels = state:labels()
              for m, match in ipairs(matches) do
                match.label1 = labels[math.floor((m - 1) / #labels) + 1]
                match.label2 = labels[(m - 1) % #labels + 1]
                match.label = match.label1
              end
            end,
          })
        end,
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'c', 'cpp', 'python', 'rust', 'tsx',
        'typescript', 'c_sharp', 'css', 'scss', 'toml',
        'markdown', 'markdown_inline', 'bash', 'lua',
        'html', 'javascript', 'json', 'yaml', 'comment' },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = false },
        incremental_selection = { enable = false },
      }
    }
  }

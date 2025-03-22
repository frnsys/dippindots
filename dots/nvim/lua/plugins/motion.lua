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
      local neowords = require("neowords")
      local p = neowords.pattern_presets

      local bigword_hops = neowords.get_word_hops(
        p.any_word,
        p.hex_color
      )
      vim.keymap.set({ "n", "x" }, "W", bigword_hops.forward_start)
      vim.keymap.set({ "n", "x" }, "E", bigword_hops.forward_end)
      vim.keymap.set({ "n", "x" }, "B", bigword_hops.backward_start)

      local subword_hops = neowords.get_word_hops(
        p.snake_case,
        p.camel_case,
        p.upper_case,
        p.number,
        p.hex_color
      )
      vim.keymap.set({ "n", "x" }, "w", subword_hops.forward_start)
      vim.keymap.set({ "n", "x" }, "e", subword_hops.forward_end)
      vim.keymap.set({ "n", "x" }, "b", subword_hops.backward_start)
    end
  },

  {
    "echasnovski/mini.ai",
    opts = {}
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
        ",,",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter"
      },

      --- Jump to word.
      {
        "f",
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

      --- Jump to the start of a delimiter pair.
      -- NOTE: This doesn't work well with
      -- nested delimiters...
      {
        "..",
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
            -- jump = { pos = "range" },
            jump = { pos = "start" },
          })
        end,
      },
    },
  },

  {
    'aaronik/treewalker.nvim',
    keys = {
      {
        "[",
        mode = { "n", "v" },
        nowait = true,
        function()
          vim.cmd([[Treewalker Left]])
        end
      },
      {
        "]",
        mode = { "n", "v" },
        nowait = true,
        function()
          vim.cmd([[Treewalker Right]])
        end
      },
      {
        "(",
        mode = { "n", "v" },
        function()
          vim.cmd([[Treewalker Up]])
        end
      },
      {
        ")",
        mode = { "n", "v" },
        function()
          vim.cmd([[Treewalker Down]])
        end
      }
    }
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

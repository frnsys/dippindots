vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/gbprod/substitute.nvim",
  "https://github.com/backdround/neowords.nvim",
  "https://github.com/echasnovski/mini.ai",
  "https://github.com/echasnovski/mini.indentscope",
  "https://github.com/folke/flash.nvim",
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    'c', 'cpp', 'python', 'rust', 'tsx',
    'typescript', 'c_sharp', 'css', 'scss', 'toml',
    'markdown', 'markdown_inline', 'bash', 'lua',
    'html', 'javascript', 'json', 'yaml', 'comment'
  },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = false },
  incremental_selection = { enable = false },
})

local ai = require('mini.ai')
ai.setup({
  custom_textobjects = {
    ['r'] = { { "%b''", '%b""', '%b``' }, '^.().*().$' },
    ['t'] = { { '%b()', '%b[]', '%b{}', '%b<>', '%b||' }, '^.().*().$' },

    -- Note: requires `nvim-treesitter/nvim-treesitter-textobjects`
    ['f'] = ai.gen_spec.treesitter({
      a = '@function.outer', i = '@function.inner' }),

    ['a'] = ai.gen_spec.argument({
      brackets = { '%b()', '%b[]', '%b{}', '%b<>', '%b||' },
      exclude_regions = { '%b""', "%b''", '%b()', '%b[]', '%b{}', '%b<>' },
    }),
  },
})

--- `cw` is an awkward sequence on my layout,
--- so use `r` instead (for e.g. `rw`).
vim.keymap.set({ "n" }, "r", "c")

--- Substitute motions
-- e.g. siw
require("substitute").setup()
vim.keymap.set("n", "s", require("substitute").operator)
vim.keymap.set("n", "ss", require("substitute").line)

--- https://github.com/backdround/neowords.nvim/blob/main/lua/neowords/pattern-presets.lua
local neowords = require("neowords")
local p = neowords.pattern_presets

local bigword_hops = neowords.get_word_hops(
  p.any_word,
  "\\v$", -- Also stop at the end of the line
  "\\v^", -- Also stop at the start of the line
  "\\v%([[:blank:]])@<=[[:punct:]]{2,}" -- Treat sequences of 2 or more punct as a word, preceded by whitespace
)
vim.keymap.set({ "n", "x" }, "W", bigword_hops.forward_start)
vim.keymap.set({ "n", "x" }, "M", bigword_hops.backward_start)
vim.keymap.set({ "n", "x" }, "E", bigword_hops.forward_end)

local bigword_change = neowords.get_word_hops(
  "[-_[:lower:][:upper:][:digit:]]+",
  "[[:punct:]]"
)
vim.keymap.set({ "o" }, "W", bigword_change.forward_start)
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
vim.keymap.set({ "n", "x", "o" }, "w", subword_hops.forward_start)
vim.keymap.set({ "n", "x", "o" }, "m", subword_hops.backward_start)
vim.keymap.set({ "n", "x", "o" }, "e", subword_hops.forward_end)

--- `i` indent scope object
require('mini.indentscope').setup()

require("flash").setup({
  labels = "nrtschaeimldpfoumbwkyx",
  label = {
    after = true,
    before = true,
  },
  modes = {
    char = {
      enabled = true,
      jump_labels = true,
      label = { exclude = "zb" },
      keys = {
        -- "t", "T",

        -- Easier than f/F
        ["f"] = "h",
        ["F"] = "<c-h>",
      }
    },
    search = {
      enabled = true,
      multi_window = false,
      incremental = true,
      mode = 'exact',
    },
  },
  prompt = { enabled = false },
})


--- Jump to (start of) line.
vim.keymap.set({"n", "x", "o"}, "<c-a>", function()
  require("flash").jump({
    search = { mode = "search", max_length = 0 },
    label = { after = { 0, 0 }, before = false },
    pattern = "^\\s*\\zs\\S"
  })
end)

local matchers = require("./matchers")
local function flash_ts(kind)
  function inner()
    require("flash").jump({
      matcher = matchers.ts_matcher(kind),
      search = { mode = "search", max_length = 0, multi_window = false },
      jump = { pos = "range", autojump = true },
    })
  end
  return inner
end
local function flash_delim(delims)
  function inner()
    require("flash").jump({
      matcher = matchers.delim_matcher(delims, false),
      search = { mode = "search", max_length = 0 },
      jump = { pos = "range", autojump = true },
    })
  end
  return inner
end

vim.keymap.set({"n"}, "=", flash_ts("left_right"))
vim.keymap.set({"n", "x", "o"}, "<c-f>", flash_ts("list_item"))
vim.keymap.set({"n", "x", "o"}, "k", flash_ts("statement"))

vim.keymap.set({"n"}, "'", flash_delim({
  { '"', '"' },
  { "'", "'" },
  { '`', '`' },
}))

vim.keymap.set({"n", "x", "o"}, "u", flash_delim({
  { '(', ')' },
  { '[', ']' },
  { '{', '}' },
}))

vim.keymap.set({"n", "x", "o"}, "U", flash_delim({
  { '<', '>' },
  { '|', '|' },
}))

--- Motion helpers
-- Better to come after flash setup to avoid overwriting.

-- , => up to next comma, e.g. `c,`
vim.keymap.set({ "o", "x" }, ",", "t,")

-- ) => up to next ), e.g. `c)`
vim.keymap.set({ "o", "x" }, ")", "t)")

-- ; => up to next ;, e.g. `c;`
vim.keymap.set({ "o", "x" }, ";", "t;")

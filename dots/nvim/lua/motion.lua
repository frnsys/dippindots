vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/gbprod/substitute.nvim",
  "https://github.com/backdround/neowords.nvim",
  "https://github.com/chrisgrieser/nvim-spider",
  "https://github.com/echasnovski/mini.ai",
  "https://github.com/echasnovski/mini.indentscope",
  "https://github.com/folke/flash.nvim",
})

require("nvim-treesitter").install({
  'c', 'cpp', 'python', 'rust', 'tsx', 'typescript',
  'c_sharp', 'css', 'scss', 'toml', 'lua',
  'markdown', 'markdown_inline', 'bash', 'gitcommit',
  'html', 'javascript', 'json', 'yaml', 'comment',
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function() vim.treesitter.start() end,
})

local ai = require('mini.ai')
ai.setup({
  custom_textobjects = {
    ['r'] = { { "%b''", '%b""', '%b``' }, '^.().*().$' },
    ['t'] = { { '%b()', '%b[]', '%b{}', '%b<>', '%b||' }, '^.().*().$' },

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
vim.keymap.set("x", "s", require("substitute").visual)
vim.keymap.set("n", "ss", require("substitute").line)

require("spider").setup({
	skipInsignificantPunctuation = true,
	subwordMovement = true,
	consistentOperatorPending = false,
	customPatterns = {},
})
vim.keymap.set({ "n", "o", "x" }, "w", function() require('spider').motion('w') end)
vim.keymap.set({ "n", "o", "x" }, "e", function() require('spider').motion('e') end)
vim.keymap.set({ "n", "o", "x" }, "m", function() require('spider').motion('b') end)
vim.keymap.set({ "n", "o", "x" }, "M", "B")

--- Make word operations more intuitive
-- Consider
--
--  foo); bar
--  ^
--
-- `w` would make this jump:
--
--  foo); bar
--  >-----^
--
-- and `cw` would replace that same span, leading to:
--
--  ______bar
--
-- when in practice you generally want:
--
--  ___); bar
--
-- i.e. you just want to change the word `foo` and
-- not the punctuation that follows.
--
-- So technically when you do `cw` you really want `ce`.
vim.keymap.set("n", "rw", "ce", { remap = true })
vim.keymap.set("n", "dw", "de", { remap = true })
vim.keymap.set("n", "sw", "se", { remap = true })
vim.keymap.set("n", "yw", "ye", { remap = true })

--- `i` indent scope object
require('mini.indentscope').setup()

require("flash").setup({
  labels = "nrtschaeimldpfoumbwkyxz.,'",
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
        -- Easier than f/F
        ["f"] = "h",
        ["F"] = "H",
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

vim.keymap.set({"n"}, "f", flash_delim({
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

-- Up to first ), ], >, ;, "
vim.keymap.set({ "o", "x" }, "'", "/\\%.l[)\\]>;\"]<cr>")

-- Easier dot repeat
vim.keymap.set("n", "'", ".")


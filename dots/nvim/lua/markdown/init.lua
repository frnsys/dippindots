vim.pack.add({
  "https://github.com/lukas-reineke/headlines.nvim",
  "https://github.com/shortcuts/no-neck-pain.nvim",
})

--- Nicer markdown headings.
require("headlines").setup({
  markdown = {
    bullets = { "", "", "", "" },
    headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4" },
    fat_headlines = false,
  },
})

require("no-neck-pain").setup({
  buffers = {
    wo = {
      fillchars = "eob: ",
    },
  },
})

-- Auto-load NoNeckPain for markdown files
vim.api.nvim_create_autocmd({"BufEnter"}, {
  pattern = "*",
  callback = function()
    vim.schedule(function()
      local filetype = vim.api.nvim_buf_get_option(0, "filetype")
      local enabled =  _G.NoNeckPain.state ~= nil and _G.NoNeckPain.state.enabled

      if (filetype == "markdown" and not enabled) or
        (filetype ~= 'markdown' and filetype ~= 'oil' and filetype ~= 'no-neck-pain' and filetype ~= 'qf' and enabled) then
        return vim.cmd("NoNeckPain")
      end
    end)
  end,
})


--- Insert text at current cursor position.
local function insert_text_at_cursor(text)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Get current cursor position
  row = row - 1  -- Convert to zero-based indexing

  -- Ensure the buffer is not read-only
  if vim.api.nvim_buf_get_option(0, 'modifiable') then
    vim.api.nvim_buf_set_text(0, row, col, row, col, {text})
  else
    print("Buffer is read-only")
  end
end

--- Screenshot, move to assets folder, paste in markdown.
local function screenshot()
  local fpath = vim.fn.system {
    'shot',
    'region',
    'path',
  }
  fpath = fpath:gsub("\n", "")
  if vim.fn.filereadable(fpath) == 1 then
    local fname = vim.fs.basename(fpath)
    local dir = vim.fn.expand('%:p:h')
    local relpath = "assets/" .. fname
    os.rename(fpath, dir .. "/" .. relpath)
    local img_ref = "![screenshot](" .. relpath .. ")"
    insert_text_at_cursor(img_ref)
  end
end

--- Toggle a markdown checkbox.
function toggle_checkbox()
  local line = vim.fn.getline(".")
  if line:match("- %[ %]") then
    local line = line:gsub("- %[ %]", "- [x]")
    vim.fn.setline(".", line)
  elseif line:match("- %[x%]") then
    local line = line:gsub("- %[x%]", "- [ ]")
    vim.fn.setline(".", line)
  end
end

local media = require("markdown/media")
local footnote = require("markdown/footnote")

-- Disable line numbers
vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.fillchars = "eob: " -- Removes ~ lines at the end of buffer

vim.wo.spell = true
vim.wo.linebreak = true
vim.opt.cursorcolumn = false
vim.opt.complete:append("kspell")

local opts = { noremap = true, buffer = 0 }
vim.keymap.set('n', ',S', screenshot, opts)
vim.keymap.set('n', ',s', toggle_checkbox, opts)
vim.keymap.set('n', 'gv', media.open_url_under_cursor, opts)

vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = "*.md",
  callback = media.auto_preview_image,
})

-- Quickly fix the closest previous spelling error
vim.api.nvim_buf_set_keymap(0, "i", "<leader>z", "<C-g>u<Esc>[s1z=`]a<C-g>u", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<leader>z", "[s1z=``", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>n", footnote.handle_footnote, opts)
vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = "*.md",
  callback = footnote.preview_footnote
})

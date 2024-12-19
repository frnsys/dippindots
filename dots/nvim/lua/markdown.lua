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

--- Open markdown syntax urlslk
---   - Open local images with `vu`
---   - Open local videos with `mp4`
function open_url_under_cursor()
  local lnum = vim.fn.line(".")
  local line = vim.fn.getline(lnum)
  local coln = vim.fn.col(".") - 1 -- Lua is 0-indexed for strings

  -- Find the start of the URL or object
  local lcol = coln
  while lcol >= 0 and line:sub(lcol + 1, lcol + 1) ~= "(" and line:sub(lcol + 1, lcol + 1) ~= "<" do
    lcol = lcol - 1
  end

  -- Find the end of the URL or object
  local rcol = coln
  while rcol <= #line and line:sub(rcol + 1, rcol + 1) ~= ")" and line:sub(rcol + 1, rcol + 1) ~= ">" do
    rcol = rcol + 1
  end

  -- Extract the object
  local obj = line:sub(lcol + 2, rcol)
  local url = obj:match("(http[s]?://[^ >,;]*)")
  local img = obj:match("([^<>()]+%.(jpg|jpeg|png|gif|mp4|webp))")

  if url then
    vim.fn.system({ "firefox", vim.fn.fnameescape(url) })
  elseif img then
    local img_path = vim.fn.expand("%:p:h") .. "/" .. img
    if img:match("%.mp4$") or img:match("%.webm$") then
      vim.fn.jobstart({ "mpv", img_path })
    else
      vim.fn.jobstart({ "vu", img_path })
    end
  else
    vim.api.nvim_echo({ { "The cursor is not on a link.", "WarningMsg" } }, true, {})
  end
end

local preview_path = ""
local preview_jobid = nil
local function close_preview_image()
  if preview_jobid then
    vim.fn.jobstop(preview_jobid)
    preview_jobid = nil
    preview_path = ""
  end
end

local function auto_preview_image()
  local lnum = vim.fn.line(".")
  local line = vim.fn.getline(lnum)
  local coln = vim.fn.col(".") - 1 -- Lua indexing

  -- Find the left boundary of the object
  local lcol = coln
  while lcol >= 0 and line:sub(lcol + 1, lcol + 1) ~= "(" and line:sub(lcol + 1, lcol + 1) ~= "<" do
    lcol = lcol - 1
  end

  -- Handle potentially nested parentheses
  local open_parens = 0
  local rcol = coln
  while rcol <= #line and line:sub(rcol + 1, rcol + 1) ~= ">" do
    if line:sub(rcol + 1, rcol + 1) == "(" then
      open_parens = open_parens + 1
    elseif line:sub(rcol + 1, rcol + 1) == ")" then
      if open_parens == 0 then
        break
      end
      open_parens = open_parens - 1
    end
    rcol = rcol + 1
  end

  -- Extract the object
  local obj = line:sub(lcol + 2, rcol) -- Adjust indices for Lua substring
  local caption = obj:match("!%[[^%]]+%]")
  if caption == nil then
    return
  end
  local path = obj:sub(#caption + 2, #obj - 1) -- Skip caption and surrounding ()
  local img = path:match("%.(jpg|jpeg|png|webp|gif)$")

  if img then
    if path ~= preview_path then
      close_image_preview()
      preview_jobid = vim.fn.jobstart({
        "vu",
        vim.fn.expand("%:p:h") .. "/" .. path,
        "--title",
        "md-vu-preview",
        "--no-focus",
      })
      preview_path = path
    end
  else
    close_preview_image()
  end
end

vim.api.nvim_create_augroup("MarkdownSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = "MarkdownSettings",
    pattern = "markdown",
    callback = function()
        -- Disable line numbers
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.fillchars = "eob: " -- Removes ~ lines at the end of buffer

        vim.wo.spell = true
        vim.wo.linebreak = true
        vim.opt.cursorcolumn = false
        vim.opt.complete:append("kspell")

        local opts = { noremap = true, buffer = 0 }
        vim.keymap.set('n', ',s', screenshot, opts)
        vim.keymap.set('n', '<leader>x', toggle_checkbox, opts)
        vim.keymap.set('n', 'gx', open_url_under_cursor, opts)

        vim.api.nvim_create_autocmd("CursorMoved", {
          pattern = "*.md",
          callback = auto_preview_image,
        })

        -- Quickly fix the closest previous spelling error
        vim.api.nvim_buf_set_keymap(0, "i", "<C-S-k>", "<C-g>u<Esc>[s1z=`]a<C-g>u", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, "n", "<C-S-k>", "[s1z=``", { noremap = true, silent = true })

        vim.keymap.set("n", "<leader>n", function()
          require("fnotes").handle_footnote()
        end, opts)
        vim.api.nvim_create_autocmd("CursorMoved", {
          pattern = "*.md",
          callback = function()
            require("fnotes").preview_footnote()
          end
        })
    end,
})

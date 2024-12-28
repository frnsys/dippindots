local M = {}

--- Open markdown syntax urls
---   - Open local images with `vu`
---   - Open local videos with `mp4`
function M.open_url_under_cursor()
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

function M.auto_preview_image()
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

return M

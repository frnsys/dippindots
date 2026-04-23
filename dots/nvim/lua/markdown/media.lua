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
    vim.fn.system({ "qutebrowser", vim.fn.fnameescape(url) })
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
function close_preview_image()
  if preview_jobid then
    vim.fn.jobstop(preview_jobid)
    preview_jobid = nil
    preview_path = ""
  end
end

function M.auto_preview_image()
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".") -- 1-based indexing for vim.fn.col

  local pattern = "(!%b[]%b())"

  local found_path = nil
  local start_pos = 1

  while true do
    local s, e, whole_match = line:find(pattern, start_pos)
    if not s then break end

    -- Check if cursor is within this specific match
    if col >= s and col <= e then
      -- Extract path from the %b() part (remove the surrounding parens)
      local caption_part, path_part = whole_match:match("(!%b[])(%b())")
      if path_part then
        found_path = path_part:sub(2, -2) -- Strip the '(' and ')'
      end
      break
    end
    start_pos = e + 1
  end

  if not found_path then
    close_preview_image()
    return
  end

  local allowed = {
      jpg = true,
      jpeg = true,
      png = true,
      webp = true,
      gif = true,
  }
  local ext = found_path:match("%.([%a%d]+)$")
  local is_image = ext and allowed[ext:lower()]

  if is_image then
    if found_path ~= preview_path then
      close_preview_image()
      preview_jobid = vim.fn.jobstart({
        "vu",
        vim.fn.expand("%:p:h") .. "/" .. found_path,
        "--max-side",
        "400",
        "--title",
        "md-vu-preview"
      })
      preview_path = found_path
    end
  else
    close_preview_image()
  end
end

return M

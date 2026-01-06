vim.filetype.add({
  extension = {
    script = "verses",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "verses" },
  callback = function()
    vim.opt_local.softtabstop = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.lsp.config["verses"] = {
  -- Debugging
  -- cmd = { '/home/francis/projects/fugue/tools/target/debug/verses', 'lsp' },
  cmd = { 'verses', 'lsp' },
  filetypes = { "verses" },
  root_markers = { ".git" },
}
vim.lsp.enable('verses')

-- verses-map
local M = {}

local uv = vim.uv or vim.loop
local augroup = vim.api.nvim_create_augroup("verses-map", { clear = true })

M.config = {
  host = "127.0.0.1",
  port = 8800,
}
M._tcp = nil
M._readbuf = ""
M._connected = false
M._skip_next = false

-- Connect to the server over TCP
local function ensure_connection()
  if M._connected and M._tcp then
    return
  end

  local tcp = uv.new_tcp()
  if not tcp then
    vim.notify("[verses-map] Failed to create TCP handle", vim.log.levels.ERROR)
    return
  end

  tcp:connect(M.config.host, M.config.port, function(err)
    if err then
      vim.schedule(function()
        vim.notify("[verses-map] TCP connect error: " .. err, vim.log.levels.ERROR)
      end)
      tcp:close()
      return
    end

    M._tcp = tcp
    M._connected = true

    vim.schedule(function()
      vim.notify(string.format(
        "[verses-map] Connected to %s:%d",
        M.config.host,
        M.config.port
      ), vim.log.levels.INFO)
    end)

    -- Start reading from the server
    tcp:read_start(function(rerr, chunk)
      if rerr then
        vim.schedule(function()
          vim.notify("[verses-map] Read error: " .. rerr, vim.log.levels.ERROR)
        end)
        return
      end

      if chunk == nil then
        -- EOF
        vim.schedule(function()
          vim.notify("[verses-map] Server closed connection", vim.log.levels.WARN)
        end)
        M._connected = false
        M._tcp = nil
        tcp:close()
        return
      end

      M._readbuf = M._readbuf .. chunk

      while true do
        local nl = M._readbuf:find("\n", 1, true)
        if not nl then
          break
        end
        local line = M._readbuf:sub(1, nl - 1)
        M._readbuf = M._readbuf:sub(nl + 1)
        M.handle_message(line)
      end
    end)
  end)
end

local function send_json(obj)
  if not (M._connected and M._tcp) then
    return
  end
  local ok, encoded = pcall(vim.json.encode, obj)
  if not ok then
    return
  end
  M._tcp:write(encoded .. "\n")
end

local function get_cursor_byte_offset(bufnr, winid)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  winid = winid or vim.api.nvim_get_current_win()

  local pos = vim.api.nvim_win_get_cursor(winid)
  local row, col = pos[1], pos[2]
  local line_start = vim.api.nvim_buf_get_offset(bufnr, row - 1)
  if line_start < 0 then
    return nil
  end

  return line_start + col
end

local function goto_byte_offset(bufnr, byte_offset)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count == 0 then
    return
  end

  local lo, hi = 0, line_count - 1
  local line = 0

  while lo <= hi do
    local mid = math.floor((lo + hi) / 2)
    local off_mid = vim.api.nvim_buf_get_offset(bufnr, mid)
    local off_next

    if mid + 1 < line_count then
      off_next = vim.api.nvim_buf_get_offset(bufnr, mid + 1)
    else
      off_next = math.huge
    end

    if byte_offset < off_mid then
      hi = mid - 1
    elseif byte_offset >= off_next then
      lo = mid + 1
    else
      line = mid
      break
    end
  end

  local line_start = vim.api.nvim_buf_get_offset(bufnr, line)
  if line_start < 0 then
    return
  end

  local col = byte_offset - line_start
  if col < 0 then
    col = 0
  end

  vim.api.nvim_win_set_cursor(0, { line + 1, col })
end

-- Called when cursor moves in a watched buffer
function M.on_cursor_moved(bufnr)
  if not M._connected then
    return
  end

  -- Don't trigger on a cursor move caused by the server
  if M._skip_next then
    M._skip_next = false
    return
  end

  local win = vim.api.nvim_get_current_win()
  local pos = vim.api.nvim_win_get_cursor(win)
  local row, col = pos[1], pos[2]
  local path = vim.api.nvim_buf_get_name(bufnr)
  local offset = get_cursor_byte_offset(bufnr)
  local lines =  vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local text = table.concat(lines, "\n")

  send_json({
    UpdateSelection = {
      file = path,
      text = text,
      pos = offset,
    }
  })
end

-- Handle a single JSON line from the server
function M.handle_message(line)
  -- For debugging
  -- vim.schedule(function()
  --   vim.notify("[verses-map] " .. line, vim.log.levels.ERROR)
  -- end)

  local ok, msg = pcall(vim.json.decode, line)
  if not ok or type(msg) ~= "table" then
    return
  end

  local msg = msg.SetCursor;
  local pos = msg.pos;
  local path = msg.file;

  vim.schedule(function()
    -- Prevent loop
    M._skip_next = true
    local bufnr = vim.fn.bufnr(path)
    goto_byte_offset(bufnr, pos)
  end)
end

function M.attach_to_buffer(bufnr)
  ensure_connection()

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      M.on_cursor_moved(bufnr)
    end,
  })
end

function setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "verses",
    callback = function(args)
      M.attach_to_buffer(args.buf)
    end,
  })
end
pcall(setup)

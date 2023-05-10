-- Adapted from <https://stackoverflow.com/a/75240496>

local buf = -1

local function open_buffer()
    local buffer_visible = vim.api.nvim_call_function("bufwinnr", { buf }) ~= -1

    if buf == -1 or not buffer_visible then
        -- name buffer to "verses-output"
        vim.api.nvim_command("botright vsplit verses-output")
        buf = vim.api.nvim_get_current_buf()

        -- map "q" to close this buffer
        vim.keymap.set('n', 'q', "<cmd>:q<cr>", { silent = true, buffer = buf })
    end

    -- temporarily disable readonly to write to buffer
    vim.api.nvim_buf_set_option(buf, "readonly", false)

    -- clear the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, {})
end

local function display(_, output, name)
    -- check if results empty
    if output[1] == '' then
        return
    end

    open_buffer()

    -- write to the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

    -- make it readonly
    -- and not modified, so it doesn't interrupt quitting
    vim.api.nvim_buf_set_option(buf, "readonly", true)
    vim.api.nvim_buf_set_option(buf, "modified", false)
    vim.api.nvim_buf_set_option(buf, "filetype", "json")

    -- Get the window the buffer is in and set the cursor position to the bottom.
    local buffer_window = vim.api.nvim_call_function("bufwinid", { buf })
    local buffer_line_count = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(buffer_window, { buffer_line_count, 0 })
end

local function execute(command)
    local type = vim.bo.filetype
    if type ~= 'script' then
        vim.notify("File is not a script!", vim.log.levels.ERROR)
        return
    end

    local job = vim.fn.jobstart(
        command,
        {
            stdout_buffered = true,
            stderr_buffered = true,
            on_stdout = display,
            on_stderr = display,
        }
    )

end

local function parse()
    local path = vim.api.nvim_buf_get_name(0)
    execute({'verses', 'parse', path})
end

local function validate()
    local path = vim.api.nvim_buf_get_name(0)
    execute({'verses', 'validate', path, "/home/ftseng/.config/hundun/sequences/config.yml"})
end

vim.api.nvim_create_autocmd('FileType', {
	desc = 'Bind keymaps for verses scripts',
	pattern = 'script',
	callback = function(opts)
        vim.keymap.set('n', '<leader>c', parse, { silent = true, buffer = opts['buffer'] })
        vim.keymap.set('n', '<leader>v', validate, { silent = true, buffer = opts['buffer'] })
	end,
})

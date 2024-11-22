-- Create an autocmd group for markdown-specific settings
vim.api.nvim_create_augroup("MarkdownSettings", { clear = true })

-- Apply settings for markdown filetype
vim.api.nvim_create_autocmd("FileType", {
    group = "MarkdownSettings",
    pattern = "markdown",
    callback = function()
        -- Disable line numbers
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.fillchars = "eob: " -- Removes ~ lines at the end of buffer
    end,
})

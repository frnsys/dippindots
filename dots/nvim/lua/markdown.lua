vim.api.nvim_create_augroup("MarkdownSettings", { clear = true })
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

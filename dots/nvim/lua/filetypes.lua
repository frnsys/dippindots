vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "markdown", "verses" },
  callback = function()
    vim.opt_local.softtabstop = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "fr", "en_us" }
    vim.opt_local.complete:append("kspell")
    require('markdown')
  end,
})

require("oil").setup({
    keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["g."] = "actions.toggle_hidden",
    },
    use_default_keymaps = false,
})

vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })

vim.api.nvim_create_autocmd('FileType', {
	desc = 'Bind keymaps for oil',
	pattern = 'oil',
	callback = function(opts)
        vim.keymap.set('n', 'q', require("oil").close, { silent = true, buffer = opts['buffer'] })
	end,
})

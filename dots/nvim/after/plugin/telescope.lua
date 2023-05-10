local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
				-- exit on first esc
                ["<esc>"] = actions.close,
            },
        },
    },
})

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<C-l>', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set({'n', 'i'}, '<C-s>', function()
  require('telescope.builtin').find_files({
    find_command = { "fd", "-t=f" },
  })
end, { desc = 'Search filepaths' })

vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = 'Search Files' })
vim.keymap.set('n', '<C-c>', require('telescope.builtin').live_grep, { desc = 'Search by grep' })
vim.keymap.set('n', '<C-b>', require('telescope.builtin').buffers, { desc = '[ ] Find existing [B]uffers' })
vim.keymap.set('n', '<leader>w', require('telescope.builtin').grep_string, { desc = 'Search current [W]ord' })
vim.keymap.set('n', '<leader>d', require('telescope.builtin').diagnostics, { desc = 'Search [D]iagnostics' })
vim.keymap.set('n', '<leader>s', require('telescope.builtin').lsp_workspace_symbols, { desc = 'Search [S]ymbols' })

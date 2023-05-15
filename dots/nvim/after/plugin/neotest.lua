require('neotest').setup({
    icons = {
        passed = "✓",
        failed = "𐄂",
        running = "~",
        skipped = "-",
        unknown = "?",
    },
    adapters = {
        -- Requires cargo-nexttest
        require("neotest-rust") {
            args = { "--no-capture" },
            dap_adapter = "codelldb",
        },
        require("neotest-python")({
            runner = "pytest",
            args = {"--log-level", "DEBUG"},
            python = vim.fn.expand("$HOME/.pyenv/shims/python"),
            is_test_file = function(file_path)
                return string.find(file_path, "test")
            end,
        })
    },
    quickfix = {
        enabled = false,
    },
    output = {
        enabled = false,
    },
})

-- Keybindings
-- See `:h neotest.run.run()`
local neotest = require("neotest")
vim.keymap.set('n', '<leader>tn', neotest.run.run, { desc = 'Run the nearest test' })
vim.keymap.set('n', '<leader>td', function() neotest.run.run({strategy = "dap"}) end, { desc = 'Run and debug nearest test' })
vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand("%")) end, { desc = 'Run all tests in file' })
vim.keymap.set('n', '<leader>ta', function() neotest.run.run(vim.fn.getcwd()) end, { desc = 'Run all tests in working dir' })
vim.keymap.set('n', '<leader>tl', neotest.run.run_last, { desc = 'Run the last run test' })
vim.keymap.set('n', '<leader>ts', neotest.summary.toggle, { desc = 'Toggle the test summary window' })
vim.keymap.set('n', '<leader>to', neotest.output_panel.toggle, { desc = 'Toggle the test output panel' })

vim.api.nvim_create_autocmd('FileType', {
	desc = 'Close neotest output panel on q',
	pattern = 'neotest-output-panel',
	callback = function(opts)
        vim.keymap.set('n', 'q', ':q<cr>', { silent = true, buffer = opts['buffer'] })
        vim.cmd("$") -- Jump to end of buffer on initial focus
	end,
})

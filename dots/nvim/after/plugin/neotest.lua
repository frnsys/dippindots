local neotest = require('neotest')

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
    consumers = {
        custom = function(client)
            -- Custom hook to open the output panel
            -- after test results that fail,
            -- and auto-focus the panel and jump to its bottom
            client.listeners.results = function(_, results)
                local any_failed = false
                for _, result in pairs(results) do
                    if result.status == "failed" then
                        any_failed = true
                        break
                    end
                end

                if any_failed then
                    local win = vim.fn.bufwinid("Neotest Output Panel")
                    if win > -1 then
                        vim.api.nvim_set_current_win(win)
                        vim.cmd("$") -- Jump to end
                    else
                        neotest.output_panel.open()
                    end
                end
            end
        end
    }
})

function run_all_tests()
    neotest.run.run(vim.fn.getcwd())
    neotest.summary.open()
end

function run_file_tests()
    neotest.run.run(vim.fn.expand("%"))
    neotest.summary.open()
end

-- Keybindings
-- See `:h neotest.run.run()`
vim.keymap.set('n', '<leader>tn', neotest.run.run, { desc = 'Run the nearest test' })
vim.keymap.set('n', '<leader>td', function() neotest.run.run({strategy = "dap"}) end, { desc = 'Run and debug nearest test' })
vim.keymap.set('n', '<leader>tf', run_file_tests, { desc = 'Run all tests in file' })
vim.keymap.set('n', '<leader>ta', run_all_tests, { desc = 'Run all tests in working dir' })
vim.keymap.set('n', '<leader>tl', neotest.run.run_last, { desc = 'Run the last run test' })
vim.keymap.set('n', '<leader>ts', neotest.summary.toggle, { desc = 'Toggle the test summary window' })
vim.keymap.set('n', '<leader>tt', neotest.output_panel.toggle, { desc = 'Toggle the test output panel' })

vim.api.nvim_create_autocmd('FileType', {
	desc = 'Close neotest output panel on q',
	pattern = 'neotest-output-panel',
	callback = function(opts)
        vim.keymap.set('n', 'q', ':q<cr>', { silent = true, buffer = opts['buffer'] })
        vim.cmd("$") -- Jump to end of buffer on initial focus
	end,
})

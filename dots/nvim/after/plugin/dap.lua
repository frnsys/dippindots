--- With Mason install:
--- - codelldb
--- - debugpy

local dap = require('dap')
local mason_registry = require("mason-registry")

local codelldb = mason_registry.get_package("codelldb")
local codelldb_path = codelldb:get_install_path() .. "/extension/adapter/codelldb"
dap.adapters.codelldb = {
    type = 'server',
    port = '13000',
    executable = {
      command = codelldb_path,
      args = { '--port', '13000' },
    },
}

local debugpy = mason_registry.get_package("debugpy")
local debugpy_path = debugpy:get_install_path() .. "/debugpy-adapter"
dap.adapters.python = {
    type = 'executable',
    command = debugpy_path
}

local get_program = function()
    return vim.fn.input('program: ', vim.loop.cwd() .. '/' .. vim.fn.expand('%f'), 'file')
end
local get_args = function()
    return vim.split(vim.fn.input('args: ', '', 'file'), ' ')
end

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        cwd = '${workspaceFolder}',
        pythonPath = "/home/ftseng/.pyenv/shims/python",
        program = get_program,
        args = get_args
    }
}

dap.configurations.rust = {
    {
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    }
}

--- Auto-open/close DAP UI
local dapui = require('dapui')
dapui.setup({
    controls = {
        enabled = false,
    }
})
dap.listeners.after.event_initialized["dap_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dap_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dap_config"] = function()
    dapui.close()
end

--- Keybindings
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle DAP breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'DAP continue' })
vim.keymap.set('n', '<leader>dn', dap.continue, { desc = 'DAP step over' })

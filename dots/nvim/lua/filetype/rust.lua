--- Run a cargo build command and extract
--- the executable path, if any.
function build(cmd)
    local cargo_output = vim.fn.system(cmd .. "--message-format=json 2> /dev/null | jq -r 'select(.executable !=null) | [.executable]'")
    local paths = vim.fn.json_decode(cargo_output)
    return paths[1]
end

function debug_main()
    vim.cmd("!cargo build")
    local path = build("cargo build")
    vim.cmd('Termdebug ' .. path)
end

function debug_test()
    local path = build("cargo test --no-run")
    vim.cmd('Termdebug ' .. path)
end

vim.api.nvim_create_user_command('Rdbg', debug_main, {})
vim.api.nvim_create_user_command('Rdbgtest', debug_test, {})

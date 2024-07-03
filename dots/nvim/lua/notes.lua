--- Use Zettle Notes on Android and Git(Hub) to sync select notes.
--- This will basically pull from GitHub when any of the selected notes are opened,
--- and then push to GitHub when exiting with any modifications.

--- NOTE: any notes added to `note_paths` needs to
--- also be whitelisted in the `.gitignore`.
local note_dir = "/home/francis/notes"
local note_paths = {
  "todo.md",
  "fugue.md"
}

--- Pull git changes, if any, on file open.
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = note_dir .. "/*",
  callback = function(args)
    -- Avoid re-triggering after reloading.
    if vim.b.reloading then
        return
    end

    if not vim.tbl_contains(note_paths, args.file) then
      return
    end

    local function on_output(job_id, data, event)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            print(line)
          end
        end
      end
    end
    vim.fn.jobstart({"git", "pull"}, {
      cwd = note_dir,
      on_stdout = on_output,
      on_stderr = on_output,
      on_exit = function(_, code, _)
        if code ~= 0 then
          print("git pull failed with code", code)
        else
          vim.fn.system('notify-send "Notes synced" -t 1000')
          vim.b.reloading = true
          vim.cmd('edit')
          vim.b.reloading = false
        end
      end,
    })
  end
})

local modified_files = {}

--- Mark file as modified when saved.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = note_dir .. "/*",
  callback = function(args)
    if vim.tbl_contains(note_paths, args.file) and not vim.tbl_contains(modified_files, args.file) then
      table.insert(modified_files, args.file)
    end
  end
})

--- If the file was modified, commit and push.
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if vim.tbl_isempty(modified_files) then
      return
    end

    local cmd = 'cd ' .. note_dir .. ' && git add . && git commit -m "Updated" && git push'
    local output = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error

    if exit_code ~= 0 then
        print("Command failed with exit code", exit_code)
        print("Output: " .. output)
    else
      vim.fn.system('notify-send "Notes pushed" -t 1000')
    end
  end
})

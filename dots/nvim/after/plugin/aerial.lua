require('aerial').setup({
  layout = {
    default_direction = "prefer_left",
  }
})

--- `q is already mapped to close the panel
vim.keymap.set({'n'}, '<leader>j', require('aerial').toggle,
  { desc = 'Open symbol navigation' })

--- Use <esc> to jump back to the previous window
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'aerial',
	callback = function(opts)
    vim.keymap.set('n', '<esc>', function()
      local prev_window = vim.fn.winnr('#')
      local win_id = vim.fn.win_getid(prev_window)
      vim.api.nvim_set_current_win(win_id)
    end, {
      silent = true,
      buffer = opts['buffer']
    })
  end
});

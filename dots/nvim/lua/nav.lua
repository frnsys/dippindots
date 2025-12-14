vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/kwkarlwang/bufjump.nvim",
  "https://github.com/yorickpeterse/nvim-window",
})

require("oil").setup({
  keymaps = {
    ["<CR>"] = "actions.select",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-s>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = function()
      require("oil.actions").preview.callback()
      vim.defer_fn(function()
        vim.cmd("vertical resize 24")
      end, 2)
    end,
    ["-"] = "actions.parent",
    ["_"] = "actions.parent",
    ["g."] = "actions.toggle_hidden",
    ["q"] = "actions.close",
  },
  default_file_explorer = false,
  use_default_keymaps = false,
  float = {
    max_width = 64,
  },
})
vim.keymap.set("n", "_", require("oil").open_float)

require("bufjump").setup({})
local opts = { silent=true, noremap=true }
vim.keymap.set("n", "b", require('bufjump').backward, opts)
vim.keymap.set("n", "B", require('bufjump').forward, opts)

require("nvim-window").setup({
  -- The characters available for hinting windows.
  chars = {
    't', 'r', 's',
  },
  normal_hl = 'WindowTarget',
  border = 'none',
})
vim.keymap.set("n", ",t", function()
  -- Exclude floating windows and scratch buffers
  local function is_real_win(win)
    -- Floating window
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg and cfg.relative ~= "" then return false end

    -- Exclude scratch buffers
    local buf = vim.api.nvim_win_get_buf(win)
    local bt  = vim.bo[buf].buftype
    return bt ~= "nofile"
  end

  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_real_win(w) then table.insert(wins, w) end
  end

  if #wins == 1 then
    return

    -- If there are only two windows,
    -- jump to the other one.
  elseif #wins == 2 then
    local cur = vim.api.nvim_get_current_win()
    local target = (wins[1] == cur) and wins[2] or wins[1]
    vim.api.nvim_set_current_win(target)

    -- Otherwise use the picker.
  else
    require('nvim-window').pick()
  end
end)

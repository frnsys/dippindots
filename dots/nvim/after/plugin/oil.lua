require("oil").setup({
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-s>"] = "actions.select_vsplit",
    ["<C-h>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["q"] = "actions.close",
    ["<C-l>"] = "actions.refresh",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["g."] = "actions.toggle_hidden",
  },
  use_default_keymaps = false,
  view_options = {
    -- Check against ignore patterns to
    -- determine what files to hide
    is_hidden_file = function(name, bufnr)
      if vim.startswith(name, ".") then
        return true
      end
      for _, pat in ipairs(edit_file_ignore_patterns) do
        if name:match(pat) then
          return true
        end
      end
      return false
    end,
  },
})

vim.keymap.set("n", "-", require("oil").open,
  { desc = "Open parent directory" })

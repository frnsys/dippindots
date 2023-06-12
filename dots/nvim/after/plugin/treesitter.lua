require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'c', 'cpp', 'python', 'rust', 'tsx',
    'typescript', 'c_sharp', 'css', 'toml',
    'markdown', 'markdown_inline', 'bash',
    'html', 'javascript', 'json', 'yaml', 'comment' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = true,

  highlight = { enable = true },
  indent = { enable = false },
  textobjects = {
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['aF'] = '@function.outer',
        ['iF'] = '@function.inner',
        ['ar'] = '@assignment.rhs',
        ['al'] = '@assignment.lhs',
        ['in'] = '@number.inner',
        ['ik'] = '@block.inner',
        ['ak'] = '@block.outer',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']f'] = '@function.outer',
        [']a'] = '@parameter.inner',
        [']r'] = '@assignment.rhs',
        [']e'] = '@assignment.lhs',
        [']]'] = { query = "@scope", query_group = "locals" },
      },
      goto_next_end = {
        ['}f'] = '@function.outer',
        [']['] = '@block.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[a'] = '@parameter.inner',
        ['[r'] = '@assignment.rhs',
        ['[e'] = '@assignment.lhs',
        ['[['] = { query = "@scope", query_group = "locals" },
      },
      goto_previous_end = {
        ['{f'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

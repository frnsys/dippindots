local variable_query = {
    query = "@variable",
    query_group = "highlights"
}

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
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['aF'] = '@function.outer',
        ['iF'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ["iv"] = variable_query,
        ['iR'] = '@assignment.rhs',
        ['iL'] = '@assignment.lhs',
        ['in'] = '@number.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']f'] = '@function.outer',
        [']]'] = '@class.outer',
        ["]v"] = variable_query,
      },
      goto_next_end = {
        [']F'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[['] = '@class.outer',
        ["[v"] = variable_query,
      },
      goto_previous_end = {
        ['[F'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

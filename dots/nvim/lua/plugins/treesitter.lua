return {
  { 'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/playground',
    },
    main = 'nvim-treesitter.configs',
    opts = {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        'c', 'cpp', 'python', 'rust', 'tsx',
        'typescript', 'c_sharp', 'css', 'toml',
        'markdown', 'markdown_inline', 'bash',
        'html', 'javascript', 'json', 'yaml', 'comment' },

      -- Autoinstall languages that are not installed.
      auto_install = true,

      highlight = { enable = true },
      indent = { enable = false },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "<tab>",
          node_decremental = "<s-tab>",
        },
      },
      textobjects = {
        swap = {
          enable = true,
          swap_next = {
            ["<leader>]"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>["] = "@parameter.inner",
          },
        },
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
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
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[a'] = '@parameter.inner',
          },
        },
      },
    }
  }
}

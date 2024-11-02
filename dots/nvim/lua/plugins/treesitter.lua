return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',

      -- Use the `Inspect` and `InspectTree` commands instead.
      -- 'nvim-treesitter/playground',
    },
    main = 'nvim-treesitter.configs',
    opts = {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        'c', 'cpp', 'python', 'rust', 'tsx',
        'typescript', 'c_sharp', 'css', 'scss', 'toml',
        'markdown', 'markdown_inline', 'bash', 'lua',
        'html', 'javascript', 'json', 'yaml', 'comment' },

      -- Autoinstall languages that are not installed.
      auto_install = true,

      highlight = { enable = true },
      indent = { enable = false },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<space>",
          node_incremental = "<space>",
          node_decremental = "<c-space>",
          scope_incremental = "<tab>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['in'] = '@number.inner',
            ['im'] = '@block.inner',
            ['am'] = '@block.outer',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ['.f'] = '@function.outer',
            ['.a'] = '@parameter.inner',
            ['.m'] = '@block.inner',
            ['.n'] = '@number.inner',
          },
          goto_previous_start = {
            [',f'] = '@function.outer',
            [',a'] = '@parameter.inner',
            [',m'] = '@block.inner',
            [',n'] = '@number.inner',
          },
        },
      },
    }
  }
}

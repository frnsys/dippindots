vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

-- NOTE: Markdown parsers are built-in.
require("nvim-treesitter").install({
  'c', 'cpp', 'python', 'rust', 'tsx', 'typescript',
  'c_sharp', 'css', 'scss', 'toml', 'lua', 'just', 'make',
  'bash', 'gitcommit', 'html', 'javascript', 'json', 'yaml', 'comment',
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then return end

    if vim.treesitter.query.get(lang, "highlights") then
      vim.treesitter.start(args.buf)
    end
  end
})

-- Use my fork of the markdown parser for now,
-- which fixes emphasis with `_foobar1_`.
vim.api.nvim_create_autocmd('User', {
  pattern = 'TSUpdate',
  callback = function()
    require('nvim-treesitter.parsers').markdown_inline = {
      install_info = {
        url = 'https://github.com/frnsys/tree-sitter-markdown',
        branch = 'fix-underscore_digit_emphasis',
        location = 'tree-sitter-markdown-inline',
      },
    }
  end
})

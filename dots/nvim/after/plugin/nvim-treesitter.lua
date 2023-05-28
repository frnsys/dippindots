require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'c', 'cpp', 'python', 'rust', 'tsx',
    'typescript', 'c_sharp', 'css', 'toml',
    'markdown', 'markdown_inline', 'bash',
    'html', 'javascript', 'json', 'yaml', 'comment' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = false },
}

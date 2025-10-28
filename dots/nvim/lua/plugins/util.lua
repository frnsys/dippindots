return {
  --- Nicer markdown headings.
  {
    'lukas-reineke/headlines.nvim',
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "markdown" },
    opts = {
      markdown = {
        bullets = { "", "", "", "" },
        headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4" },
      },
    }
  },

  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },

  --- Use `:NoNeckPain`
  {
    "shortcuts/no-neck-pain.nvim",
    config = function()
      require("no-neck-pain").setup({
        buffers = {
          wo = {
            fillchars = "eob: ",
          },
        },
      })

      -- Auto-load for markdown files
      vim.api.nvim_create_autocmd({"BufEnter"}, {
        pattern = "*",
        callback = function()
          vim.schedule(function()
            local filetype = vim.api.nvim_buf_get_option(0, "filetype")
            local enabled =  _G.NoNeckPain.state ~= nil and _G.NoNeckPain.state.enabled

            if (filetype == "markdown" and not enabled) or
              (filetype ~= 'markdown' and filetype ~= 'oil' and filetype ~= 'no-neck-pain' and enabled) then
              return vim.cmd("NoNeckPain")
            end
          end)
        end,
      })
    end
  },

  --- LSP status
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        override_vim_notify = true,
      },
    },
  },
  {
    'mikesmithgh/kitty-scrollback.nvim',
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    version = '*', -- latest stable version, may have breaking changes if major version changed
    config = function()
      require('kitty-scrollback').setup({
        {
          status_window = {
            style_simple = true
          },
          paste_window = {
            yank_register_enabled = false,
          },
        }
      })
    end,
  },
}

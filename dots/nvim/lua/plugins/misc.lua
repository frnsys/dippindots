return {
  {
      "robitx/gp.nvim",
      config = function()
          local conf = {
            openai_api_key = { "cat", "~/.openai" },
          }
          require("gp").setup(conf)
      end,
  }
}

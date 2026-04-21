return {
  "max397574/startup.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  config = function()
    local startup = require("startup")
    local startup_headers = require("startup.headers")

    startup.setup({
      parts = { "header", "body" },
      header = {
        type = "text",
        align = "center",
        fold_section = false,
        title = "Header",
        margin = 5,
        content = startup_headers.hydra_header,
        highlight = "@function.builtin",
        default_color = "",
        oldfiles_amount = 0,
      },
      body = {
        type = "mapping",
        align = "center",
        fold_section = false,
        title = "Basic Commands",
        margin = 5,
        content = {
          { " Find File", "FzfLua files", "<leader>ff" },
          { " Find Word", "FzfLua live_grep", "<leader>fg" },
          { " Recent Files", "FzfLua oldfiles", "<leader>of" },
          { " Colorschemes", "FzfLua colorschemes", "<leader>cs" },
          { " New File", "lua require'startup'.new_file()", "<leader>nf" },
        },
        highlight = "@function.builtin",
        default_color = "",
        oldfiles_amount = 0,
      },
    })
  end,
}

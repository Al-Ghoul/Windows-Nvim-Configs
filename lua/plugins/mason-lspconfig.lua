return {
  "mason-org/mason-lspconfig.nvim",
  lazy = false,
  opts = {
    automatic_enable = true,
    ensure_installed = {
      "lua_ls",
      "clangd",
      -- "cmake",
    },
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
  config = function()
    -- https://github.com/neovim/nvim-lspconfig/issues/3705
    local LSPs = {
      { "lua_ls" },
      { "clangd" },
    }

    for _, lsp in pairs(LSPs) do
      local name, config = lsp[1], lsp[2]
      vim.lsp.enable(name)
      vim.lsp.config(name, config or vim.lsp.config[name])
    end
  end,
}

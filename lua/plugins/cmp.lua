return {
  "hrsh7th/nvim-cmp",
  lazy = false,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    {
      "L3MON4D3/LuaSnip",
      dependencies = { "rafamadriz/friendly-snippets" },
    }
  },
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load() -- luasnip/friendly-snippets related

    local cmp = require("cmp")
    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        {
          { name = "buffer" },
          { name = "path" },
        }
      }),
    })
  end,
}

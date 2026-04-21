return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  config = function()
    local neocodeium = require("neocodeium")
    neocodeium.setup()
    vim.keymap.set("i", "<C-]>", neocodeium.clear)
    vim.keymap.set("i", "<M-]>", neocodeium.cycle)
    vim.keymap.set("i", "<M-[>", function() neocodeium.cycle(-1) end)
    vim.keymap.set("i", "<C-k>", neocodeium.accept_word)
    vim.keymap.set("i", "<C-l>", neocodeium.accept_line)
    vim.keymap.set("i", "<Tab>", neocodeium.accept)
  end,
}

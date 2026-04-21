return {
	"EdenEast/nightfox.nvim",
	lazy = false,
  opts = {
    options = {
      transparent = true,
    },
  },
	config = function()
		vim.cmd.colorscheme("nightfox")
	end,
}

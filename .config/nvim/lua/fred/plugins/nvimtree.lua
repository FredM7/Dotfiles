return {
	"nvim-tree/nvim-tree.lua",
--	version = "*",
--	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local nvimtree = require("nvim-tree")

		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		nvimtree.setup({
			view = {
				width = 35,
			},
			git = {
				ignore = false,
			}
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>bb", "<cmd>NvimTreeToggle<CR>")
		keymap.set("n", "<leader>br", "<cmd>NvimTreeRefresh<CR>")
		keymap.set("n", "<leader>bf", "<cmd>NvimTreeFindFileToggle<CR>")
		keymap.set("n", "<leader>bc", "<cmd>NvimTreeCollapse<CR>")
	end
}

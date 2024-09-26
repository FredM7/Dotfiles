return {
	'akinsho/toggleterm.nvim',
	version = "*",
	config = function()
		local toggleterm = require("toggleterm")
		toggleterm.setup()

		local keymap = vim.keymap

		keymap.set("n", "<leader>jj", "<cmd>ToggleTerm size=12<cr>", { desc = "Toggle the terminal" })
	end
}

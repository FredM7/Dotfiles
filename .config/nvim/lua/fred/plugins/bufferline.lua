return {
	"akinsho/bufferline.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	version = "*",
	opts = { -- require(bufferline).setup(opts)
		options = {
			mode = "buffers", --"tabs",
			separator_style = "slant",
		}
	}
}

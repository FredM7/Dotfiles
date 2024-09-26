return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" }, -- only need commenting in a buffer
	config = true, -- runs require('Comment').setup()
}

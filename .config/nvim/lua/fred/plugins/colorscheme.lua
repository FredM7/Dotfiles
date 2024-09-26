return {
	-- 'NLKNguyen/papercolor-theme',
	"bluz71/vim-moonfly-colors",
	name = "moonfly",
	lazy = false,
	priority = 1000,
	config = function()
		-- -- vim.opt.backgound = dark;
		-- vim.cmd([[colorscheme PaperColor]])
		vim.cmd([[colorscheme moonfly]])
	end,
}

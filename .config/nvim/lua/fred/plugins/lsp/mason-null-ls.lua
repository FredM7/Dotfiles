return {
	"jay-babu/mason-null-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"jose-elias-alvarez/null-ls.nvim",
	},
	config = function()
		-- require("your.null-ls.config") -- require your null-ls config here (example below)
		local mason = require("mason")
		mason.setup()

		local null_ls = require('null-ls')
		null_ls.setup()
		
		require("mason-null-ls").setup({
			ensure_installed = {
				"prettier",
				"stylua"
			},
			handlers = {
        function() end, -- disables automatic setup of all null-ls sources
				prettier = function(source_name, methods)
          null_ls.register(null_ls.builtins.formatting.prettier)
        end,
				stylua = function(source_name, methods)
          null_ls.register(null_ls.builtins.formatting.stylua)
        end,
			},
		})
	end,
}

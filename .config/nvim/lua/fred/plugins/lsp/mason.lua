return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim", -- acts as the bridge between mason and nvim-lsp
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_uninstalled = "x",
					package_pending = "→",
				}
			}
		})

		mason_lspconfig.setup({
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"lua_ls",
				"emmet_ls",
				-- "nil_ls", -- Nix language server
				"rust_analyzer"
			},
			automatic_installation = true,
		})
	end
}


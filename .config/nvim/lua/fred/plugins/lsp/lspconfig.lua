return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "bufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp", -- completion source
		{ "antosha417/nvim-lsp-file-operations", config = true }, -- allows rename file through nvimtree
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap

		local opts = {
			noremap = true,
			silent = true,
			--autoformat = true
		}

		local on_attach = function(client, bufnr)
			opts.buffer = bufnr

			-- opts.autoforamt = true

			opts.desc = "Show LSP references"
  		keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
			opts.desc = "Go to declaration"
  		keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			opts.desc = "Show LSP definitions"
  		keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
			opts.desc = "Show LSP implementations"
 		 	keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
			opts.desc = "Show LSP type defitions"
  		keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
			opts.desc = "See available code actions"
  		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- smart rename
			opts.desc = "Smart rename"
  		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts, opts) -- show  diagnostics for line
			opts.desc = "Show buffer diagnostics"
  		keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show diagnostics for cursor
			opts.desc = "Show line diagnostics"
  		keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- jump to previous diagnostic in buffer
			opts.desc = "Go to previous diagnostic"
 			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to next diagnostic in buffer
			opts.desc = "Show documentation for what is under cursor"
  		keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor
			opts.desc = "Restart LSP"
  		keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", opts) -- see outline on right hand side
			keymap.set("n", "<space>f", function()
				vim.lsp.buf.format({ async = true })
			end, opts) -- format the buffer
			-- keymap.set("n", "<leader>fx", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
			-- vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]])
		end

		local capabilities = cmp_nvim_lsp.default_capabilities()
		-- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
		--
		lspconfig["html"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["ts_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["tailwindcss"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["cssls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["emmet_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
		})

		lspconfig["lua_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" }, -- make the language server aware of the 'vim' global
					},
					workspace = {
						library = {
							-- make the language server aware of the runtime files
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					}
				}
			}
		})

    lspconfig["rust_analyzer"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			-- currently this cmd is specfic to my NixOS. "which rust-analyzer" to find yours
			cmd = { "/run/current-system/sw/bin/rust-analyzer" },
		})
	end
}

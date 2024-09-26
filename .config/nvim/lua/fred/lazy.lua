-- vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

-- Bootstrap lazy.nvim so that nvim can install it.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Require and load lazy.nvim.
require("lazy").setup({
	{ import = "fred.plugins" },
	{ import = "fred.plugins.lsp" },
}, {
	install = {
		colorscheme = { "PaperColor" },
	},
	checker = {
		enabled = true, -- keep checking for plugin updates on startup
		notify = false, -- dont notify me when i startup neovim
	},
	change_detection = {
		enabled = true, -- keep checking for live changes
		notify = false, -- dont notify me if i make a change to the config
	}
})
-- {
-- 	-- Theme
-- 	{
-- 		'NLKNguyen/papercolor-theme',
-- 		priority = 1000,
-- 		config = function()
-- 			-- vim.opt.backgound = dark;
-- 			vim.cmd([[colorscheme PaperColor]])
-- 		end,
-- 	},
-- },
--{
--  checker = {
--    enabled = true,
--		notify = false,
--	},
--	change_detection = {
--		notify = false,
--	},
--}

-- -- Require and load lazy.nvim.
-- require("lazy").setup({
-- 	-- Theme
-- 	{
--     'NLKNguyen/papercolor-theme',
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function()
-- 			-- vim.opt.backgound = dark;
--       -- vim.cmd('colorscheme PaperColor');
--     end,
-- 	},
-- 	-- Github CoPilot
--   {
--     'github/copilot.vim',
--     lazy = false,
-- 		priority = 999,
--   },
-- 	-- Syntax highlighting
-- 	{
-- 		"nvim-treesitter/nvim-treesitter",
-- 		--build = ":TSUpdate",
-- 		lazy = false,
-- 	},
-- 	-- Undo history
-- 	{
-- 		"mbbill/undotree",
-- 	},
-- 	-- Git integration
-- 	{
-- 		"tpope/vim-fugitive",
-- 	},
-- 	-- File tree
-- 	{
--     "nvim-tree/nvim-tree.lua",
--     version = "*",
--     lazy = false,
--     dependencies = {
--       "nvim-tree/nvim-web-devicons",
--     },
--     config = function()
--       require("nvim-tree").setup {}
--     end,
--   },
-- 	-- Commenting
--   {
--     'numToStr/Comment.nvim',
--     opts = {
--         -- add any options here
--     },
--     lazy = false,
--   },
-- 	-- Status bar
--   {
--     'nvim-lualine/lualine.nvim',
--     dependencies = {
--       "nvim-tree/nvim-web-devicons",
--     },
--     lazy = false,
--   },
-- 	-- Auto completion
-- 	{
-- 		'VonHeikemen/lsp-zero.nvim',
-- 		-- branch = 'v2.x',
-- 		branch = 'dev-v3',
-- 		-- dependencies = {
-- 		-- 	-- LSP Support
-- 		-- 	{'neovim/nvim-lspconfig'},             -- Required
-- 		-- 	{'williamboman/mason.nvim'},           -- Optional
-- 		-- 	{'williamboman/mason-lspconfig.nvim'}, -- Optional
-- 		--
-- 		-- 	-- Autocompletion
-- 		-- 	{'hrsh7th/nvim-cmp'},     -- Required
-- 		-- 	{'hrsh7th/cmp-nvim-lsp'}, -- Required
-- 		-- 	{'L3MON4D3/LuaSnip'},     -- Required
-- 		-- }
-- 	},
-- 	{'williamboman/mason.nvim'},
--   {'williamboman/mason-lspconfig.nvim'},
--   -- LSP Support
--   {
--     'neovim/nvim-lspconfig',
--     dependencies = {
--       {'hrsh7th/cmp-nvim-lsp'},
--     },
--   },
--   -- Autocompletion
--   {
--     'hrsh7th/nvim-cmp',
--     dependencies = {
--       {'L3MON4D3/LuaSnip'},
--     }
--   },
--   {
-- 		'akinsho/toggleterm.nvim',
-- 		version = "*",
-- 		config = true,
-- 	},
-- 	-- {
-- 	-- 	'glepnir/dashboard-nvim',
-- 	-- 	event = 'VimEnter',
-- 	-- 	config = function()
-- 	-- 		require('dashboard').setup {
-- 	-- 			-- config
-- 	-- 		}
-- 	-- 	end,
-- 	-- 	dependencies = { 
-- 	-- 		{ 'nvim-tree/nvim-web-devicons' }
-- 	-- 	}
-- 	-- },
-- 	-- Github CoPilot
-- 	--{
-- 	--	'github/copilot.vim',
-- 	--	-- lazy = false,
-- 	--},
-- 	-- {
-- 	-- 	'zbirenbaum/copilot.lua',
-- 	-- 	config = function ()
-- 	-- 		--
-- 	-- 		-- require('copilot').setup({
-- 	-- 			-- 	suggestion = { enabled = false },
-- 	-- 			-- 	panel = { enabled = false },
-- 	-- 			-- })
-- 	-- 	end,
-- 	-- },
-- 	-- {
-- 	-- 	"zbirenbaum/copilot-cmp",
-- 	-- 	config = function ()
-- 	-- 		-- require("copilot_cmp").setup()
-- 	-- 	end,
-- 	-- 	-- dependencies = {
-- 	-- 		--   "zbirenbaum/copilot.lua",
-- 	-- 		-- },	
-- 	-- },
-- });


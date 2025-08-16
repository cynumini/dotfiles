-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Theme & transparency
vim.cmd.colorscheme("retrobox")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.o.tabstop = 2    -- how many spaces in tab
vim.o.shiftwidth = 2 -- how many spaces for indentation
vim.o.smartindent = true
vim.o.list = true

-- Search settings
vim.o.ignorecase = true
vim.o.smartcase = true

-- File handling
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.undofile = true

-- Behavior settings
vim.o.clipboard = "unnamedplus"

-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	callback = function()
		local dir = vim.fn.expand('<afile>:p:h')
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, 'p')
		end
	end,
})

require("lazy").setup({
	spec = {
		'https://github.com/neovim/nvim-lspconfig',
		{
			'stevearc/oil.nvim',
			---@module 'oil'
			---@type oil.SetupOpts
			opts = { view_options = { show_hidden = true } },
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			lazy = false,
		},
		{
			'nvim-telescope/telescope.nvim',
			tag = '0.1.8',
			dependencies = { 'nvim-lua/plenary.nvim' }
		},
		{
			'saghen/blink.cmp',
			dependencies = { 'rafamadriz/friendly-snippets' },
			version = '1.*',
			---@module 'blink.cmp'
			---@type blink.cmp.Config
			opts = {
				keymap = { preset = 'default' },
				appearance = { nerd_font_variant = 'mono' },
				completion = { documentation = { auto_show = false } },
				sources = {
					default = { 'lsp', 'path', 'snippets', 'buffer' },
					providers = { lsp = { fallbacks = {} } }
				},
				fuzzy = { implementation = "prefer_rust_with_warning" }
			},
			opts_extend = { "sources.default" }
		}
	},
	install = { colorscheme = { "retrobox" } },
	checker = { enabled = true },
})

require('lua_ls')
vim.lsp.enable('basedpyright')
vim.lsp.enable("lua_ls")
vim.lsp.enable('ltex_plus')
vim.lsp.enable('zls')
vim.lsp.enable('clangd')
vim.lsp.enable('qmlls')
vim.lsp.enable('ruff')

vim.keymap.set('n', '<Leader>nd', require("tasks"))

vim.api.nvim_create_autocmd('LspAttach', {
	group = augroup,
	callback = function(args)
		vim.keymap.set('n', '<Leader>lf', function() vim.lsp.buf.format() end)
	end
})

vim.keymap.set("n", "<leader>o", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local builtin = require('telescope.builtin');

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

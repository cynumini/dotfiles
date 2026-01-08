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
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.o.tabstop = 4 -- how many spaces in tab
-- vim.o.shiftwidth = 4 -- how many spaces for indentation
-- vim.o.smartindent = true
vim.o.list = true
-- vim.o.expandtab = true

-- Search settings
-- vim.o.ignorecase = true
-- vim.o.smartcase = true

-- File handling
-- vim.o.writebackup = false
-- vim.o.swapfile = false
-- vim.o.undofile = true

-- End of half
-- vim.o.colorcolumn = "116"

-- Behavior settings
vim.o.clipboard = "unnamedplus"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		'neovim/nvim-lspconfig',
		{
			'nvim-telescope/telescope.nvim',
			tag = 'v0.2.1',
			dependencies = {
				'nvim-lua/plenary.nvim',
				-- optional but recommended
				{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
			}
		},
		{
			'saghen/blink.cmp',
			dependencies = { 'rafamadriz/friendly-snippets' },
			version = '1.*',
			---@module 'blink.cmp'
			---@type blink.cmp.Config
			opts = {
				keymap = { preset = 'default' },
				appearance = { nerd_font_variant = 'normal' },
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
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "retrobox" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- Support for config
vim.lsp.config('lua_ls', {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
				return
			end
		end
		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = {
				version = 'LuaJIT',
				path = {
					'lua/?.lua',
					'lua/?/init.lua',
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME
				}
			}
		})
	end,
	settings = {
		Lua = {}
	}
})

require('lua_ls')
vim.lsp.enable('basedpyright')
vim.lsp.enable("lua_ls")
vim.lsp.enable('ltex_plus', {
	settings = {
		ltex = {
			language = "ja-JP",
		}
	}
})
vim.lsp.enable('zls')
vim.lsp.enable('clangd')
vim.lsp.enable('qmlls')
vim.lsp.enable('ruff')
vim.lsp.enable('asm_lsp')

vim.keymap.set('n', '<Leader>nd', require("tasks"))

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method('textDocument/formatting') then
			vim.keymap.set('n', '<leader>lf',
				function() vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 }) end)
		end
	end
})

vim.keymap.set("n", "<leader>o", "<CMD>Ex<CR>", { desc = "Open parent directory" })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = 'Telescope lists items in the quickfix list' })

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
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
vim.opt.path:append('**')

-- Lazy
require("config.lazy")

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

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>nd', require("tasks"))
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set("n", "<leader>o", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		vim.keymap.set('n', '<Leader>lf', function() vim.lsp.buf.format() end)
	end
})

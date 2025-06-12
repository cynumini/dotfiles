require("config.lazy")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.list = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true

-- oil.nvim
vim.keymap.set('n', '<leader>o', "<CMD>Oil<CR>", { desc = 'Oil' })

-- telescope.nvim
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- lsp only keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    vim.keymap.set('n', 'grr', builtin.lsp_references, { desc = 'Telescope lsp references' })
    vim.keymap.set('n', 'gqq', vim.lsp.buf.format, { desc = 'lsp format' })
  end
})

-- auto update
vim.api.nvim_create_autocmd("VimEnter", { callback = function() require("lazy").update({ show = false }) end })

-- notes.nvim
vim.keymap.set("n", "<leader>no", ":NotesSearch<CR>")

-- theme
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

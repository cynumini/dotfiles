-- theme
vim.api.nvim_set_hl(0, "Normal", { bg = "none" }) -- disable background

-- basic
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.g.mapleader = " "

-- lsp
vim.pack.add { { src = 'https://github.com/neovim/nvim-lspconfig' } }
vim.lsp.enable('serve_d')
vim.lsp.enable('basedpyright')
vim.lsp.enable('ruff')
require("lua_ls") -- curstom lua_ls config
vim.lsp.enable('lua_ls')

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- blink
vim.pack.add({ 'https://github.com/saghen/blink.lib', 'https://github.com/saghen/blink.cmp' })
local cmp = require('blink.cmp')
cmp.build():pwait()
cmp.setup({
    signature = {
        enabled = true,
    },
})

-- fzf
vim.pack.add({ { src = "https://github.com/ibhagwan/fzf-lua" } })
require("fzf-lua")
vim.keymap.set("n", "<leader>g", FzfLua.git_files)
vim.keymap.set("n", "<leader>b", FzfLua.buffers)
vim.keymap.set("n", "<leader>d", FzfLua.diagnostics_document)

-- D
vim.api.nvim_create_autocmd("FileType", {
    pattern = "d",
    callback = function()
        vim.opt_local.makeprg = "dub"
        vim.opt_local.errorformat = {
            [[%f(%l\,%c): Error: %m]],
            [[%f(%l\,%c): Warning: %m]],
            [[%-G%.%#]],
        }
    end,
})

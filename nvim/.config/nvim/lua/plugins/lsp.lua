return {
  'neovim/nvim-lspconfig',
  config = function()
    vim.lsp.enable('zls')
    vim.lsp.enable('lua_ls')
    vim.lsp.enable('clangd')
    vim.lsp.enable('glsl_analyzer')
    vim.lsp.enable('basedpyright')
    vim.lsp.enable('ruff')
    return {}
  end
}

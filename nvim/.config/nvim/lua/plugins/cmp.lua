return {
	'saghen/blink.cmp',
	dependencies = { 'rafamadriz/friendly-snippets' },

	version = '1.*',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = 'default' },

		appearance = {
			nerd_font_variant = 'normal'
		},

		completion = { documentation = { auto_show = false } },

		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer' },
			providers = {
				-- defaults to `{ 'buffer' }`
				lsp = { fallbacks = {} }
			}
		},

		fuzzy = { implementation = "prefer_rust_with_warning" }
	},
	opts_extend = { "sources.default" }
}

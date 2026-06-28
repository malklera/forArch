local wk = require("which-key")
wk.setup({})
wk.add({
	{ "<leader>c", group = "code" },
	{ "<leader>t", group = "toggle" },
	{ "<leader>p", group = "pack" },
	{ "<leader>f", group = "find" },
	{ "<leader>fg", group = "grep" },
	{ "<leader>fm", group = "files (home)" },
	{ "g", group = "goto" },
	{ "gr", group = "lsp" },
	{
		"<leader>b",
		group = "buffer",
		expand = function()
			return require("which-key.extras").expand.buf()
		end,
	},
	{
		"<leader>w",
		group = "windows",
		proxy = "<c-w>",
		expand = function()
			return require("which-key.extras").expand.win()
		end,
	},
	{
		"<leader>?",
		function()
			require("which-key").show({ global = false })
		end,
		desc = "Buffer Keymaps (which-key)",
	},
})

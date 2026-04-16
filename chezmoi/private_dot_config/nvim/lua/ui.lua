-- Plugins related to the UI

require("gitsigns").setup()

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command("GitBlameLine", function()
	local line_number = vim.fn.line(".") -- Get the current line number. See `:h line()`
	local filename = vim.api.nvim_buf_get_name(0)
	print(vim.fn.system({ "git", "blame", "-L", line_number .. ",+1", filename }))
end, { desc = "Print the git blame for the current line" })

vim.cmd([[colorscheme tokyonight-night]])


-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	callback = function()
		vim.hl.on_yank()
	end,
})

local wk = require("which-key")
wk.setup({})
wk.add({
	{ "<leader>c", group = "code" },
	{ "<leader>t", group = "line wrap" },
-- 	{ "<leader>d", group = "debug" },
-- 	{ "<leader>D", group = "Diffview", icon = { icon = "", color = "orange" } },
	{ "<leader>p", group = "Pack" },
-- 	{ "<leader>dp", group = "profiler" },
	{ "<leader>f", group = "file/find" },
-- 	{ "<leader>g", group = "git" },
-- 	{ "<leader>gh", group = "hunks" },
-- 	{ "<leader>s", group = "search" },
-- 	{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
-- 	{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
-- 	{ "[", group = "prev" },
-- 	{ "]", group = "next" },
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
-- 	-- better descriptions
-- 	{ "gx", desc = "Open with system app" },
-- 	{
-- 		"<leader>fC",
-- 		group = "Copy Path",
-- 		{
-- 			"<leader>fCf",
-- 			function()
-- 				vim.fn.setreg("+", vim.fn.expand("%:p")) -- Copy full file path to clipboard
-- 				vim.notify("Copied full file path: " .. vim.fn.expand("%:p"))
-- 			end,
-- 			desc = "Copy full file path",
-- 		},
-- 		{
-- 			"<leader>fCn",
-- 			function()
-- 				vim.fn.setreg("+", vim.fn.expand("%:t")) -- Copy file name to clipboard
-- 				vim.notify("Copied file name: " .. vim.fn.expand("%:t"))
-- 			end,
-- 			desc = "Copy file name",
-- 		},
-- 		{
-- 			"<leader>fCr",
-- 			function()
-- 				local cwd = vim.fn.getcwd() -- Current working directory
-- 				local full_path = vim.fn.expand("%:p") -- Full file path
-- 				local rel_path = full_path:sub(#cwd + 2) -- Remove cwd prefix and leading slash
-- 				vim.fn.setreg("+", rel_path) -- Copy relative file path to clipboard
-- 				vim.notify("Copied relative file path: " .. rel_path)
-- 			end,
-- 			desc = "Copy relative file path",
-- 		},
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Keymaps (which-key)",
		},
-- 		{
-- 			"<c-w><space>",
-- 			function()
-- 				require("which-key").show({ keys = "<c-w>", loop = true })
-- 			end,
-- 			desc = "Window Hydra Mode (which-key)",
-- 		},
-- 	},
-- 	{
-- 		-- Nested mappings are allowed and can be added in any order
-- 		-- Most attributes can be inherited or overridden on any level
-- 		-- There's no limit to the depth of nesting
-- 		mode = { "n", "v" }, -- NORMAL and VISUAL mode
-- 		{ "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
-- 		{ "<leader>w", "<cmd>w<cr>", desc = "Write" },
-- 	},
})

local builtin = require("telescope.builtin")
local home = os.getenv("HOME")

vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy search current buffer" })
vim.keymap.set("n", "<leader>fl", builtin.resume, { desc = "Open last picker" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fc", builtin.spell_suggest, { desc = "Spell check suggestions" })
-- LSP
vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "References" })
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
vim.keymap.set("n", "<leader>fd", function()
	builtin.diagnostics({ bufnr = 0 })
end, { desc = "Buffer Diagnostics" })

-- Files
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Files (cwd)" }) -- Search for files by name (respects .gitignore)
vim.keymap.set("n", "<leader>fF", function()
	builtin.find_files({ prompt_title = "Files (All)", hidden = true, no_ignore = true })
end, { desc = "Files (All)" })

vim.keymap.set("n", "<leader>fmn", function()
	builtin.find_files({ cwd = home, prompt_title = "Home (Normal)" })
end, { desc = "Find files in Home" })
vim.keymap.set("n", "<leader>fmN", function()
	builtin.find_files({ cwd = home, prompt_title = "Home (All)", hidden = true, no_ignore = true })
end, { desc = "Find all files in Home" })

vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep" })
vim.keymap.set("n", "<leader>fG", function()
	builtin.live_grep({
		prompt_title = "Grep (All)",
		additional_args = function()
			return { "--hidden", "--no-ignore" }
		end,
	})
end, { desc = "Grep (All)" })

vim.keymap.set("n", "<leader>fn", function()
	builtin.find_files({
		cwd = vim.fn.stdpath("config"),
		prompt_title = "Neovim Config Files",
	})
end, { desc = "Neovim configs" })

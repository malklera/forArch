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
vim.keymap.set("n", "<leader>fd", function()
	builtin.diagnostics({ bufnr = 0 })
end, { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "References" })

-- Files
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Files (cwd)" }) -- Search for files by name (respects .gitignore)
vim.keymap.set("n", "<leader>fa", function()
	builtin.find_files({ prompt_title = "CWD (All)", hidden = true, no_ignore = true })
end, { desc = "CWD (All)" })

vim.keymap.set("n", "<leader>fmn", function()
	builtin.find_files({ cwd = home, prompt_title = "Home (Normal)" })
end, { desc = "Find files in Home" })
vim.keymap.set("n", "<leader>fma", function()
	builtin.find_files({ cwd = home, prompt_title = "Home (All)", hidden = true, no_ignore = true })
end, { desc = "Find all files in Home" })

-- Do not actually use
-- vim.keymap.set("n", "<leader>frn", function()
-- 	builtin.find_files({ cwd = "/", prompt_title = "Root (Normal)" })
-- end, { desc = "Find files in root" })
-- vim.keymap.set("n", "<leader>fra", function()
-- 	builtin.find_files({ cwd = "/", prompt_title = "Root (All)", hidden = true, no_ignore = true })
-- end, { desc = "Find all files in root" })

vim.keymap.set("n", "<leader>fgn", builtin.live_grep, { desc = "Grep: Normal" })
vim.keymap.set("n", "<leader>fga", function()
	builtin.live_grep({
		prompt_title = "Grep (All)",
		additional_args = function()
			return { "--hidden", "--no-ignore" }
		end,
	})
end, { desc = "Grep: All Files" })

-- Do not actually use.
-- Root Grep: Normal
-- vim.keymap.set("n", "<leader>frgn", function()
-- 	builtin.live_grep({ cwd = "/", file_ignore_patterns = { "^proc/", "^dev/", "^sys/", "^tmp/" }, prompt_title = "Root Grep (Normal)" })
-- end, { desc = "Root Grep: Normal" })
-- vim.keymap.set("n", "<leader>frga", function()
-- 	builtin.live_grep({
-- 		cwd = "/",
-- 		prompt_title = "Root Grep (All)",
-- 		file_ignore_patterns = { "^proc/", "^dev/", "^sys/", "^tmp/" }, -- Relative to CWD
-- 		additional_args = function()
-- 			return { "--hidden", "--no-ignore" }
-- 		end,
-- 	})
-- end, { desc = "Root Grep: All Files" })

vim.keymap.set("n", "<leader>fn", function()
	builtin.find_files({
		cwd = vim.fn.stdpath("config"),
		prompt_title = "Neovim Config Files",
	})
end, { desc = "Neovim configs" })

local builtin = require("telescope.builtin")
local make_entry = require("telescope.make_entry")
local strings = require("plenary.strings")
local home = os.getenv("HOME")

-- rg prints the ENTIRE line per match; on files with megabyte-long lines
-- (e.g. Inkscape SVGs) that pipes gigabytes into nvim. Truncate instead.
require("telescope").setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--max-columns=200",
			"--max-columns-preview",
		},
		layout_strategy = "flex",
		layout_config = {
			-- Make the picker fill the whole window, leaving only the
			-- statusline and the command line visible at the bottom,
			-- while keeping the original layout: prompt at the bottom,
			-- results above it, preview to the right.
			horizontal = {
				height = { padding = 0 },
				width = { padding = 0 },
				prompt_position = "bottom",
			},
			vertical = {
				height = { padding = 0 },
				width = { padding = 0 },
				prompt_position = "bottom",
			},
		},
	},
})

vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy search current buffer" })
vim.keymap.set("n", "<leader>fl", builtin.resume, { desc = "Open last picker" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fc", builtin.spell_suggest, { desc = "Spell check suggestions" })
-- Custom entry format for document/workspace symbols:
-- line number (left), symbol name (center, uses all free space),
-- symbol type (right, right-aligned). The type never clips the name:
-- the name only truncates if the row itself runs out of room.
local LINE_WIDTH = 4

local function lsp_symbols_entry_maker(opts)
	opts = opts or {}

	return function(entry)
		local symbol_msg = entry.text
		local symbol_type, symbol_name = symbol_msg:match("%[(.+)%]%s+(.*)")
		local line_no = tostring(entry.lnum)

		local ordinal = (symbol_name or "") .. " " .. (symbol_type or "unknown")

		local function make_display(_, picker)
			local results_width = vim.api.nvim_win_get_width(picker.results_win)
			local caret_w = vim.fn.strdisplaywidth(picker.selection_caret or "")
			local avail = results_width - caret_w

			local typ = (symbol_type or ""):lower()
			local typ_w = vim.fn.strdisplaywidth(typ)

			local line_col = #line_no >= LINE_WIDTH and line_no or string.rep(" ", LINE_WIDTH - #line_no) .. line_no

			local name_space = avail - LINE_WIDTH - typ_w - 2
			if name_space < 1 then
				name_space = 1
			end
			local name_part = strings.truncate(symbol_name or "", name_space)
			local name_pad = string.rep(" ", name_space - vim.fn.strdisplaywidth(name_part))

			return table.concat({ line_col, name_part .. name_pad, typ }, " ")
		end

		return make_entry.set_default_entry_mt({
			value = entry,
			ordinal = ordinal,
			display = make_display,
			filename = entry.filename,
			lnum = entry.lnum,
			col = entry.col,
			symbol_name = symbol_name,
			symbol_type = symbol_type,
			start = entry.start,
			finish = entry.finish,
		}, opts)
	end
end

-- LSP
vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "References" })
vim.keymap.set("n", "<leader>fs", function()
	builtin.lsp_document_symbols({ entry_maker = lsp_symbols_entry_maker() })
end, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fS", function()
	builtin.lsp_workspace_symbols({ entry_maker = lsp_symbols_entry_maker() })
end, { desc = "Workspace symbols" })
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

function _G.__position()
	local line = vim.fn.line(".")
	local total_lines = vim.fn.line("$")
	local col = vim.fn.col(".")
	local total_col = math.max(vim.fn.col("$") - 1, 1)
	-- return string.format("%3d/%-3d - %2d/%-2d", line, total_lines, col, total_col)
	return string.format("%d/%-d - %d/%-d", line, total_lines, col, total_col)
end

local custom_theme = {
	normal = {
		a = { fg = "#7aa2f7", bg = "#1a1b26" },
		b = { fg = "#7aa2f7", bg = "#1a1b26" },
		c = { fg = "#c0caf5", bg = "#1a1b26" },
	},
	insert = { a = { fg = "#9ece6a", bg = "#1a1b26" } },
	visual = { a = { fg = "#bb9af7", bg = "#1a1b26" } },
	replace = { a = { fg = "#f7768e", bg = "#1a1b26" } },
	command = { a = { fg = "#e0af68", bg = "#1a1b26" } },
	inactive = {
		a = { fg = "#565f89", bg = "#16161e" },
		b = { fg = "#565f89", bg = "#16161e" },
		c = { fg = "#565f89", bg = "#16161e" },
	},
}

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = custom_theme,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "branch" },
		lualine_b = { "diff" },
		lualine_c = { { "filename", path = 2, shorting_target = 0 }, "diagnostics" },
		lualine_x = { {
			"encoding",
			cond = function()
				return vim.bo.fileencoding ~= "utf-8"
			end,
		} },
		lualine_y = {},
		lualine_z = {
			function()
				return __position()
			end,
		},
	},
	inactive_sections = {
		lualine_a = { "branch" },
		lualine_b = { { "diff", color = { fg = "#565f89", bg = "#16161e" } } },
		lualine_c = { { "filename", path = 2, shorting_target = 0 }, { "diagnostics", color = { fg = "#565f89", bg = "#16161e" } } },
		lualine_x = { {
			"encoding",
			cond = function()
				return vim.bo.fileencoding ~= "utf-8"
			end,
		} },
		lualine_y = {},
		lualine_z = {
			function()
				return __position()
			end,
		},
	},
})

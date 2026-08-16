-- Plugins related to the UI

vim.cmd([[colorscheme tokyonight-night]])

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	callback = function()
		vim.hl.on_yank()
	end,
})

-- original has [buffer number]
-- vim.opt.statusline = "[%n] %<%F %h%w%m%r %{v:lua.__git_branch()}%=%{v:lua.__diagnostics()} %{v:lua.__position()}"
-- vim.opt.statusline = "%<%F %h%w%m%r %{v:lua.__git_branch()}%=%{v:lua.__diagnostics()} %{v:lua.__position()}"
--
-- local git_branch = vim.g.git_branch or ""
--
-- local function update_git_branch()
-- 	local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null")
-- 	if vim.v.shell_error ~= 0 then
-- 		git_branch = ""
-- 	else
-- 		git_branch = branch:gsub("%s+", "")
-- 	end
-- end
--
-- local group = vim.api.nvim_create_augroup("StatuslineGit", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged", "VimResume" }, {
-- 	group = group,
-- 	callback = update_git_branch,
-- })
--
-- function _G.__git_branch()
-- 	return git_branch
-- end
--
-- function _G.__diagnostics()
-- 	local counts = vim.diagnostic.count(0)
-- 	local errors = counts[vim.diagnostic.severity.ERROR] or 0
-- 	local warnings = counts[vim.diagnostic.severity.WARN] or 0
-- 	local parts = {}
-- 	if errors > 0 then
-- 		table.insert(parts, "E:" .. errors)
-- 	end
-- 	if warnings > 0 then
-- 		table.insert(parts, "W:" .. warnings)
-- 	end
-- 	if #parts == 0 then
-- 		return ""
-- 	end
-- 	return " " .. table.concat(parts, " ")
-- end
--
-- function _G.__position()
-- 	local line = vim.fn.line(".")
-- 	local total_lines = vim.fn.line("$")
-- 	local col = vim.fn.col(".")
-- 	local total_col = math.max(vim.fn.col("$") - 1, 1)
-- 	return string.format("%3d/%-3d - %2d/%-2d", line, total_lines, col, total_col)
-- end

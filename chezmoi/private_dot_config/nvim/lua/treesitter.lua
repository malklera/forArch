require("nvim-treesitter").setup({})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		local filetype = vim.bo.filetype
		if filetype and filetype ~= "" then
			pcall(vim.treesitter.start)
		end
	end,
})

vim.api.nvim_create_autocmd("PackChanged", {
	desc = "Handle nvim-treesitter updates",
	group = vim.api.nvim_create_augroup("nvim-treesitter-pack-changed-update-handler", { clear = true }),
	callback = function(event)
		if event.data.kind == "update" then
			local ok = pcall(vim.cmd, "TSUpdate")
			if ok then
				vim.notify("TSUpdate completed successfully!", vim.log.levels.INFO)
			else
				vim.notify("TSUpdate command not available yet, skipping", vim.log.levels.WARN)
			end
		end
	end,
})

local SKIP_FT = {
	[""] = true,
	qf = true,
	help = true,
	man = true,
	noice = true,
	notify = true,
	snacks_notif = true,
	snacks_notif_history = true,
	snacks_picker_list = true,
	snacks_picker_input = true,
	snacks_input = true,
	snacks_terminal = true,
	dapui_scopes = true,
	dapui_breakpoints = true,
	dapui_stacks = true,
	dapui_watches = true,
	dapui_console = true,
	dap_repl = true,
	gitcommit = true,
	gitrebase = true,
	lazy = true,
	lspinfo = true,
	checkhealth = true,
	startuptime = true,
	TelescopePrompt = true,
	TelescopeResults = true,
	spectre_panel = true,
	["grug-far"] = true,
	trouble = true,
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*" },
	callback = function()
		local ft = vim.bo.filetype
		if SKIP_FT[ft] then
			return
		end

		local ok = pcall(vim.treesitter.start)
		if not ok then
			return
		end

		-- Only set expr folds when treesitter successfully started
		-- vim.wo[0].foldmethod = "expr"
		-- vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end,
})

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.api.nvim_create_autocmd("FileType", {
	desc = "Auto-install missing treesitter parsers",
	callback = function(args)
		local ft = args.match
		if SKIP_FT[ft] then
			return
		end

		local lang = vim.treesitter.language.get_lang(ft)
		if not lang then
			return
		end

		local installed = require("nvim-treesitter.config").get_installed()
		if not vim.tbl_contains(installed, lang) then
			require("nvim-treesitter").install(lang)
		end
	end,
})

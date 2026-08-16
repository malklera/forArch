-- [[ Formating ]]
-- vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofmt" },
		sh = { "shellharden", "shfmt" },
		json = { "prettier" },
		jsonc = { "prettier" },
		html = { "superhtml" },
		rust = { "rustfmt" },
		yaml = { "yamlfmt" },
		-- sql = { "sqlfluff" }, do not actually work

		-- python = { "" },
		-- javascript = { "prettier" },
		-- typescript = { "prettier" },
		-- javascriptreact = { "prettier" },
		-- typescriptreact = { "prettier" },
		-- css = { "prettier" },
	},
	-- formatters = {
	-- 	sqlfluff = {
	-- 		args = { "fix", "-", "--dialect", "sqlite" },
	-- 		require_cwd = false,
	-- 	},
	-- },
})

vim.keymap.set({ "n" }, "<leader>cf", function()
	require("conform").format({ async = true }, function(err, did_edit)
		if not err and did_edit then
			vim.notify("Code formatted", vim.log.levels.INFO, { title = "Conform" })
		end
	end)
end, { desc = "Format buffer" })

vim.keymap.set({ "n", "v" }, "<leader>cn", "<cmd>ConformInfo<cr>", { desc = "Conform Info" })

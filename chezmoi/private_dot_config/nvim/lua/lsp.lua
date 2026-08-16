vim.diagnostic.config({
	virtual_text = true, -- Keep or remove if using virtual_lines
	float = {
		border = "rounded", -- Optional: nice border
		wrap = true, -- Enable text wrapping inside the float
		header = "", -- Optional: hide redundant header
	},
})

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_win_get_config(win).relative ~= "" then
				return
			end
		end
		vim.diagnostic.open_float(nil, { scope = "cursor", focus = false })
	end,
})

-- [[ lua ]]
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			diagnostics = {
				globals = { "vim" },
			},
			format = {
				enable = true,
				defaultConfig = {
					indent_style = "space",
					indent_size = "2",
				},
			},
		},
	},
})

-- [[ go ]]
vim.lsp.config("gopls", {
	settings = {
		gopls = {
			staticcheck = true,
			analyses = {
				SA4017 = true,
			},
		},
	},
})

-- Got tired of it not updating if i do not save the file
-- vim.lsp.config("golangci_lint_ls", {})

-- [[ rust ]]
vim.lsp.config("rust_analyzer", {})

vim.lsp.config("bashls", {})
vim.lsp.config("jsonls", {})
vim.lsp.config("superhtml", {})

-- Enable all configured servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
-- vim.lsp.enable("golangci_lint_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("bashls")
vim.lsp.enable("jsonls")
vim.lsp.enable("superhtml")

-- [[ Keymaps ]]
vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "K", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		if client:supports_method("textDocument/hover") then
			vim.lsp.buf.hover({ border = "rounded" })
			return
		end
	end
	-- Fallback to default K behavior (help) if no LSP hover support
	vim.cmd.normal("K")
end, { desc = "LSP hover (floating) or keyword help" })

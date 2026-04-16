require("mason").setup()

require("mason-lspconfig").setup({
	automatic_installation = false, -- you install manually via :Mason
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.o.signcolumn = "yes:1"
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method("textDocument/completion") then
			vim.o.complete = "o,.,w,b,u"
			vim.o.completeopt = "menu,menuone,popup,noinsert"
			vim.lsp.completion.enable(true, client.id, args.buf)
		end
	end,
})

vim.diagnostic.config({
	virtual_text = true,
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
    },
  },
})

-- [[ rust ]]
vim.lsp.config("rust_analyzer", {})

vim.lsp.config("bashls", {})
vim.lsp.config("jsonls", {})
vim.lsp.config("superhtml", {})

-- Enable all configured servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("bashls")
vim.lsp.enable("jsonls")
vim.lsp.enable("superhtml")

-- [[ Formating ]]
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofmt" },
		python = { "black" },
		json = { "prettier" },
		markdown = { "prettier" }, -- think if i want this
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		css = { "prettier" },
		html = { "superhtml" },
	},
})

vim.keymap.set({ "n" }, "<leader>cf", function()
	require("conform").format({ async = true }, function(err, did_edit)
		if not err and did_edit then
			vim.notify("Code formatted", vim.log.levels.INFO, { title = "Conform" })
		end
	end)
end, { desc = "Format buffer" })

vim.keymap.set({ "n", "v" }, "<leader>cn", "<cmd>ConformInfo<cr>", { desc = "Conform Info" })

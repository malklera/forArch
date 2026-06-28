require("mason").setup()

require("mason-lspconfig").setup({
	automatic_installation = false, -- you install manually via :Mason
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method("textDocument/completion") then
			vim.o.complete = "o,.,w,b,u"
			vim.o.completeopt = "menu,menuone,popup,noinsert"
			vim.lsp.completion.enable(true, client.id, args.buf)
		end

		if client:supports_method("textDocument/documentHighlight") then
			local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
			vim.api.nvim_clear_autocmds({ buffer = args.buf, group = group })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = args.buf,
				group = group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = args.buf,
				group = group,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

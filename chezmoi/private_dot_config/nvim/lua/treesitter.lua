require('nvim-treesitter').setup({
	install_dir = vim.fn.stdpath('data') .. '/site'
})

vim.api.nvim_create_autocmd('FileType', {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

		local lang = vim.treesitter.language.get_lang(args.match)
		if not lang then return end

		local available = require('nvim-treesitter.config').get_available()
		if not vim.tbl_contains(available, lang) then return end

		local installed = require('nvim-treesitter.config').get_installed()
		if not vim.tbl_contains(installed, lang) then
			require('nvim-treesitter').install(lang)
		end
	end,
	once = true
})

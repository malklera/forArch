-- [[ Add optional packages ]]
-- Nvim comes bundled with a set of packages that are not enabled by
-- default. You can enable any of them by using the `:packadd` command.

vim.pack.add({
	'https://github.com/folke/tokyonight.nvim',
	'https://github.com/neovim/nvim-lspconfig',
	'https://github.com/nvim-treesitter/nvim-treesitter',
	'https://github.com/lewis6991/gitsigns.nvim',
	'https://github.com/mason-org/mason.nvim',
	'https://github.com/williamboman/mason-lspconfig.nvim',
	'https://github.com/rmagatti/auto-session',
  'https://github.com/stevearc/conform.nvim'
})

vim.cmd.packadd('nvim.undotree')
vim.cmd.packadd('nvim.difftool')

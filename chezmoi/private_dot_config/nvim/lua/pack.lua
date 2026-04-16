-- [[ Add optional packages ]]
-- Nvim comes bundled with a set of packages that are not enabled by
-- default. You can enable any of them by using the `:packadd` command.

vim.pack.add({
	"https://github.com/folke/tokyonight.nvim", -- colorscheme
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/lewis6991/gitsigns.nvim", -- do i use this?
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim", -- for mason
	"https://github.com/rmagatti/auto-session",
	"https://github.com/stevearc/conform.nvim", -- formatter
	"https://github.com/folke/which-key.nvim",
	-- { src = "https://github.com/nvim-telescope/telescope.nvim", version = vim.version.range(">=0.2.0") },
 "https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-lua/plenary.nvim", -- for telescope
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim", -- for telescope
})

vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")

vim.keymap.set("n", "<leader>pu", "<cmd>lua vim.pack.update()<CR>", {desc = "Update plugins"})
vim.keymap.set("n", "<leader>pc", function()
    -- 1. Identify plugins that are on disk but NOT in your pack.lua
    local inactive = vim.iter(vim.pack.get())
        :filter(function(x) return not x.active end)
        :map(function(x) return x.spec.name end)
        :totable()

    -- 2. If we found any, delete them
    if #inactive > 0 then
        print("Cleaning: " .. table.concat(inactive, ", "))
        vim.pack.del(inactive)
    else
        print("Everything is clean!")
    end
end, { desc = "Pack Clean: Delete unused plugins" })

-- [[ Setting options ]] See `:h vim.o`

vim.opt.number = true -- Print the line number in front of each line
vim.opt.relativenumber = true
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true -- Copy indent from current line
vim.opt.ignorecase = true -- Case-insensitive searching
vim.opt.smartcase = true --  UNLESS \C or one or more capital letters in the search term
vim.opt.cursorline = true -- Highlight the line where the cursor is on
vim.opt.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s) See `:help 'confirm'`
vim.opt.confirm = true

vim.opt.colorcolumn = "80,120" -- Highlight column 80 and 120
vim.opt.list = false -- show tabs and end of line whitespace
vim.opt.swapfile = false -- will use undo-tree for this
vim.opt.undofile = true -- enable persistent undotree
vim.opt.backup = false -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup before writing
vim.opt.signcolumn = "yes:1"
vim.opt.statusline = "[%n] %<%F %h%w%m%r%=%-(%l/%L - %c%V%) "
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- vim.opt.autocomplete = true -- think about this
-- vim.opt.completeopt = { "menuone", "popup", "noinsert" } -- Options for completion menu
-- think if i need this
-- vim.cmd.filetype("plugin indent on") -- Enable filetype detection, plugins, and indentation
vim.opt.tabstop = 4 -- Render TAB as 4 spaces
vim.opt.softtabstop = 4 -- Number of spaces a <Tab> counts for while editing
vim.opt.shiftwidth = 4 -- Number of spaces for auto-indent
vim.opt.expandtab = true -- Convert TABs to spaces
vim.opt.hlsearch = false -- Don't highlight search results

-- see if i like/need this
vim.opt.synmaxcol = 300 -- Syntax highlighting limit
vim.opt.updatetime = 300 -- Faster completion
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- maybe this is usefull?
vim.filetype.add({
	extension = {
		env = "dotenv",
		["gowork"] = "gowork",
		["gotmpl"] = "gotmpl",
	},
	filename = {
		[".env"] = "dotenv",
		["env"] = "dotenv",
		["go.work"] = "gowork",
	},
	pattern = {
		["[jt]sconfig.*.json"] = "jsonc",
		["%.env%.[%w_.-]+"] = "dotenv",
	},
})

-- [[ Basic Autocommands ]].
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		vim.opt.clipboard = "unnamedplus"
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "html", "lua" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

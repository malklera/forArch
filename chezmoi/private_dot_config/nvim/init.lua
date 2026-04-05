-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
-- think if i need this
-- vim.cmd.filetype("plugin indent on") -- Enable filetype detection, plugins, and indentation


-- [[ Setting options ]] See `:h vim.o`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`
-- To see documentation for an option, you can use `:h 'optionname'`, for example `:h 'number'`
-- (Note the single quotes)

vim.o.number = true -- Print the line number in front of each line

-- Use relative line numbers, so that it is easier to jump with j, k. This will affect the 'number'
-- option above, see `:h number_relativenumber`
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.cursorline = true -- Highlight the line where the cursor is on
vim.o.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s) See `:help 'confirm'`
vim.o.confirm = true

vim.o.colorcolumn = "80,120" -- Highlight column 80 and 120
vim.o.list = false -- show tabs and end of line whitespace
vim.o.swapfile = false -- will use undo-tree for this
vim.o.undofile = true -- enable persistent undotree
-- vim.o.wrap = false -- see how i like wraping, if i do not like, uncoment this
vim.o.signcolumn = 'yes:1'
vim.o.statusline = '[%n] %<%F %h%w%m%r%=%-(%l/%L - %c%V%) '
-- vim.o.autocomplete = true -- think about this
-- vim.o.completeopt = { "menuone", "popup", "noinsert" } -- Options for completion menu
-- think if i need this
-- vim.cmd.filetype("plugin indent on") -- Enable filetype detection, plugins, and indentation

-- [[ Set up keymaps ]] See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-j>', '<C-w>j')
vim.keymap.set({ 'n' }, '<A-k>', '<C-w>k')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Press Escape to clear search highlights

vim.keymap.set('n', '<Leader>v', '<cmd>vsplit<CR>', { silent = true })
vim.keymap.set('n', '<Leader>h', '<cmd>split<CR>', { silent = true })
vim.keymap.set('n', '<C-t>', '<cmd>tabnew<CR>', { silent = true })

-- [[ Basic Autocommands ]].
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Create user commands ]]
-- See `:h nvim_create_user_command()` and `:h user-commands`

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command('GitBlameLine', function()
  local line_number = vim.fn.line('.') -- Get the current line number. See `:h line()`
  local filename = vim.api.nvim_buf_get_name(0)
  print(vim.fn.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }))
end, { desc = 'Print the git blame for the current line' })

-- [[ Add optional packages ]]
-- Nvim comes bundled with a set of packages that are not enabled by
-- default. You can enable any of them by using the `:packadd` command.

-- For example, to add the "nohlsearch" package to automatically turn off search highlighting after
-- 'updatetime' and when going to insert mode
-- vim.cmd('packadd! nohlsearch')
--
-- vim.pack.add({
-- 	'https://github.com/folke/tokyonight.nvim',
-- 	'https://github.com/neovim/nvim-lspconfig',
-- 	'https://github.com/nvim-treesitter/nvim-treesitter',
-- 	'https://github.com/lewis6991/gitsigns.nvim',
-- 	'https://github.com/mason-org/mason.nvim'
-- })
--
--vim.cmd.packadd('nvim.undotree')
--vim.cmd.packadd('nvim.difftool')
-- require('gitsigns').setup()
-- vim.cmd.colorscheme('tokyonight')
--
-- vim.api.nvim_create_autocmd('LspAttach', {
--     callback = function(args)
--         vim.o.signcolumn = 'yes:1'
--         local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
--         if client:supports_method('textDocument/completion') then
--             vim.o.complete = 'o,.,w,b,u'
--             vim.o.completeopt = 'menu,menuone,popup,noinsert'
--             vim.lsp.completion.enable(true, client.id, args.buf)
--         end
--     end
-- })

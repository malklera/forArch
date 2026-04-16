-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '

require('options')
require('pack')
require('keymaps')
require('ui')
require('treesitter')
require('lsp')
require('session')
require('tele')

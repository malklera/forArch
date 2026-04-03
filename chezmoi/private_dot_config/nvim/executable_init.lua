vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setting options
require("config.options")

-- General keymaps
require("config.keymaps")

-- Install lazy.nvim and import plugins
require("config.lazy")

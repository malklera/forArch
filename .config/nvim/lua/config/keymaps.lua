-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Exit insert mode
vim.keymap.set("i", "jj", "<Esc>", { silent = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- On visual mode, select text and move it.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- On visual mode, better indent handling.
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Open [s]mall [t]erminal
vim.keymap.set("n", "<leader>t", function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 15)
end, { desc = "small [t]erminal" })

-- Switch to last accessed buffer
vim.keymap.set("n", "<leader>p", "<cmd>b#<CR>", { desc = "Switch to [p]revious buffer" })

-- Close current buffer
vim.keymap.set("n", "<C-w>", "<cmd>bdelete<CR>", { desc = "Close current buffer" })

-- Vertical split
vim.keymap.set("n", "<leader>v", "<cmd>vsp<CR>", { desc = "[v]ertical split" })

-- Horizontal split
vim.keymap.set("n", "<leader>h", "<cmd>hsp<CR>", { desc = "[h]orizontal split" })

-- Close pane
vim.keymap.set("n", "<leader>c", "<cmd>q<CR>", { desc = "[c]lose pane" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "diagnostic [q]uickfix" })

-- Make :help always open in a new tab
vim.cmd("cabbrev help tab help")

-- use U to redo
vim.keymap.set("n", "U", "<C-r>", { noremap = true, desc = "[U]ndo" })

-- diff between two files
vim.keymap.set("n", "<leader>i", "<cmd>windo diffthis<CR>", { desc = "d[i]ff files" })

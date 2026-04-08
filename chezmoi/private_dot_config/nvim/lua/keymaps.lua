-- [[ Set up keymaps ]] See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ "t", "i" }, "<A-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set({ "t", "i" }, "<A-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set({ "t", "i" }, "<A-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set({ "t", "i" }, "<A-l>", "<C-\\><C-n><C-w>l")
vim.keymap.set({ "n" }, "<A-h>", "<C-w>h")
vim.keymap.set({ "n" }, "<A-j>", "<C-w>j")
vim.keymap.set({ "n" }, "<A-k>", "<C-w>k")
vim.keymap.set({ "n" }, "<A-l>", "<C-w>l")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Press Escape to clear search highlights

vim.keymap.set("n", "<Leader>v", "<cmd>vsplit<CR>", { silent = true })
vim.keymap.set("n", "<Leader>h", "<cmd>split<CR>", { silent = true })
vim.keymap.set("n", "<C-t>", "<cmd>tabnew<CR>", { silent = true })

-- vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
-- vim.keymap.set("n", "<leader>bp", ":bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bl", ":ls<CR>", { desc = "List buffers" })
vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Back to last buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
-- Map <leader>b1 through <leader>b9
for i = 1, 9 do
	vim.keymap.set("n", "<leader>b" .. i, ":" .. i .. "b<CR>", { desc = "Go to buffer " .. i })
end

vim.keymap.set("v", ">", ">gv", { noremap = true })
vim.keymap.set("v", "<", "<gv", { noremap = true })
vim.keymap.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
	print("Wrap: " .. (vim.opt.wrap:get() and "On" or "Off"))
end, { desc = "Toggle line wrap" })

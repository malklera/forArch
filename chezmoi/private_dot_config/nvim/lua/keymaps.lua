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

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear srach highlights" })

vim.keymap.set("n", "<leader>bl", ":ls<CR>", { desc = "List buffers" })
vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Back to last buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
-- Map <leader>b1 through <leader>b9
for i = 1, 9 do
	vim.keymap.set("n", "<leader>b" .. i, ":" .. i .. "b<CR>", { desc = "Go to buffer " .. i })
end

vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true, desc = "Better indenting, stay in visual mode" })
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true, desc = "Better indenting, stay in visual mode" })
vim.keymap.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
	print("Wrap: " .. (vim.opt.wrap:get() and "On" or "Off"))
end, { desc = "Toggle line wrap" })

vim.keymap.set(
	"v",
	"p",
	'"_dP',
	{ noremap = true, silent = true, desc = "Doesn't replace clipboard with deleted text" }
)

-- Auto close pairs of symbols, try them
vim.keymap.set("i", "`", "``<left>")
vim.keymap.set("i", '"', '""<left>')
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")
vim.keymap.set("i", "<", "<><left>")

-- LSP
vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "Go to definition"})
vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "Go to declaration"})
-- vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { desc = "Go to implementation"})

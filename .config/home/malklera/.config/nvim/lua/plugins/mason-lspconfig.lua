return {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
            "lua_ls", -- lua lsp
            "gopls", -- golang lsp
            "pyright", -- python
            "bashls", -- bash
            "html",
            "jsonls", -- json lsp
            "ts_ls", -- javascript and typescript
            "cssls", -- css lsp
            "tailwindcss", -- tailwind lsp
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        }, -- close dependencies
        automatic_enable = false,
    },
}
--[[
Install the following formatters manually

"golangci-lint", -- cli golang linter
"stylua", -- lua formatter
"staticcheck", -- in nvim golang linter
"black", -- python formatter
"jq", -- json formatter
"prettier", -- js, ts, html, css formatter
]]

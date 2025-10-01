return {
    -- Formatter
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = "n",
            desc = "[f]ormat buffer",
        },
    },
    opts = {
        notify_on_error = true,
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "black" },
            json = { "jq" },
            go = { "gofmt" },
            html = { "prettier" },
            css = { "prettier" },
            javascript = { "prettier" },
            typescript = { "prettier" },
        },
        formatters = {
            stylua = {
                command = "stylua",
                args = {
                    "--indent-type",
                    "Spaces",
                    "--indent-width",
                    "4",
                    "-",
                },
            },
        },
    },
}

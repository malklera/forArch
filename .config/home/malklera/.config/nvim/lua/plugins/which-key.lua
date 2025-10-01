return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        spec = {
            { "<leader>g", group = "[g]oto" },
            { "<leader>gw", group = "[w]orkspace" },
            { "<leader>gr", group = "lsp" },
            { "<leader>s", group = "[s]earch" },
            { "gr", group = "lsp" },
        },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}

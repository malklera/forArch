return {
    "Darazaki/indent-o-matic",
    config = function()
        require("indent-o-matic").setup({
            filetype_text = {
                standard_widths = { 4 },
            },
        })
    end,
}

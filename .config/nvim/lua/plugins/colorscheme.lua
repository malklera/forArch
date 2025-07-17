return {
    "folke/tokyonight.nvim",
    priority = 1000, -- Set a high priority to ensure it loads early
    config = function()
        -- Load the colorscheme here
        vim.cmd.colorscheme("tokyonight-night")

        -- Optional: Configure TokyoNight with specific options
        -- See :help tokyonight-settings for all options
        require("tokyonight").setup({
            style = "night", -- 'night', 'storm', 'moon', 'day'
            transparent = false, -- Enable this to remove the background
            terminal_colors = true, -- Enable setting the terminal colors
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
                functions = { bold = true },
                variables = {},
                -- For more styles, see :help tokyonight-settings
            },
            -- Custom highlights
            -- For example, to make line numbers a different color
            on_colors = function(colors)
                -- colors is a table containing all the generated colors
                -- You can use these colors to set custom highlights
                -- For example:
                -- vim.api.nvim_set_hl(0, "LineNr", { fg = colors.magenta })
            end,
            on_highlights = function(highlights, colors)
                -- highlights is a table containing all the generated highlights
                -- You can modify existing highlights or add new ones
                -- For example, to change the background of "Normal"
                -- highlights.Normal.bg = colors.none
            end,
        })
    end,
}

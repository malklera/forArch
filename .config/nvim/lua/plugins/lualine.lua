return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        -- Custom progress function
        local function progress_m()
            local cur = vim.fn.line(".")
            local total = vim.fn.line("$")
            local col = vim.fn.charcol(".")
            --           return string.format("%d|%d/%d", col, cur, total)
            return string.format("%d/%d|%02d", cur, total, col)
        end

        require("lualine").setup({
            options = {
                -- theme = "catppuccin",
                icons_enabled = true,
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        fmt = function(res)
                            return res:sub(1, 1)
                        end,
                    },
                },
                lualine_c = {
                    {
                        "filename",
                        path = 2,
                    },
                },
                lualine_x = {
                    {
                        function()
                            local encoding = vim.bo.fenc
                            if encoding ~= "utf-8" and encoding ~= "" then
                                return encoding
                            else
                                return ""
                            end
                        end,
                    },
                },
                lualine_y = {
                    "filetype",
                },
                lualine_z = {
                    progress_m,
                },
            },
        })
    end,
}

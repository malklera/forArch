return {
    { -- Fuzzy Finder (files, lsp, etc)
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                "nvim-telescope/telescope-fzf-native.nvim",

                -- `build` is used to run some command when the plugin is installed/updated.
                -- This is only run then, not every time Neovim starts up.
                build = "make",

                -- `cond` is a condition used to determine whether this plugin should be
                -- installed and loaded.
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
            { "nvim-telescope/telescope-ui-select.nvim" },

            -- Useful for getting pretty icons, but requires a Nerd Font.
            { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
        },
        config = function()
            -- Telescope is a fuzzy finder that comes with a lot of different things that
            -- it can fuzzy find! It's more than just a "file finder", it can search
            -- many different aspects of Neovim, your workspace, LSP, and more!
            --
            -- The easiest way to use Telescope, is to start by doing something like:
            --  :Telescope help_tags
            --
            -- After running this command, a window will open up and you're able to
            -- type in the prompt window. You'll see a list of `help_tags` options and
            -- a corresponding preview of the help.
            --
            -- Two important keymaps to use while in Telescope are:
            --  - Insert mode: <c-/>
            --  - Normal mode: ?
            --
            -- This opens a window that shows you all of the keymaps for the current
            -- Telescope picker. This is really useful to discover what Telescope can
            -- do as well as how to actually do it!

            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            require("telescope").setup({
                -- You can put your default mappings / updates / etc. in here
                --  All the info you're looking for is in `:help telescope.setup()`
                defaults = {
                  layout_config = {
                      horizontal = {
                          width = { padding = 0 },
                          height = { padding = 0 },
                      },
                  },
                  results_title = false,
                  preview = false,
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            })

            -- Enable Telescope extensions if they are installed
            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")

            -- See `:help telescope.builtin`
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[h]elp" })
            vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[k]eymaps" })
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[f]iles" })
            vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[s]elect Telescope" })
            vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "current [w]ord" })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "by [g]rep" })
            vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[d]iagnostics" })
            vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[r]esume" })
            vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = 'Recent Files ("." for repeat)' })
            vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

            -- Slightly advanced example of overriding default behavior and theme
            vim.keymap.set("n", "<leader>/", function()
                -- You can pass additional configuration to Telescope to change the theme, layout, etc.
                builtin.current_buffer_fuzzy_find({
                    layout_config = {
                        prompt_position = "bottom",
                        width = { padding = 0 },
                        height = { padding = 0 },
                    },
                })
            end, { desc = "[/] Fuzzily search in current buffer" })

            -- It's also possible to pass additional configuration options.
            --  See `:help telescope.builtin.live_grep()` for information about particular keys
            vim.keymap.set("n", "<leader>s/", function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = "Live Grep in Open Files",
                })
            end, { desc = "[/] in Open Files" })

            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set("n", "<leader>sn", function()
                builtin.find_files({ cwd = vim.fn.stdpath("config") })
            end, { desc = "[n]eovim files" })

            -- Shortcut for searching hidden files
            vim.keymap.set("n", "<leader>si", function()
                builtin.find_files({ hidden = true, no_ignore = true })
            end, { desc = "[i]gnored files" })

            -- Shortcut for searching the whole computer
            vim.keymap.set("n", "<leader>sc", function()
                builtin.find_files( { cwd = "/"})
            end, { desc = "whole [c]omputer"})
        end,
    },
}

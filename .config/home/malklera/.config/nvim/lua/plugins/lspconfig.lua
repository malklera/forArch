return {
    "neovim/nvim-lspconfig",
    -- Your LSP server configurations go here
    config = function()
        -- Common on_attach function for all LSPs
        -- This function runs AFTER the LSP is attached to a particular buffer (bufnr).
        local on_attach = function(client, bufnr)
            local map = function(keys, func, desc, mode)
                mode = mode or "n"
                vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "" .. desc })
            end

            -- Jump to the definition of the word under your cursor.
            --  This is where a variable was first declared, or where a function is defined, etc.
            --  To jump back, press <C-t>.
            map("grd", require("telescope.builtin").lsp_definitions, "[d]efinition")

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map("grt", require("telescope.builtin").lsp_type_definitions, "[t]ype definition")

            -- Fuzzy find all the symbols in your current workspace.
            --  Similar to document symbols, except searches over your entire project.
            map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[w]orkspace Symbols")

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header.
            map("grD", vim.lsp.buf.declaration, "[D]eclaration")

            -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
            ---@param client vim.lsp.Client
            ---@param method vim.lsp.protocol.Method
            ---@param bufnr? integer some lsp support methods only in specific files
            ---@return boolean
            local function client_supports_method(client, method, bufnr)
                if vim.fn.has("nvim-0.11") == 1 then
                    return client:supports_method(method, bufnr)
                else
                    return client.supports_method(method, { bufnr = bufnr })
                end
            end

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            -- local client = vim.lsp.get_client_by_id(client.id)
            if
                client
                and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr)
            then
                local highlight_augroup = vim.api.nvim_create_augroup("my-lsp-highlight", { clear = false })
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    buffer = bufnr,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.document_highlight,
                })

                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    buffer = bufnr,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.clear_references,
                })

                vim.api.nvim_create_autocmd("LspDetach", {
                    group = vim.api.nvim_create_augroup("my-lsp-detach", { clear = true }),
                    callback = function(event2)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds({ group = "my-lsp-highlight", buffer = event2.buf })
                    end, -- close callback
                }) -- close LspDetach

                -- Open an floating window with the diagnostic on the cursor
                vim.api.nvim_create_autocmd("CursorHold", {
                    buffer = bufnr,
                    callback = function()
                        local opts = {
                            focusable = false,
                            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                            border = "rounded",
                            source = "always",
                            prefix = " ",
                            scope = "cursor",
                        }
                        vim.diagnostic.open_float(nil, opts)
                    end,
                })
            end -- close if from higlights
        end --close of on_attach

        -- Base capabilities (no autocomplete-specific settings)
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- You could explicitly disable completion if you want, but by not setting any
        -- completion-related options, it should be effectively off from LSP side.
        -- capabilities.textDocument.completion = nil

        -- Define configurations for all LSP servers
        local servers_configs = {
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "None",
                        },
                        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                        diagnostics = {
                            disable = { "missing-fields" },
                            globals = { "vim" },
                        },
                    },
                },
            }, -- close lua_ls.setup

            gopls = {
                settings = {
                    gopls = {
                        staticcheck = true,
                        analyses = {
                            S1011 = true,
                            SA1014 = true,
                            SA4005 = true,
                            SA4006 = true,
                            SA4017 = true,
                            ST1003 = true, -- this is for variables and package name
                            ST1005 = true,
                        },
                    },
                },
            },

            pyright = {},

            jsonls = {
                filetypes = { "json", "jsonc" },
            },

            bashls = {},

            ts_ls = {},

            html = {},

            tailwindcss = {},

            cssls = {},

            -- Add more servers here if needed, following the same pattern
            -- e.g., tsserver = { ... }, html = { ... }, etc.
        }

        -- Loop through the server configurations and set them up
        for server_name, server_opts in pairs(servers_configs) do
            require("lspconfig")[server_name].setup(vim.tbl_deep_extend("force", {
                on_attach = on_attach,
                capabilities = capabilities,
            }, server_opts))
        end -- close loop of server configurations
    end, -- close config function
} -- close main return

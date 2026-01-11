-- Create a single augroup for all your LSP-related LspAttach configurations
-- This will ensure that when 'LspAttach' fires, previous autocommands for 'LspAttach'
-- within this group are cleared before new ones are set up, if you were to redefine it.
-- However, for the purpose of a global LspAttach handler, it's typically fine to just
-- have one 'LspAttach' autocmd. The 'LspDetach' logic will handle cleanup of per-buffer
-- autocmds.
local my_lsp_augroup = vim.api.nvim_create_augroup('myLsp', { clear = false })

-- The main LspAttach autocommand
vim.api.nvim_create_autocmd('LspAttach', {
  group = my_lsp_augroup,
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- Ensure we have a unique augroup for highlight-related autocmds per buffer
    -- This is crucial for cleanup when LspDetach occurs.
    local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight-" .. bufnr, { clear = true })

    -- Document Highlight
    if client:supports_method('textDocument/documentHighlight') then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        group = highlight_augroup, -- Use the per-buffer highlight augroup
        callback = function()
          vim.lsp.buf.document_highlight({ bufnr = bufnr })
        end,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = bufnr,
        group = highlight_augroup, -- Use the per-buffer highlight augroup
        callback = function()
          vim.lsp.buf.clear_references({ bufnr = bufnr })
        end,
      })
    end

    -- Open a floating window with diagnostics on CursorHold (independent of documentHighlight)
    vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        group = highlight_augroup, -- Optionally associate with highlight_augroup for easier cleanup
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

    -- LspDetach callback to clean up per-buffer autocommands
    -- This is critical. When an LSP client detaches from a buffer, we need to
    -- clear the autocommands we set up specifically for that buffer.
    vim.api.nvim_create_autocmd("LspDetach", {
        group = my_lsp_augroup, -- Use the main LSP augroup for the LspDetach handler itself
        buffer = bufnr, -- This LspDetach will only trigger for the specific buffer
        callback = function(event)
            -- Clear all references that might still be active
            vim.lsp.buf.clear_references({ bufnr = event.buf })
            -- Clear the per-buffer highlight augroup to remove its CursorHold/Moved autocmds
            vim.api.nvim_clear_autocmds({ group = "lsp-highlight-" .. event.buf, buffer = event.buf })
        end,
    })
  end,
})

-- The global enable calls for LSP servers remain outside, as they are part of
-- setting up which servers Neovim should *try* to attach.
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("pyright")
vim.lsp.enable("jsonls")
vim.lsp.enable("bashls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("superhtml")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("cssls")
vim.lsp.enable("clangd")

vim.lsp.enable("gopls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("jsonls")
vim.lsp.enable("pyright")
vim.lsp.enable("bashls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("superhtml")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("cssls")
vim.lsp.enable("clangd")

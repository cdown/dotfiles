local vimrc = vim.fn.stdpath("config") .. "/init_.vim"
vim.cmd.source(vimrc)

-- LSP

vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "single"
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = "single"
  }
)

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

local on_attach = function(client, bufnr)
  client.server_capabilities.semanticTokensProvider = nil

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

require('trouble').setup({
  auto_open = true,
  auto_close = true,
  fold_open = "v",
  fold_closed = ">",
  indent_lines = false,
  icons = {
    indent = {
      top           = "| ",
      middle        = "+-",
      last          = "`-",
      fold_open     = "> ",
      fold_closed   = "v ",
      ws            = "  ",
    },
    folder_closed   = "[ ] ",
    folder_open     = "[>] ",
  },
})

local nvim_lsp = require('lspconfig')
nvim_lsp.rust_analyzer.setup({
  on_attach = on_attach,
  cmd = { "rust-analyzer-root" },
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        enable = true,
        command = "clippy",
      },
    },
  },
})

require("lsp_lines").setup()
vim.diagnostic.config({
  virtual_text = false,
})

vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })

-- No bottom bar
vim.opt.laststatus = 0
vim.opt.ruler = true

-- Disable mouse support
vim.opt.mouse = ""

local vimrc = vim.fn.stdpath("config") .. "/init_.vim"
vim.cmd.source(vimrc)

local nvim_lsp = require('lspconfig')
nvim_lsp.rust_analyzer.setup { }

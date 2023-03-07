local vimrc = vim.fn.stdpath("config") .. "/init_.vim"
vim.cmd.source(vimrc)

require('packer').startup(function(use)
  use '~/.nvim/bundle/nvim-lspconfig'
end)

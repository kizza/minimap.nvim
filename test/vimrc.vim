source ./test/vimrc_without_plugin.vim

" Bootstrap
lua vim.uv = require("luv") -- this is somehow needed
lua require("minimap").setup({map = {width = 12}})

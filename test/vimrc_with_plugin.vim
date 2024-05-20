source ./test/vimrc.vim

" Bootstrap
lua vim.uv = require("luv") -- this is somehow needed
lua require("minimap").setup({width = 12, debounce = { build = 1, paint = 1}})

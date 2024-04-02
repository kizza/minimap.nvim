" Sensible defaults for tests
set nocompatible
set nobackup
set nowb
set noswapfile

" Include out plugin (ie. this project)
let s:plugin = expand('<sfile>:h:h')
execute 'set runtimepath+='.s:plugin

" Include plugin dependencies
execute 'set runtimepath+='.s:plugin.'/node_modules/nui'
execute 'set runtimepath+='.s:plugin.'/node_modules/gitsigns'

" Bootstrap
execute 'set runtimepath+='.s:plugin.'/test'
lua vim.uv = require("luv") -- this is somehow needed

" CD to test directory
execute 'cd '.s:plugin.'/test'

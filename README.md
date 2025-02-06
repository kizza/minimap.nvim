# Minimap.nvim

A lua rewrite of the _blazingly fast_ [minimap for vim](https://github.com/wfxr/minimap.vim), featuring live changes, git highlights and more!

## ✨ Features
- 👌 Built with lua
- ⚡️ Blazing-fast (see [benchmark](https://github.com/wfxr/code-minimap#benchmark)).
- 💡 Real-time buffer changes
- 🚦 Real-time git highlighting
- 🔎 Real-time search result highlighting
- 🏃‍➡️ Buffer navigation (via motions within the minimap)
- 💊 Functionally tested

## 🔌 Installation

Install the plugin with your preferred package manager.  Note [nui.nvim](https://github.com/MunifTanjim/nui.nvim) is used to create the minimap split, and [code-minimap](https://github.com/wfxr/code-minimap) to
(by default) to generate its contents.
```lua
-- lazy
{
  "kizza/minimap.vim",
  build = ":!cargo install --locked code-minimap",
  dependencies = {
    -- Uses nui to create map split
    "MunifTanjim/nui.nvim"
  }
}
```
<details><summary>Vim plug</summary>

```vim
" vim-plug
call plug#begin()
  Plug "kizza/minimap.vim", {'do': ':!cargo install --locked code-minimap'}
    " Uses nui to create map split
    Plug "MunifTanjim/nui.nvim"
call plug#end()

lua require("minimap").setup()
```
</details>

## ⚙️ Configuration

Minimap.nvim is be default configu
```lua
require("minimap").setup({
  width = 12,
  -- Minimap content generation
  builder = require("minimap.builtin.builders.code_minimap"),
  -- Minimap highlighting (executed in order)
  painters = {
    require("minimap.builtin.painters.viewport"),
    require("minimap.builtin.painters.cursor"),
    require("minimap.builtin.painters.gitsigns"),
    require("minimap.builtin.painters.search"),
  },
  -- Minimap behaviour
  behaviors = {
    require("minimap.builtin.behaviors.rebuild_map_when_buffer_changed"),
    require("minimap.builtin.behaviors.restore_previous_buffer"),
    require("minimap.builtin.behaviors.move_map_viewport"),
    require("minimap.builtin.behaviors.move_buffer_viewport"),
  },
  debounce = {
    build = 1000, -- Debounce between rebuilding content
    paint = 50, -- Debounce between repainting content
  },
  -- Won't open for these ignored buffers
  ignored = {
    buf_types = { "nofile", "nowrite", "quickfix", "terminal", "help", "prompt", "NvimTree" },
    file_types = { "diff", "fugitive", "fzf", "telescope", "gitrebase", "gitcommit", "NvimTree" },
  }
})
```

## 🦀 Rust backed

Defaults to building map contents with [code-minimap](https://github.com/wfxr/code-minimap) - a rust executable that's amazingly fast at generating a surprisingly decent
symbolized representation of even quite large files.

## 🤔 Philosophy

The original (and inspirational) [minimap.vim](https://github.com/wfxr/minimap.vim) is fantastic.  However, via the implications of vimscript, it's necessarily
jumping back-and-forward between the buffer and map.  This plugin leverages neovim's new apis so you never jump around.

Additionally, this plugin tries to remain open for extension - structured with explicit builders, painters and behaviours:
1. Builders, create the contents of the minimap ([code-minimap](https://github.com/wfxr/code-minimap) by default, but you can bring your own)
2. Painters, highlight the content using events and callbacks (includes cursor, viewport, git and search - but is easily extendible)
3. Behaviours, listen to different events and do things - such as scrolling viewports and such

It essentially tries to encapsulate (and abstract) the core buffer-mapping primitives - to build on top of it.

## 🎨 Highlights

The primary highlights are `MinimapNormal`, `MinimapCursorLine` and `MinimapViewport`.

Each painter introduces its own highlights, but with variants depending on whether it's the current cursor line, or within the viewport.
A util function is provided to assist with the contextual highlighting of overlapping contexts (eg. a changed git hunk, under the current cursor line)

```lua
local util = require("minimap.util")

-- Highlight applied for painter
vim.api.nvim_set_hl(0, "CustomHighlight", { fg = .., bg = ... })

-- When in cursor line, use above `fg`, but cursor `bg`
util.merge_hl_groups("CustomHighlightCursorLine", { fg = "CustomPainterHighlight", bg = "MinimapCursorLine" })

-- Similarly when within viewport, use painters `fg` but viewport `bg`
util.merge_hl_groups("CustomHighlightViewport", { fg = "CustomPainterHighlight", bg = "MinimapViewport" })
```

This means you can tailor your own painters via the configuration, you can include your own highlights using the helper function above, or you can write them all by hand.

The default builtin painter highlights to customise are `MinimapSearch` (for search), `MinimapAdded`, `MinimapChanged` and `MinimapRemoved` (for git)
```

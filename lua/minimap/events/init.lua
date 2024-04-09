local events = {
  BufferActive = "BufferActive",
  MinimapActive = "MinimapActive",
  RowChanged = "RowChanged",
  BufferChanged = "BufferChanged",
  Built = "Built",
  Repaint = "Repaint",

  BufEnter = "BufEnter",
  FileType = "FileType", -- To catch the resulting buffer when one is removed

  -- BufDelete = "BufDelete",
  BufUnload = "BufUnload",
  CmdLineLeave = "CmdLineLeave",
  CursorMoved = "CursorMoved",
  CursorMovedI = "CursorMovedI",
  InsertLeave = "InsertLeave",
  TextChanged = "TextChanged",
  TextChangedI = "TextChangedI",
  WinScrolled = "WinScrolled",
  VimResized = "VimResized",
}

return events

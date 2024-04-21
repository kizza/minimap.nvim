---@enum Event
local events = {
  BufferActive = "BufferActive",
  MinimapActive = "MinimapActive",
  MinimapClosed = "MinimapClosed",
  RowChanged = "RowChanged",
  BufferChanged = "BufferChanged",
  Built = "Built",
  Repaint = "Repaint",

  BufEnter = "BufEnter",
  BufLeave = "BufLeave",
  FileType = "FileType", -- To catch the resulting buffer when one is removed
  BufWinEnter = "BufWinEnter",

  -- BufDelete = "BufDelete",
  BufUnload = "BufUnload",
  CmdLineLeave = "CmdLineLeave",
  CursorMoved = "CursorMoved",
  CursorMovedI = "CursorMovedI",
  InsertLeave = "InsertLeave",
  TextChanged = "TextChanged",
  TextChangedI = "TextChangedI",
  WinClosed = "WinClosed",
  WinScrolled = "WinScrolled",
  VimResized = "VimResized",
}

return events

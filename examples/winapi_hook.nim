#====================================================================
#
#                   MinHook wrapper for Nim
#                   Copyright (C) 2020 Ward
#
#====================================================================

import minhook

proc MessageBox(hWnd: int, lpText: cstring, lpCaption: cstring, uType: int32): int32
  {.stdcall, dynlib: "user32", importc: "MessageBoxA".}

proc detour(hWnd: int, lpText: cstring, lpCaption: cstring, uType: int32): int32
  {.stdcall, minhook: MessageBox.} =

  result = MessageBox(hWnd, lpText, "Hook Enabled", uType)

when isMainModule:
  discard MessageBox(0, "", "Hook Disabled", 0)
  enableHook(MessageBox)
  discard MessageBox(0, "", "Hook Disabled", 0)

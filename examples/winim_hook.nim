#====================================================================
#
#                   MinHook wrapper for Nim
#                   Copyright (C) 2020 Ward
#
#====================================================================

import winim/lean, minhook

proc detour(hWnd: HWND, lpText: LPCWSTR, lpCaption: LPCWSTR, uType: UINT): int32
    {.stdcall, minhook: MessageBox.} =

  result = MessageBox(hWnd, lpText, "Hook Enabled", uType)

when isMainModule:
  MessageBox(0, "", "Hook Disabled", 0)
  enableHook(MessageBox)
  MessageBox(0, "", "Hook Disabled", 0)

# MinHook

MinHook is the minimalistic x86/x64 hooking library for windows.
http://www.codeproject.com/KB/winsdk/LibMinHook.aspx
https://github.com/TsudaKageyu/minhook

This module provides MinHook wrapper for nim, and also a `minhook` macro
to help the users writing the detour function in really easy way. For example:

```nim
import minhook

proc test_function(input: string): string =
  echo input
  return "output"

proc detour(input: string): string {.minhook: test_function.} =
  # Using {.minhook: target_name.} to write the detour function.
  # The hook will be created in disabled state.

  # Calling the trampoline function in detour function is in the same way
  # as calling the original function.

  echo "before detour"
  result = "modified " & test_function("modified " & input)
  echo "after detour"

when isMainModule:
  echo "--- Hook Disabled ---"
  echo test_function("input")

  enableHook(test_function) # or enableHook(AllHooks)

  echo "--- Hook Enabled ---"
  echo test_function("input")

```

Improts winim to create the Windows API hook:


```nim
import winim/lean, minhook

proc detour(hWnd: HWND, lpText: LPCWSTR, lpCaption: LPCWSTR, uType: UINT): int32
    {.stdcall, minhook: MessageBox.} =

  result = MessageBox(hWnd, lpText, "Hook Enabled", uType)

when isMainModule:
  MessageBox(0, "", "Hook Disabled", 0)
  enableHook(MessageBox)
  MessageBox(0, "", "Hook Disabled", 0)

```

Or use dynlib:

```nim
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
```

# License

## ﻿MinHook

[![License](https://img.shields.io/badge/License-BSD%202--Clause-orange.svg)](https://opensource.org/licenses/BSD-2-Clause)

Copyright (C) 2009-2017 Tsuda Kageyu.
All rights reserved.

## The wrapper module

Read license.txt for more details.

Copyright (c) 2020 Kai-Hung Chen, Ward. All rights reserved.

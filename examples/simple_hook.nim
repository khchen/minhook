#====================================================================
#
#                   MinHook wrapper for Nim
#                   Copyright (C) 2020 Ward
#
#====================================================================

import minhook
import test_module

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

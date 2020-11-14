#====================================================================
#
#                   MinHook wrapper for Nim
#                   Copyright (C) 2020 Ward
#
#====================================================================

# Separate the test procedure to avoid the inline optimization

proc test_function*(input: string): string =
  echo input
  return "output"

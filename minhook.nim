#====================================================================
#
#                   MinHook wrapper for Nim
#                   Copyright (C) 2020 Ward
#
#====================================================================

#====================================================================
#
#     ﻿MinHook - The Minimalistic API Hooking Library for x64/x86
#            Copyright (C) 2009-2017 Tsuda Kageyu.
#
#====================================================================

import macros

when (compiles do: import std/exitprocs):
  import std/exitprocs
  proc addQuitProc(cl: proc() {.noconv.}) = addExitProc(cl)

template atExit(body: untyped): untyped =
  addQuitProc proc () {.noconv.} =
    body

{.compile: "minhook/src/hook.c".}
{.compile: "minhook/src/buffer.c".}
{.compile: "minhook/src/trampoline.c".}

when defined(cpu64):
  {.compile: "minhook/src/hde/hde64.c".}
else:
  {.compile: "minhook/src/hde/hde32.c".}


type
  MhStatus* = enum
    mhUnknown = -1
    mhOk = 0
    mhErrorAlreadyInitialized
    mhErrorNotInitialized
    mhErrorAlreadyCreated
    mhErrorNotCreated
    mhErrorEnabled
    mhErrorDisabled
    mhErrorNotExecutable
    mhErrorUnsupportedFunction
    mhErrorMemoryAlloc
    mhErrorMemoryProtect
    mhErrorModuleNotFound
    mhErrorFunctionNotFound

const
  AllHooks* = nil

proc initialize(): MHStatus {.stdcall, importc: "MH_Initialize", discardable.}
proc uninitialize(): MHStatus {.stdcall, importc: "MH_Uninitialize", discardable.}
proc createHook*(pTarget: pointer, pDetour: pointer, ppOriginal: ptr pointer): MHStatus {.stdcall, importc: "MH_CreateHook", discardable.}
proc enableHook*(pTarget: pointer): MHStatus {.stdcall, importc: "MH_EnableHook", discardable.}
proc disableHook*(pTarget: pointer): MHStatus {.stdcall, importc: "MH_DisableHook", discardable.}
proc queueEnableHook*(pTarget: pointer): MHStatus {.stdcall, importc: "MH_QueueEnableHook", discardable.}
proc queueDisableHook*(pTarget: pointer): MHStatus {.stdcall, importc: "MH_QueueDisableHook", discardable.}
proc applyQueued*(): MHStatus {.stdcall, importc: "MH_ApplyQueued", discardable.}

template createHook*(pTarget: proc, pDetour: proc, ppOriginal: ptr proc): untyped =
  createHook(cast[pointer](pTarget), cast[pointer](pDetour), cast[ptr pointer](ppOriginal))

template enableHook*(pTarget: proc): untyped =
  enableHook(cast[pointer](pTarget))

template disableHook*(pTarget: proc): untyped =
  disableHook(cast[pointer](pTarget))

template queueEnableHook*(pTarget: proc): untyped =
  queueEnableHook(cast[pointer](pTarget))

template queueDisableHook*(pTarget: proc): untyped =
  queueDisableHook(cast[pointer](pTarget))

macro minhook*(target, def: untyped): untyped =
  let
    sym = genSym(nskVar, "trampoline")
    name = target.toStrLit
    procty = newTree(nnkProcTy, def.params, def.pragma)
    detour = def.name

  def.body.insert 0, quote do:
    var `target`: `procty` = `sym`

  result = quote do:
    var `sym`: `procty`
    `def`
    if createHook(`target`, `detour`, addr `sym`) != mhOk:
      raise newException(LibraryError, "Could not hook: " & `name`)

once:
  initialize()

atExit:
  uninitialize()

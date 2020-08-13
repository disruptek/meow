import hashes, strutils

import nimterop/[build, cimport]

const
  baseDir = getProjectCacheDir("meow")

static:
  gitPull(
    "https://github.com/cmuratori/meow_hash",
    outdir = baseDir
  )

const
  header = findFile("meow_hash_x64_aesni.h", baseDir)
  maxBuffer = 8192

static:
  let
    data = header.readFile()
  header.writeFile(data.multiReplace([
    ("int unsigned", "unsigned int"),
    ("long long unsigned", "unsigned long long"),
    ("char unsigned", "unsigned char")
  ]))

cOverride:
  type m128i {.importc: "__m128i", header: "emmintrin.h".} = object

cPassC("-O3 -mavx -maes")
cImport(header, flags = "-E__,_ -c")

type
  Meow* = m128i  ## meow hash operations use this type

proc meowHash*(x: cstring | string): Meow =
  result = MeowHash(addr MeowDefaultSeed, len(x).culonglong, x)

proc meowHash*(x: string): Meow =
  result = meowHash(x.cstring)

proc meowHash*[T](x: T): Meow =
  result = MeowHash(addr MeowDefaultSeed, sizeof(x).culonglong, x)

proc meowFile*(path: string): Meow =
  ## Create hash without loading entire file in memory like `MeowHash()`
  var
    state: meow_state
    buffer = newString(maxBuffer)
    f = open(path)
  MeowBegin(addr state, addr MeowDefaultSeed)

  while true:
    let bytesRead = readBuffer(f, addr buffer[0], maxBuffer)
    if bytesRead == maxBuffer:
      MeowAbsorb(addr state, culonglong(bytesRead), addr buffer[0])
    else:
      if bytesRead > 0:
        buffer.setLen(bytesRead)
        MeowAbsorb(addr state, culonglong(bytesRead), addr buffer[0])
      break

  result = MeowEnd(addr state, nil)

  f.close()

proc `==`*(a, b: Meow): bool =
  ## Compare two hashes for equality
  ({.emit: [
    result, " = MeowHashesAreEqual(", a, ", ", b, ");"
  ].})

converter toArray*(h: Meow): seq[uint32] =
  ## Split 128-bit hash into 4 uint32 values
  var s: uint32
  ({.emit: [s, " = MeowU32From(", h, ", 0);"].})
  result.add s
  ({.emit: [s, " = MeowU32From(", h, ", 1);"].})
  result.add s
  ({.emit: [s, " = MeowU32From(", h, ", 2);"].})
  result.add s
  ({.emit: [s, " = MeowU32From(", h, ", 3);"].})
  result.add s

proc `$`*(h: Meow): string =
  ## Convert hash into a string
  let arr: seq[uint32] = h
  for i in countDown(arr.high, arr.low):
    result &= toHex(arr[i])

proc hash*(x: Meow): Hash =
  ## Computes a Hash from `x` for table use
  var h: Hash = 0
  for i in items(x.toArray):
    h = h !& i.int
  result = !$h

when isMainModule:
  import os
  let
    params = commandLineParams()
  case params.len
  of 1:
    echo meowFile(params[0])
  of 2:
    echo meowFile(params[0]) == meowFile(params[1])
  else:
    echo "meow file1 [file2]"

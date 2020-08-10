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
  type m128i* {.importc: "__m128i", header: "emmintrin.h".} = object

cPassC("-O3 -mavx -maes")
cImport(header, flags = "-E__,_ -c")

proc MeowFile*(path: string): m128i =
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

proc MeowHashesAreEqual*(A, B: m128i): bool =
  ## Compare two hashes for equality
  ({.emit: [
    result, " = MeowHashesAreEqual(", A, ", ", B, ");"
  ].})

proc MeowHashToArray*(A: m128i): seq[uint32] =
  ## Split 128-bit hash into 4 uint32 values
  var s: uint32
  ({.emit: [s, " = MeowU32From(", A, ", 0);"].})
  result.add s
  ({.emit: [s, " = MeowU32From(", A, ", 1);"].})
  result.add s
  ({.emit: [s, " = MeowU32From(", A, ", 2);"].})
  result.add s
  ({.emit: [s, " = MeowU32From(", A, ", 3);"].})
  result.add s

proc `$`*(A: m128i): string =
  ## Convert hash into a string
  let arr = A.MeowHashToArray()
  for i in countdown(arr.high, 0):
    result &= toHex(arr[i])

proc hash*(x: m128i): Hash =
  ## Computes a Hash from `x` for table use
  var h: Hash = 0
  for i in x.MeowHashToArray():
    h = h !& i.int
  result = !$h

when isMainModule:
  import os
  let
    params = commandLineParams()
  case params.len
  of 1:
    echo MeowFile(params[0])
  of 2:
    echo MeowHashesAreEqual(MeowFile(params[0]), MeowFile(params[1]))
  else:
    echo "meow file1 [file2]"

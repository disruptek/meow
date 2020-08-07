import strutils

import nimterop/[build, cimport]

const
  baseDir = getProjectCacheDir("meow")

static:
  gitPull(
    "https://github.com/cmuratori/meow_hash",
    outdir = baseDir
  )
  cDebug()

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
      buffer.setLen(bytesRead)
      MeowAbsorb(addr state, culonglong(bytesRead), addr buffer[0])
      break

  result = MeowEnd(addr state, nil)

  f.close()

proc MeowHashesAreEqual*(A, B: m128i): bool =
  ({.emit: [
    result, "= MeowHashesAreEqual(", A, ", ", B, ");"
  ].})

proc MeowPrint*(x: m128i) =
  ({.emit: ["""
    printf("    %08X-%08X-%08X-%08X\n",
           MeowU32From(""", x, """, 3),
           MeowU32From(""", x, """, 2),
           MeowU32From(""", x, """, 1),
           MeowU32From(""", x, """, 0));
  """].})

when isMainModule:
  # Test for ascii file
  var
    hash1 = MeowFile("file1")
    data2 = readFile("file1").cstring
    hash2 = MeowHash(addr MeowDefaultSeed, culonglong(data2.len), data2)

  MeowPrint(hash1)
  MeowPrint(hash2)

  if MeowHashesAreEqual(hash1, hash2):
    echo "Equal"

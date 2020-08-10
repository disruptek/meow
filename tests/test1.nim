import meow

var
  hash1 = MeowFile(currentSourcePath)
  data2 = readFile(currentSourcePath).cstring
  hash2 = MeowHash(addr MeowDefaultSeed, culonglong(data2.len), data2)

echo hash1
echo hash2

doAssert MeowHashesAreEqual(hash1, hash2), "Hashing failed"
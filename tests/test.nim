import meow

var
  hash1 = meowFile(currentSourcePath)
  data2 = readFile(currentSourcePath).cstring
  hash2 = meowHash(data2)

echo hash1
echo hash2

doAssert hash1 == hash2, "Hashing failed"

assert meowHash("one two three") == meowHash("one two three".cstring)

# Package

version       = "0.1.0"
author        = "genotrance"
description   = "meowhash wrapper for Nim"
license       = "MIT"

bin = @["meow"]
installFiles = @["meow.nim"]

# Dependencies

requires "nimterop >= 0.6.8"

when gorgeEx("nimble path nimterop").exitCode == 0:
  import nimterop/docs
  task docs, "Generate docs":
    buildDocs(@["meow.nim"], "build/htmldocs")
else:
  task docs, "Do nothing": discard

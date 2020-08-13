# meow

meow is a [Nim](https://nim-lang.org/) wrapper for the [meow_hash](https://github.com/cmuratori/meow_hash) library.

`meow` is distributed as a [Nimble](https://github.com/nim-lang/nimble) package and depends on [nimterop](https://github.com/nimterop/nimterop) to generate the wrappers. The `meow_hash` source code is downloaded using Git so having ```git``` in the path is required.

## Installation

`meow` can be installed via [Nimble](https://github.com/nim-lang/nimble):

```
> nimble install meow
```

This will download and install `meow` in the standard Nimble package location, typically ~/.nimble. Once installed, it can be imported into any Nim program.

## Usage

Module documentation can be found [here](https://disruptek.github.io/meow/meow.html)

```nim
import meow

echo MeowFile("path/to/file")
```

## Credits

`meow` wraps the `meow_hash` source code and all licensing terms of [meow_hash](https://github.com/cmuratori/meow_hash/blob/master/LICENSE) apply to the usage of this package.

## Feedback

`meow` is a work in progress and any feedback or suggestions are welcome. It is hosted on [GitHub](https://github.com/disruptek/meow) with an MIT license so issues, forks and PRs are most appreciated.

## Documentation
See [the documentation for the meow module](https://disruptek.github.io/meow/meow.html) as generated directly from the source.

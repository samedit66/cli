# faketar

A single-command parser demonstration. It only prints the parsed parameters in a
fixed order; it never reads, writes, extracts, or creates files or archives.
All flags are independent, so even `-cxtvzjp` is accepted.

## Build

Requires `just` and either Gobo (`gec`, `GOBO`) or EiffelStudio (`ec`, `ISE_LIBRARY`).
Run from this directory:

```sh
just gobo

just eiffelstudio
```

The executable is `build/gobo/faketar` or `build/eiffelstudio/faketar`.

## Short-option rule

**The first option that takes a value consumes the entire remainder of its
short-option group and ends the group.** One leading `=` is removed as a
separator. Without a remainder, it consumes the next token, even if that token
starts with `-`. Characters in that value are never interpreted as flags.

| Input | Interpretation |
|---|---|
| `-cvz` | Flags `create`, `verbose`, `gzip` |
| `-cvzfarchive.tar` | Those flags and `file=archive.tar` |
| `-cvzf=archive.tar` | Same result |
| `-cvzf archive.tar` | Same result |
| `-fcvz` | `file=cvz`; no flags |
| `-f=` | Empty file value |
| `-f==name` | File value `=name` |
| `-b-3` | Integer blocking factor `-3` |
| `-vv` | Error: repeated flag |
| `-cv=yes` | Error: flag `verbose` does not accept a value |

## Usage

```sh
./build/gobo/faketar -cxtvzjpfarchive.tar -Ctmp -b=32 src README.md
./build/gobo/faketar -cvzf archive.tar -- -filename
./build/gobo/faketar -fcvz
./build/gobo/faketar --help
```

Flags: `-c/--create`, `-x/--extract`, `-t/--list`, `-v/--verbose`,
`-z/--gzip`, `-j/--bzip2`, `-p/--preserve`.
Options: `-f/--file` (default empty), `-C/--directory` (default `.`),
`-b/--blocking-factor` (default `20`). Remaining operands form the `paths` list.
Options may appear between operands. `--` ends option recognition except when
consumed as an option's value. Invalid input exits with code `2`.

## Verification

Build `greet`, `text`, and `faketar` with each compiler, then run from the repository root:

```sh
python3 tests/check_examples.py gobo eiffelstudio
```

Additional parser checks cover repeatable options, required values, negative
integer operands and numeric aliases. From `tests`, run `just gobo` and
`just eiffelstudio`; each recipe builds and executes these checks.

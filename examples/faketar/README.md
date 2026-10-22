# faketar

Demonstrates grouped short flags and repeated list options in a default command.
The handler prints parsed values in a fixed order without performing archive operations.

## Build

Run either recipe from this directory:

```sh
just gobo
just eiffelstudio
```

The executable is `build/gobo/faketar` or `build/eiffelstudio/faketar`.
See [building and verification](../../docs/development.md) for compiler setup and checks.

## Usage

```sh
./build/gobo/faketar -cxtvzjpf archive.tar -C tmp -b 32 src README.md
./build/gobo/faketar -cvzf archive.tar -- -filename
./build/gobo/faketar -cvzf=-archive.tar -b=-3
./build/gobo/faketar -vX tmp -X cache -K 1 -K 2
```

Use `build/eiffelstudio/faketar` for the EiffelStudio build.

## Interface

The flags `-c`, `-x`, `-t`, `-v`, `-z`, `-j`, and `-p` are independent and may be
grouped. An option taking a value must end the group: `-cvzf archive.tar` and
`-cvzf=archive.tar` set three flags and the file value. Inline values require `=`;
`-farchive.tar` is unsupported. See the [short-option rules](../../docs/syntax.md#named-options).

`--file` (`-f`) defaults to an empty string, `--directory` (`-C`) to `.`, and
`--blocking-factor` (`-b`) to `20`. Repeat `--exclude` (`-X`) for string values or
`--checkpoint` (`-K`) for integers. Both lists default to empty. Positional values
form the `paths` list, which also defaults to empty.

See [FAKETAR_COMMAND](src/faketar_command.e) for the declarations and handler, and
[FAKETAR_APPLICATION](src/faketar_application.e) for registration with `CLI_APPLICATION`.

# text

Demonstrates named commands, positional lists, integer options, and generated help.
The application registers `join`, `repeat`, and the library's `help` command.

## Build

Run either recipe from this directory:

```sh
just gobo
just eiffelstudio
```

The executable is `build/gobo/text` or `build/eiffelstudio/text`.
See [building and verification](../../docs/development.md) for compiler setup and checks.

## Usage

```sh
./build/gobo/text join hello world                  # hello world
./build/gobo/text join hello world -us -            # HELLO-WORLD
./build/gobo/text repeat hello --count 2 --prefix "> "
# > hello
# > hello

./build/gobo/text help
./build/gobo/text help repeat
```

Use `build/eiffelstudio/text` for the EiffelStudio build.

## Interface

`join` requires at least one word. `--separator` (`-s`) defaults to a space, and
`--upper` (`-u`) uppercases the joined text. See [JOIN_COMMAND](src/join_command.e).

`repeat` requires text and `--count` (`-n`). The count must be nonnegative; zero
prints nothing. `--prefix` (`-p`) defaults to an empty string. `--upper` (`-u`)
uppercases the text while preserving the prefix. See [REPEAT_COMMAND](src/repeat_command.e).

[TEXT_APPLICATION](src/text_application.e) registers `CLI_HELP_COMMAND` explicitly.
It has no default command, so empty input is an error. See
[help](../../docs/usage.md#help) for registration and
[command-line syntax](../../docs/syntax.md) for parsing rules.

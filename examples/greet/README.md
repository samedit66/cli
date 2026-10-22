# greet

Demonstrates a default command with a positional argument, a string option, and
a flag. The command has an empty name, so input is accepted without a command prefix.

## Build

Run either recipe from this directory:

```sh
just gobo
just eiffelstudio
```

The executable is `build/gobo/greet` or `build/eiffelstudio/greet`.
See [building and verification](../../docs/development.md) for compiler setup and checks.

## Usage

```sh
./build/gobo/greet --help
./build/gobo/greet                       # Hello, world!
./build/gobo/greet Alice                 # Hello, Alice!
./build/gobo/greet Alice --prefix Hi      # Hi, Alice!
./build/gobo/greet Alice --prefix=--Hi    # --Hi, Alice!
./build/gobo/greet Alice -yp Hi           # HI, ALICE!
./build/gobo/greet Alice -yp=Hi           # HI, ALICE!
./build/gobo/greet -- -Alice              # Hello, -Alice!
```

Use `build/eiffelstudio/greet` for the EiffelStudio build.

## Interface

`name` defaults to `world`; `--prefix` (`-p`) defaults to `Hello`.
`--yell` (`-y`) uppercases the complete greeting. An extra positional value is an
error. This command does not declare a `help` flag.

See [GREET_COMMAND](src/greet_command.e) for the declarations and handler, and
[GREET_APPLICATION](src/greet_application.e) for registration with `CLI_APPLICATION`.
The [syntax guide](../../docs/syntax.md) defines the parsing rules.

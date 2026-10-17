# greet

A single-command application. Its name and description come from `GREET_COMMAND`.
Arguments, options, and flags are accepted directly, without a subcommand name.

## Build

Requires `just` and either Gobo (`gec`, `GOBO`) or EiffelStudio (`ec`, `ISE_LIBRARY`).
Run from this directory:

```sh
just gobo

just eiffelstudio
```

## Usage

```sh
./build/gobo/greet                         # Hello, world!
./build/gobo/greet Alice                   # Hello, Alice!
./build/gobo/greet Alice --yell            # HELLO, ALICE!
./build/gobo/greet Alice -p Hi -y          # HI, ALICE!
./build/gobo/greet --help                  # Generated help
./build/gobo/greet help                    # Hello, help!
./build/gobo/greet -- --help               # Hello, --help!
./build/gobo/greet --prefix --help Alice   # --help, Alice!
```

The application adds an ordinary `help` flag to the command parameters when no
parameter named `help` exists. An existing parameter with that name is handled by
the command instead. Generated help bypasses required-parameter validation, but
unknown options and invalid values still fail anywhere in the input. After `--`,
`--help` is an argument; when consumed by an option, it is that option's value.
Invalid input exits with code `2`.

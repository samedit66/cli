<div align="center">

# cli

[![ISE Eiffel](https://img.shields.io/badge/toolchain-ISE%20Eiffel-17365D)](https://www.eiffel.com/)
[![Gobo Eiffel](https://img.shields.io/badge/toolchain-Gobo%20Eiffel-8B5A2B)](https://www.gobosoft.com/)

A small Eiffel library for defining command-line arguments, options, and flags declaratively.

Void-safe and ELKS-only, with support for both EiffelStudio and Gobo.

Inspired by Python's [Cleo](https://github.com/python-poetry/cleo).

</div>

## Highlights

- Describe your commands; let cli handle the arguments 💅
- Typed values and lists with explicit defaults 🎯
- Automatically generated application and command help 📖

## Installation

From your project's root directory:

```sh
git clone https://github.com/samedit66/cli.git vendor/cli
```

Add the library to your application's ECF target:

```xml
<library name="cli" location="vendor/cli/cli.ecf"/>
```

Set `GOBO_EIFFEL=ge` to use Gobo's FreeELKS via `GOBO`; otherwise, the library uses EiffelBase via `ISE_LIBRARY`.

## Usage

Define a command in `hello_command.e`:

```eiffel
class
    HELLO_COMMAND

inherit
    CLI_COMMAND

feature -- Metadata

    name: STRING_32 = "hello"

    description: STRING_32 = "Greet someone"

feature -- Command interface

    interface
        do
            add_optional_string_argument ("name", "Person to greet", "world")
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
        do
            io.put_string_32 (
                {STRING_32} "Hello, " + a_input.string_parameter ("name") + "!%N"
            )
        end

end
```

Register the command in your application's entry point, `application.e`:

```eiffel
class
    APPLICATION

create
    make

feature {NONE} -- Initialization

    make
        local
            application: CLI_APPLICATION
        do
            create application.make ("tool", "My simple tool")
            application.add_command (create {HELLO_COMMAND})
            application.run
        end

end
```

Compile the application. Assuming the executable is named `application`, run:

```sh
./application hello             # Prints: Hello, world!
./application hello samedit66   # Prints: Hello, samedit66!
./application help              # Shows automatically generated application help
./application help hello        # Shows automatically generated command help
```

`run` reads process arguments through `ARGUMENTS_32`. Use `run_with_tokens` to
pass tokens explicitly; omit the executable name. See
[CLI_APPLICATION](src/cli_application.e).

See the [text example](examples/text/README.md) for `join` and `repeat` commands
and builds with EiffelStudio or Gobo.

## Single-command applications

Suppose you have a `greet` command:

```eiffel
class
    GREET_COMMAND

inherit
    CLI_COMMAND

feature -- Metadata

    name: STRING_32 = "greet"

    description: STRING_32 = "Greet someone"

feature -- Command interface

    interface
        do
            add_optional_string_argument ("name", "Person to greet", "world")
            add_optional_string_option ("prefix", "Greeting prefix", "Hello")
            set_short_name ("prefix", 'p')
            add_flag ("yell", "Print the greeting in uppercase")
            set_short_name ("yell", 'y')
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
        local
            l_greeting: STRING_32
        do
            l_greeting := a_input.string_parameter ("prefix") + ", " +
                a_input.string_parameter ("name") + "!"
            if a_input.boolean_parameter ("yell") then
                l_greeting.to_upper
            end
            io.put_string_32 (l_greeting + "%N")
        end

end
```

Use `CLI_SINGLE_COMMAND_APPLICATION` to run one command directly:

```eiffel
class
    APPLICATION

create
    make

feature {NONE} -- Entry point

    make
        local
            application: CLI_SINGLE_COMMAND_APPLICATION
        do
            create application.make (create {GREET_COMMAND})
            application.run
        end

end
```

Assuming the executable is named `application`, run: `./application Alice --yell`.
`--help` is generated automatically unless the command defines its own `help` parameter.
See the [greet example](examples/greet/README.md) for setup, build, and usage instructions.

## Design

`cli` uses a simple model: a [CLI_APPLICATION](src/cli_application.e) contains
[CLI_COMMAND](src/cli_command.e) objects. Each application has a name, a
description, and a set of commands. Each command declares its positional
arguments, named options, and flags in `interface`.

| Parameter | Declaration | Input | Value access |
|---|---|---|---|
| Positional argument | `add_string_argument` | `Alice` | `string_parameter` |
| Named option | `add_integer_option` | `--port 8080` | `integer_parameter` |
| Flag | `add_flag` | `--verbose` | `boolean_parameter` |
| Positional list | `add_string_list_argument` | `a.txt b.txt` | `string_list_parameter` |
| Repeatable option | `add_integer_list_option` | `--port 8080 --port 8081` | `integer_list_parameter` |

Arguments and options support integers, strings, and lists of either type.
Use `add_optional_*` with an explicit default to make them optional. Flags are
`False` when absent. Use `set_short_name ("port", 'p')` to add `-p` as an alias.

After a successful parse, the application passes a typed
[CLI_COMMAND_INPUT](src/cli_command_input.e) to `handle`. Parsing errors are
reported before the handler is called.

See [CLI_COMMAND](src/cli_command.e) for parameter declarations and
[CLI_COMMAND_INPUT](src/cli_command_input.e) for typed value access.

## Errors

Invalid commands or arguments print an error to standard error and exit with
code `2`. This applies to both `run` and `run_with_tokens`.

Use `fail` inside `handle` to print an error and stop the program immediately:

```eiffel
handle (a_input: CLI_COMMAND_INPUT)
    local
        count: INTEGER
    do
        count := a_input.integer_parameter ("count")
        if count < 0 then
            fail ("Count must be zero or greater.", Invalid_call)
        end
        -- Continue only when count is valid.
    end
```

`CLI_COMMAND` provides two numeric exit-code constants:

- `Command_error = 1`: the command could not complete its work.
- `Invalid_call = 2`: the command or its arguments are invalid.

`fail` requires a nonzero code. It exits without raising an exception or
running `rescue`; any work already done is not undone.

## Syntax and limits

- With `CLI_APPLICATION`, the first token selects a command; there are no global options or nested commands.
- An option consumes exactly one following token, even if it starts with `-`.
- `--` ends option recognition when encountered outside an option's value.
- Required positional arguments precede optional ones. A positional list must be last.
- Required lists need at least one value. Only list options may be repeated.
- **Not currently supported**: `--name=value`, `-nvalue`, combined flags such as `-abc`, and comma-separated lists.
- Boolean-valued options and boolean lists are **not supported**; use flags instead.

## License

Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

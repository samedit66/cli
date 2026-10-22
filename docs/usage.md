# Classes and usage

Declare a command's parameters, register the command with an application, and
read the parsed values in its handler. The application selects a command and
calls its handler only after parsing succeeds.

| Class | Responsibility |
|---|---|
| [CLI_COMMAND](../src/cli_command.e) | Declare a command and handle its input |
| [CLI_APPLICATION](../src/cli_application.e) | Register commands, select one, and execute it |
| [CLI_PARAMETER](../src/cli_parameter.e) | Describe a parameter's kind, type, and default |
| [CLI_COMMAND_INPUT](../src/cli_command_input.e) | Provide typed values to the handler |
| [CLI_PARSER](../src/cli_parser.e) | Parse tokens against parameter definitions |
| [CLI_HELP_COMMAND](../src/cli_help_command.e) | Expose generated help as an ordinary command |
| [CLI_STRING_ROUTINES](../src/cli_string_routines.e) | Split parsed strings explicitly |
| [CLI_FAILURE](../src/cli_failure.e) | Report a fatal diagnostic and terminate the process |

The source files define the feature signatures and contracts. The
[syntax guide](syntax.md) defines the command-line grammar.

## Commands and parameters

Inherit `CLI_COMMAND`, define `name` and `description`, declare parameters in
`interface`, and implement `handle`. Registration calls `interface`; application
code does not need to call it separately. See the
[greet command](../examples/greet/src/greet_command.e) for a complete definition.

| Parameter | Declaration | Input | Value access |
|---|---|---|---|
| Positional argument | `add_string_argument` | `Alice` | `string_parameter` |
| Named option | `add_integer_option` | `--port 8080` | `integer_parameter` |
| Flag | `add_flag` | `--verbose` | `boolean_parameter` |
| Positional list | `add_string_list_argument` | `a.txt b.txt` | `string_list_parameter` |
| Repeated list option | `add_integer_list_option` | `--port 8080 --port 8081` | `integer_list_parameter` |

Arguments and options support strings, 32-bit integers, and lists of either type.
Use `add_optional_*` with an explicit default for optional parameters.
Use `set_short_name ("port", 'p')` to assign a one-letter alias.
The [parameter rules](syntax.md#parameter-definitions) cover declaration order,
unique names, and positional lists. The [defaults rules](syntax.md#defaults-and-completion)
cover absent parameters and replacement of list defaults.

The handler receives `CLI_COMMAND_INPUT`. Its typed queries require a value of
the corresponding type. Use `has_parameter` or a type-specific `has_*_parameter`
query when checking for a value. String and list queries return copies, so
changing the returned data does not change the stored input.

## Applications

`CLI_APPLICATION.make` takes the application name and description. Register each
command with `add_command`, then call `run`. It reads process arguments through
`ARGUMENTS_32`. Use `run_with_tokens` to provide tokens directly, excluding the
executable name. See the [text application](../examples/text/src/text_application.e).

A command with `name = ""` accepts input without a command prefix. An application
with only that command behaves as a single-command utility:

```eiffel
create command
create application.make ("greet", command.description)
application.add_command (command)
application.run
```

Here, `command` is a `GREET_COMMAND` whose name is empty. The complete entry point
is in [greet_application.e](../examples/greet/src/greet_application.e).

Command names may also contain several words. An empty command can coexist with
named commands to provide parameters for root invocations. See
[command selection](syntax.md#command-selection) for matching and precedence,
and the [arc example](../examples/arc/README.md) for declarations and invocations.

## Help

Help text is generated from registered parameter definitions:

| Query | Result |
|---|---|
| `application.help` | Application overview with the registered commands |
| `application.command_help ("pack")` | Parameter help for a named command |
| `application.command_help ("")` | Parameter help for the default command |
| `command.help (invocation)` | Parameter help using an explicit invocation string |

`command_help` requires the requested command to be registered.
`application.show_help (name)` prints the application overview when `name` is
empty; otherwise it prints the named command's help or reports an unknown command.

To make help available from the command line, register `CLI_HELP_COMMAND`:

```eiffel
application.add_command (create {CLI_HELP_COMMAND}.make (application))
```

This adds a command named `help`, not a `--help` flag. It accepts command words,
such as `tool help remote add`. The
[text application](../examples/text/src/text_application.e) demonstrates registration.
Applications do not add a help flag or display help implicitly. A flag named
`help` follows the same parsing and required-parameter rules as any other flag.

## Errors

`run` and `run_with_tokens` report invalid commands or arguments to standard error
and exit with code `2`. The handler is not called when parsing fails.

For validation inside a handler, call the inherited `fail` feature:

```eiffel
count := a_input.integer_parameter ("count")
if count < 0 then
    fail ("Count must be zero or greater.", Invalid_call)
end
```

See [repeat_command.e](../examples/text/src/repeat_command.e) for the complete handler.
`CLI_COMMAND` defines `Command_error = 1` for execution failures and
`Invalid_call = 2` for invalid input. `fail` requires a nonzero exit code and
terminates the process immediately. It does not raise an exception, run `rescue`,
or undo earlier work.

## Direct parsing

Use `CLI_PARSER` when command selection and process handling are managed elsewhere.
Pass an iterable of `CLI_PARAMETER` definitions to `make` and a
`READABLE_INDEXABLE [STRING_32]` of input tokens to `parse`:

```eiffel
create parser.make (parameters)
parser.parse (tokens)
if parser.is_successful then
    values := parser.values
else
    message := parser.error_message
end
```

Tokens exclude the executable and command prefix. Definitions must remain
unchanged until parsing finishes. The parser reads tokens without retaining or
changing them. Each parser accepts one `parse` call; create another parser for
another input.

The parser performs no I/O. `values` is available only after a complete successful
parse. On failure, `error_message` returns the diagnostic. There is no separately
exposed partial result or required-parameter validation call.

The main loop handles one input token per iteration. Its states are explicit;
short groups use an inner loop over letters:

```mermaid
stateDiagram-v2
    [*] --> Reading_parameters
    Reading_parameters --> Reading_parameters: positional value, flags, or inline value
    Reading_parameters --> Expecting_option_value: option without an inline value
    Expecting_option_value --> Reading_parameters: one non-option-like value token
    Reading_parameters --> Reading_positionals: separator --
    Reading_positionals --> Reading_positionals: positional value
    Reading_parameters --> [*]: end of input and complete values
    Reading_positionals --> [*]: end of input and complete values
    Expecting_option_value --> Error: option-like token or end of input
```

Any state can fail on invalid input. Completeness checks and defaults are part of
the same `parse` call. See [CLI_PARSER](../src/cli_parser.e) for the loop and transitions.

## Explicit splitting

`CLI_STRING_ROUTINES.split` splits a parsed string on a chosen character:

```eiffel
create routines
parts := routines.split ("a,,b", ',')
```

The result contains `"a"`, `""`, and `"b"`. Whitespace and empty parts are preserved;
empty input produces one empty part. Quotes and escape characters have no special
meaning. The helper returns strings and does not perform numeric conversion.
Use it in a handler when that command wants delimited values. It does not change
the parser's [list-option syntax](syntax.md#named-options).

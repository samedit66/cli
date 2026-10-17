# Command-line syntax

## Commands and parameters

With `CLI_APPLICATION`, the first token selects a command. With
`CLI_SINGLE_COMMAND_APPLICATION`, tokens are passed directly to its command.

Required positional arguments precede optional ones. A positional list must be
last. Required lists need at least one value. Parameter names cannot contain
spaces or `=`, or start with `-`.

## Named options

| Form | Example |
|---|---|
| Long name with a separate value | `--file archive.tar` |
| Long name with `=` | `--file=archive.tar` |
| Short name with a separate value | `-f archive.tar` |
| Short name with `=` | `-f=archive.tar` |
| Short name with an attached value | `-farchive.tar` |
| Combined short flags | `-cvz` means `-c -v -z` |

An option without an attached value consumes exactly one following token, even
if it starts with `-`. For example, `--file --help` sets `file` to `--help`.

Only the first separator `=` is removed: `--file=a=b` sets `file` to `a=b`, and
`-f==name` sets it to `=name`. An explicit value may be empty: `--file=` or `-f=`.
Flags do not accept values: `--verbose=true` and `-v=yes` are errors.

Only list options may be repeated. Repeating a scalar option or a flag, including
`-vv`, is an error. Lists use repeated options, such as `--port 80 --port 81`;
commas are not treated as list separators.

## Short-option groups

**The first option that takes a value consumes the entire remainder of the
token and ends the group.** One leading `=` is removed as a separator. If there
is no remainder, the option consumes the next token.

Assuming `c`, `v`, and `z` are flags and `f` takes a string value:

| Input | Interpretation |
|---|---|
| `-cvzfarchive.tar` | Flags `c`, `v`, `z`; `file=archive.tar` |
| `-cvzf=archive.tar` | Same result |
| `-cvzf archive.tar` | Same result |
| `-fcvz` | `file=cvz`; no flags |

Unknown short options and repeated flags are errors anywhere in a group.
Groups require a leading dash; `cvzf` is an ordinary positional value.

See [faketar](../examples/faketar/README.md) for a runnable demonstration that
only reports parsed values and never operates on files or archives.

## Ending option recognition

`--` ends option recognition when encountered outside an option's value.
For example, `-- -cvz` passes `-cvz` as a positional value, whereas `-f --`
sets `file` to `--`.

Negative integer operands do not require `--` when the next positional parameter
is integer-valued. An exact numeric short alias, such as `-1`, takes priority
when defined. Otherwise, a token beginning with a minus and a digit is parsed as
a positional integer in that context and must be a valid 32-bit integer.

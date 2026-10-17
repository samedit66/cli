# text

A small CLI example with two commands: `join` and `repeat`.
Demonstrates string lists, integer and string parameters, explicit defaults,
short option names, flags, and generated help.

## Build

Run from this directory. Requires [just](https://just.systems/) and either
EiffelStudio (`ec`, `ISE_LIBRARY`) or Gobo (`gec`, `GOBO`).

```sh
just eiffelstudio
just gobo
```

Executables: `build/eiffelstudio/text` and `build/gobo/text`.
Each recipe selects the standard library through `GOBO_EIFFEL`.

## Usage

```sh
./build/gobo/text join hello world
# hello world

./build/gobo/text join hello world -s "-" -u
# HELLO-WORLD

./build/gobo/text repeat hello --count 3 --prefix "> "
# > hello
# > hello
# > hello

./build/gobo/text help
./build/gobo/text help join
./build/gobo/text help repeat
```

Use `build/eiffelstudio/text` for the EiffelStudio build.
`repeat` requires a nonnegative count; zero prints nothing. `--upper` changes
only the repeated text, preserving the prefix. Invalid input exits with code `2`.
Use `--` before positional values that start with `-`.

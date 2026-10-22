# arc

Demonstrates root flags and multiword command names using an interface based on
[samedit66/arc](https://github.com/samedit66/arc). The handlers report parsed values
without performing archive operations. The example has no arc or libarchive dependency.

## Build

Run either recipe from this directory:

```sh
just gobo
just eiffelstudio
```

The executable is `build/gobo/arc` or `build/eiffelstudio/arc`.
See [building and verification](../../docs/development.md) for compiler setup and checks.

## Usage

```sh
./build/gobo/arc --version
./build/gobo/arc --help --version
./build/gobo/arc pack --keep-root project.zip ./src ./README.md
./build/gobo/arc pack --password=--keep-root project.zip
./build/gobo/arc unpack --strip-root --entry docs --entry notes.txt project.zip ./out
./build/gobo/arc list --tree project.zip
./build/gobo/arc list tree project.zip
./build/gobo/arc info project.zip
./build/gobo/arc verify project.zip
./build/gobo/arc help list tree
```

Use `build/eiffelstudio/arc` for the EiffelStudio build.

## Interface

The archive commands follow arc's [CLI declarations](https://github.com/samedit66/arc/blob/main/src/cli/main.c).
This example adds `list tree` as a multiword alternative to `list --tree` and
registers the library's `help` command.

```text
arc [--help] [--version]
arc pack [--format FORMAT] [--keep-root] [--password VALUE] ARCHIVE [SOURCE...]
arc unpack [--strip-root] [--entry PATH]... [--password VALUE] ARCHIVE [DESTINATION]
arc list [--tree] [--password VALUE] ARCHIVE
arc list tree [--password VALUE] ARCHIVE
arc info [--password VALUE] ARCHIVE
arc verify [--password VALUE] ARCHIVE
arc help [COMMAND WORDS...]
```

[ARC_ROOT_COMMAND](src/arc_root_command.e) has an empty name and declares `help`
and `version` as ordinary flags. Its handler reports their Boolean values;
empty input reports both as `False`. Use `arc help` for generated help text.
Root flags apply only to root invocations. For example, `arc pack --version file.zip`
is an unknown-option error, while `arc --help pack` stays at the root and reports
an unexpected positional argument.

Both [ARC_LIST_COMMAND](src/arc_list_command.e) and
[ARC_LIST_TREE_COMMAND](src/arc_list_tree_command.e) are registered:

```sh
./build/gobo/arc list tree project.zip  # Selects list tree; archive is project.zip
./build/gobo/arc list -- tree          # Selects list; archive is tree
./build/gobo/arc list tree             # Missing required parameter: archive
```

The last invocation does not fall back to `list`. See
[command selection](../../docs/syntax.md#command-selection) for the matching rules.

The [pack](src/arc_pack_command.e), [unpack](src/arc_unpack_command.e),
[info](src/arc_info_command.e), and [verify](src/arc_verify_command.e) classes
contain the remaining declarations. Unset string options and the optional
destination default to empty strings; source and entry lists default to empty.
Passwords are reported only as `password-set=True/False`. Paths, formats, and
destinations are not resolved or checked by these handlers.

[ARC_APPLICATION](src/arc_application.e) registers all commands. The example uses
this library's [syntax](../../docs/syntax.md), including `--option value` and
`--option=value`, options between positional values, and repeated `--entry` options.
For example, `arc pack --password --keep-root project.zip` reports a missing
password. The inline form `--password=--keep-root` passes that literal value
without setting the `keep-root` flag.

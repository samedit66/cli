# Repository guide

`cli` is a small, void-safe Eiffel library for declaring command-line interfaces.
Commands define parameters and receive typed values after successful parsing.
Support both EiffelStudio (EiffelBase) and Gobo (FreeELKS); keep library code
within their shared ELKS subset.

A CLI program uses one `CLI_APPLICATION`; commands are registered with that
application. Do not design around sharing commands between applications.
Command names are declarative metadata and keep the same value after registration.
Use concise `STRING_32` constants for fixed command names.

## File map

- `src/`: library classes. `CLI_COMMAND` declares interfaces;
  `CLI_PARAMETER` holds definitions; `CLI_PARSER` consumes tokens and produces
  `CLI_COMMAND_INPUT`; `CLI_APPLICATION` selects and runs commands, including
  automatic help. `CLI_HELP_COMMAND` is an explicitly registered help command.
- `cli.ecf`: library configuration and compiler-specific base-library selection.
- `examples/{greet,text,faketar,arc}/`: runnable applications, each with a README,
  ECF target, `justfile`, and `src/` directory. `arc` demonstrates an archive-tool
  interface without implementing archive operations.
- `tests/src/`: assertion-enabled parser tests and command-routing fixtures.
- `tests/check_examples.py`: integration checks for built examples and tests.
- `docs/`: detailed usage, syntax, and build instructions.

## Read and update documentation

Read the relevant document before changing the behavior it describes. Update it
in the same change when its instructions or examples become inaccurate.

- [README.md](README.md): introduction, installation, quick start, and navigation.
  Keep it concise; link to detailed documentation rather than duplicating it.
- [docs/usage.md](docs/usage.md): class responsibilities, public APIs, and usage.
  Update for interface and application-lifecycle changes; source contracts define
  exact feature signatures and obligations.
- [docs/syntax.md](docs/syntax.md): command selection, accepted token forms,
  defaults, help precedence, and errors. Update for grammar or parsing changes.
- [docs/development.md](docs/development.md): toolchain setup, builds, and checks.
  Update when configurations or verification commands change.
- `examples/*/README.md`: each example's interface, build commands, and invocations.
  Keep these synchronized with the corresponding source and integration checks.

## Eiffel source documentation

- Start every Eiffel class, including examples and tests, with a `note` clause.
  Include a short `description`, `author`, and `email`, in that order. Describe
  the role of the instances; use established author details rather than guessing.
- Add `copyright` and `license` only when the ownership and license are known.
  Do not add manually maintained `date` or `revision` fields; Git records history.
- Give every public feature and creation procedure a short English header comment.
  Cover selectively exported features too. Document redefinitions where they are
  declared, even when the inherited feature already has a comment.
- Use an imperative sentence for a command, a noun phrase for a value query,
  and a question for a Boolean query. Keep the existing feature-section style.
- Describe purpose and material usage rules, including result ownership,
  availability, and defaults. Keep exact obligations in contracts; do not repeat
  the implementation or use a help-text attribute as its own documentation.
- Update source comments and class descriptions when their meaning changes.
  Keep them consistent with the usage and syntax guides.

## Editing and verification

- Keep code comments and documentation in English. Preserve Eiffel contracts,
  command-query separation, void safety, and caller-owned input.
- Keep parser transitions explicit. Command selection and automatic help belong
  to the application; the parser handles parameter definitions and tokens.
- Add focused regression coverage for changed behavior. Do not edit generated
  `build/`, `EIFGENs/`, or `.gobo/` contents.
- For library changes, build all four examples and `tests/` with `just gobo` and
  `just eiffelstudio` in each directory. Then run
  `python3 tests/check_examples.py` from the repository root. The script does not
  build executables; rebuild after source changes before trusting its results.
- Run `GOBO_EIFFEL=ge gelint --flat tests/cli_tests.ecf` and
  `GOBO_EIFFEL=ge gelint --flat examples/arc/arc.ecf` for Eiffel changes.
- For documentation changes, check local links, anchors, and affected invocation
  examples. Preserve blank lines around the README's centered HTML header.
- Run `git diff --check` before finishing. Report checks actually run and any
  unavailable compiler or verification step.

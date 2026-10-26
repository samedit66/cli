"""Check built examples and tests: python3 tests/check_examples.py [gobo|eiffelstudio ...]."""

from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def faketar_output(flags=(), file="", directory=".", blocking_factor=20, paths=(), exclude=(), checkpoint=()):
    names = ("create", "extract", "list", "verbose", "gzip", "bzip2", "preserve")
    return (
        "".join(f"{name}={name in flags}\n" for name in names)
        + f"file={file}\ndirectory={directory}\nblocking-factor={blocking_factor}\npaths:\n"
        + "".join(f"  {path}\n" for path in paths)
        + "exclude:\n" + "".join(f"  {pattern}\n" for pattern in exclude)
        + "checkpoint:\n" + "".join(f"  {number}\n" for number in checkpoint)
    )


def routing_output(command="", verbose=False, help=False, count=7, arguments=(), tags=("default",), checkpoints=(8, 9), root_only=False):
    return (
        f"command={command}\nverbose={verbose}\nhelp={help}\ncount={count}\n"
        + (f"root-only={root_only}\n" if command == "" else "")
        + "arguments:\n" + "".join(f"  {value}\n" for value in arguments)
        + "tags:\n" + "".join(f"  {value}\n" for value in tags)
        + "checkpoints:\n" + "".join(f"  {value}\n" for value in checkpoints)
    )


def arc_pack_output(archive, sources=(), format="", keep_root=False, password_set=False):
    return (
        f"command=pack\narchive={archive}\nformat={format}\nkeep-root={keep_root}\n"
        + f"password-set={password_set}\nsources:\n"
        + "".join(f"  {source}\n" for source in sources)
    )


def arc_unpack_output(archive, destination="", entries=(), strip_root=False, password_set=False):
    return (
        f"command=unpack\narchive={archive}\ndestination={destination}\nstrip-root={strip_root}\n"
        + f"password-set={password_set}\nentries:\n"
        + "".join(f"  {entry}\n" for entry in entries)
    )


def arc_read_output(command, archive, tree=None, password_set=False):
    return (
        f"command={command}\narchive={archive}\n"
        + (f"tree={tree}\n" if tree is not None else "")
        + f"password-set={password_set}\n"
    )


CASES = [
    ("cli_tests", ["choices", "3", "json", "--number=1", "-m", "Fast"], 0, "JSON\nAuto\n", ""),
    ("cli_tests", ["choices", "3", "YAML", "--number=3", "-m=fast", "--color=NEVER"], 0, "yaml\nNever\n", ""),
    ("cli_tests", ["choices", "3", "xml", "--help"], 2, "", 'Invalid choice for format: xml; expected one of: "JSON", "yaml"'),
    ("cli_tests", ["choices", "3", "json", "--number=2"], 2, "", "Invalid choice for number: 2; expected one of: 1, 3"),
    ("cli_tests", ["choices", "3", "json", "--number=1", "-m=FAST"], 2, "", 'Invalid choice for mode: FAST; expected one of: "Fast", "fast"'),
    ("greet", [], 0, "Hello, world!\n", ""),
    ("greet", ["Alice", "--prefix", "Hi"], 0, "Hi, Alice!\n", ""),
    ("greet", ["Alice", "--prefix", ""], 0, ", Alice!\n", ""),
    ("greet", ["Alice", "--prefix", "a=b"], 0, "a=b, Alice!\n", ""),
    ("greet", ["--prefix", "--help", "Alice"], 2, "", "Missing value for option: --prefix"),
    ("greet", ["--prefix", "--", "Alice", "-y"], 2, "", "Missing value for option: --prefix"),
    ("greet", ["--prefix=--help", "Alice"], 0, "--help, Alice!\n", ""),
    ("greet", ["--prefix=--", "Alice", "-y"], 0, "--, ALICE!\n", ""),
    ("greet", ["--", "--prefix=Hi"], 0, "Hello, --prefix=Hi!\n", ""),
    ("greet", ["--", "--"], 0, "Hello, --!\n", ""),
    ("greet", ["Alice", "-yp", "Hi"], 0, "HI, ALICE!\n", ""),
    ("greet", ["-"], 0, "Hello, -!\n", ""),
    ("greet", [""], 0, "Hello, !\n", ""),
    ("greet", ["Alice", "Bob", "Carol"], 2, "", "Unexpected argument: Bob"),
    ("greet", ["Alice", "--", "-y"], 2, "", "Unexpected argument: -y"),
    ("greet", ["--prefix", "Hi", "-p", "Hey"], 2, "", "Repeated parameter: prefix"),
    ("greet", ["-yy"], 2, "", "Repeated parameter: yell"),
    ("greet", ["--prefix"], 2, "", "Missing value for option: --prefix"),
    ("greet", ["--pre", "Hi"], 2, "", "Unknown option: --pre"),
    ("greet", ["--prefix=Hi"], 0, "Hi, world!\n", ""),
    ("greet", ["--prefix="], 0, ", world!\n", ""),
    ("greet", ["--prefix=a=b"], 0, "a=b, world!\n", ""),
    ("greet", ["--prefix==value"], 0, "=value, world!\n", ""),
    ("greet", ["--prefix=-p"], 0, "-p, world!\n", ""),
    ("greet", ["--prefix", "-"], 0, "-, world!\n", ""),
    ("greet", ["--prefix", "--unknown=value"], 2, "", "Missing value for option: --prefix"),
    ("greet", ["-yp", "-y"], 2, "", "Missing value for option: --prefix"),
    ("greet", ["--prefix=Hi", "-p", "Hey"], 2, "", "Repeated parameter: prefix"),
    ("greet", ["--prefix", "Hi", "--prefix=Hey"], 2, "", "Repeated parameter: prefix"),
    ("greet", ["--unknown=value"], 2, "", "Unknown option: --unknown=value"),
    ("greet", ["--=value"], 2, "", "Unknown option: --=value"),
    ("greet", ["--yell=true"], 2, "", "Flag does not accept a value: --yell"),
    ("greet", ["--yell="], 2, "", "Flag does not accept a value: --yell"),
    ("greet", ["-p=Hi"], 0, "Hi, world!\n", ""),
    ("greet", ["Alice", "-yp=Hi"], 0, "HI, ALICE!\n", ""),
    ("greet", ["-p="], 0, ", world!\n", ""),
    ("greet", ["-yp="], 0, ", WORLD!\n", ""),
    ("greet", ["-p=a=b"], 0, "a=b, world!\n", ""),
    ("greet", ["-p==value"], 0, "=value, world!\n", ""),
    ("greet", ["-p=--help"], 0, "--help, world!\n", ""),
    ("greet", ["-p=--"], 0, "--, world!\n", ""),
    ("greet", ["-p=y"], 0, "y, world!\n", ""),
    ("greet", ["-p=Hi", "--prefix=Hey"], 2, "", "Repeated parameter: prefix"),
    ("greet", ["--prefix=Hi", "-p=Hey"], 2, "", "Repeated parameter: prefix"),
    ("greet", ["-y=true"], 2, "", "Flag does not accept a value: -y"),
    ("greet", ["-y="], 2, "", "Flag does not accept a value: -y"),
    ("greet", ["-pHi"], 2, "", "Option with a value must end the group: -p"),
    ("greet", ["-py", "Hi"], 2, "", "Option with a value must end the group: -p"),
    ("greet", ["-yQ"], 2, "", "Unknown option: -Q"),
    ("text", [], 2, "", "Missing command."),
    ("text", ["unknown"], 2, "", "Unknown command: unknown"),
    ("text", ["join", "a", "b", "--separator", "-", "--upper"], 0, "A-B\n", ""),
    ("text", ["join", "a", "b", "--separator", ""], 0, "ab\n", ""),
    ("text", ["join", "file=name.txt", "b"], 0, "file=name.txt b\n", ""),
    ("text", ["join", "--", "--separator=x", "b"], 0, "--separator=x b\n", ""),
    ("text", ["join", "a", "b", "--separator", "--upper"], 2, "", "Missing value for option: --separator"),
    ("text", ["join", "a", "b", "--separator=--upper"], 0, "a--upperb\n", ""),
    ("text", ["join"], 2, "", "Missing required parameter: parts"),
    ("text", ["repeat", "hello", "--count", "2", "--prefix", "> "], 0, "> hello\n> hello\n", ""),
    ("text", ["repeat", "hello", "-un", "2"], 0, "HELLO\nHELLO\n", ""),
    ("text", ["repeat", "hello", "--count", "0"], 0, "", ""),
    ("text", ["repeat", "hello", "--count", "-3"], 2, "", "Missing value for option: --count"),
    ("text", ["repeat", "hello", "--count=-3"], 2, "", "Count must be zero or greater."),
    ("text", ["repeat", "hello", "--count=2"], 0, "hello\nhello\n", ""),
    ("text", ["repeat", "hello", "--count="], 2, "", "Invalid integer for count:"),
    ("text", ["repeat", "hello", "--count", ""], 2, "", "Invalid integer for count:"),
    ("text", ["repeat", "hello", "--count", "abc"], 2, "", "Invalid integer for count: abc"),
    ("text", ["repeat", "hello", "--count", "1", "-n", "2"], 2, "", "Repeated parameter: count"),
    ("text", ["repeat", "hello", "--count"], 2, "", "Missing value for option: --count"),
    ("text", ["repeat", "hello", "-u"], 2, "", "Missing required parameter: count"),
    ("text", ["repeat", "--count", "1"], 2, "", "Missing required parameter: text"),
    ("text", ["repeat", "hello", "world", "--count", "1"], 2, "", "Unexpected argument: world"),
    ("faketar", [], 0, faketar_output(), ""),
    ("faketar", ["-cvzf", "archive.tar"], 0, faketar_output(("create", "verbose", "gzip"), "archive.tar"), ""),
    ("faketar", ["-cvzf=-archive.tar", "-b=-3", "src"], 0,
     faketar_output(("create", "verbose", "gzip"), "-archive.tar", blocking_factor=-3, paths=("src",)), ""),
    ("faketar", ["-vX=-v", "-X=", "--exclude=a=b", "-K=-3", "-K=4"], 0,
     faketar_output(("verbose",), exclude=("-v", "", "a=b"), checkpoint=(-3, 4)), ""),
    ("faketar", ["-b="], 2, "", "Invalid integer for blocking-factor: "),
    ("faketar", ["-K=bad"], 2, "", "Invalid integer for checkpoint: bad"),
    ("faketar", ["-b=2147483648"], 2, "", "Invalid integer for blocking-factor: 2147483648"),
    ("faketar", ["-cv=true"], 2, "", "Flag does not accept a value: -v"),
    ("faketar", ["--create", "--verbose", "--gzip", "--file", "archive.tar"], 0,
     faketar_output(("create", "verbose", "gzip"), "archive.tar"), ""),
    ("faketar", ["-vX", "a", "-X", "b", "--exclude", "c", "-K", "1", "-K", "2", "--checkpoint=-3"],
     0, faketar_output(("verbose",), exclude=("a", "b", "c"), checkpoint=(1, 2, -3)), ""),
    ("faketar", ["-X", "a,b"], 0, faketar_output(exclude=("a,b",)), ""),
    ("faketar", ["-X", ""], 0, faketar_output(exclude=("",)), ""),
    ("faketar", ["-X", "-v"], 2, "", "Missing value for option: --exclude"),
    ("faketar", ["--exclude=-v", "-X", "b", "--exclude="], 0, faketar_output(exclude=("-v", "b", "")), ""),
    ("faketar", ["-cxtvzjpf", "archive.tar", "-C", "tmp", "-b", "32", "src", "README.md"], 0,
     faketar_output(("create", "extract", "list", "verbose", "gzip", "bzip2", "preserve"),
                    "archive.tar", "tmp", 32, ("src", "README.md")), ""),
    ("faketar", ["-f", "--", "-v"], 2, "", "Missing value for option: --file"),
    ("faketar", ["--file=--", "-v"], 0, faketar_output(("verbose",), "--"), ""),
    ("faketar", ["--", "-cvz", "-f=x"], 0, faketar_output(paths=("-cvz", "-f=x")), ""),
    ("faketar", ["a", "-cv", "b"], 0, faketar_output(("create", "verbose"), paths=("a", "b")), ""),
    ("faketar", ["-b", "-3"], 2, "", "Missing value for option: --blocking-factor"),
    ("faketar", ["--blocking-factor=-3"], 0, faketar_output(blocking_factor=-3), ""),
    ("faketar", ["-f", ""], 0, faketar_output(), ""),
    ("faketar", ["-K", "1", "-K", "bad"], 2, "", "Invalid integer for checkpoint: bad"),
    ("faketar", ["-vv"], 2, "", "Repeated parameter: verbose"),
    ("faketar", ["-cv", "--verbose"], 2, "", "Repeated parameter: verbose"),
    ("faketar", ["-cvf"], 2, "", "Missing value for option: --file"),
    ("faketar", ["-cvzfarchive.tar"], 2, "", "Option with a value must end the group: -f"),
    ("faketar", ["-b-3"], 2, "", "Option with a value must end the group: -b"),
    ("cli_tests", [], 0, "parser tests passed\n", ""),
    ("arc", [], 0, "command=<root>\nhelp=False\nversion=False\n", ""),
    ("arc", ["--help"], 0, "command=<root>\nhelp=True\nversion=False\n", ""),
    ("arc", ["--version"], 0, "command=<root>\nhelp=False\nversion=True\n", ""),
    ("arc", ["--help", "--version"], 0, "command=<root>\nhelp=True\nversion=True\n", ""),
    ("arc", ["pack", "project.zip"], 0, arc_pack_output("project.zip"), ""),
    ("arc", ["pack", "--format", "tar", "--keep-root", "backup", "./src", "README.md"],
     0, arc_pack_output("backup", ("./src", "README.md"), "tar", keep_root=True), ""),
    ("arc", ["pack", "project.zip", "--password", "example"],
     0, arc_pack_output("project.zip", password_set=True), ""),
    ("arc", ["pack", "--", "-archive.zip", "-source"],
     0, arc_pack_output("-archive.zip", ("-source",)), ""),
    ("arc", ["unpack", "project.zip"], 0, arc_unpack_output("project.zip"), ""),
    ("arc", ["unpack", "--strip-root", "--entry", "docs", "--entry", "notes.txt", "project.zip", "./out"],
     0, arc_unpack_output("project.zip", "./out", ("docs", "notes.txt"), strip_root=True), ""),
    ("arc", ["unpack", "project.zip", "--entry", "a,b", "--password", "example"],
     0, arc_unpack_output("project.zip", entries=("a,b",), password_set=True), ""),
    ("arc", ["list", "project.zip"], 0, arc_read_output("list", "project.zip", tree=False), ""),
    ("arc", ["list", "--tree", "project.zip"], 0, arc_read_output("list", "project.zip", tree=True), ""),
    ("arc", ["list", "tree", "project.zip"], 0, arc_read_output("list tree", "project.zip", tree=True), ""),
    ("arc", ["list", "--", "tree"], 0, arc_read_output("list", "tree", tree=False), ""),
    ("arc", ["list", "tree", "--password", "example", "project.zip"],
     0, arc_read_output("list tree", "project.zip", tree=True, password_set=True), ""),
    ("arc", ["info", "project.zip"], 0, arc_read_output("info", "project.zip"), ""),
    ("arc", ["verify", "--password", "example", "project.zip"],
     0, arc_read_output("verify", "project.zip", password_set=True), ""),
    ("arc", ["list", "tree"], 2, "", "Missing required parameter: archive"),
    ("arc", ["list", "tree", "project.zip", "extra"], 2, "", "Unexpected argument: extra"),
    ("arc", ["unpack", "project.zip", "./out", "extra"], 2, "", "Unexpected argument: extra"),
    ("arc", ["--help", "pack"], 2, "", "Unexpected argument: pack"),
    ("arc", ["pack", "--version", "project.zip"], 2, "", "Unknown option: --version"),
    ("arc", ["pack", "--help=true"], 2, "", "Flag does not accept a value: --help"),
    ("arc", ["pack", "--", "--help"], 0, arc_pack_output("--help"), ""),
    ("arc", ["unknown", "--help"], 2, "", "Unexpected argument: unknown"),
    ("arc", ["pack", "--format=zip", "project.zip"], 0, arc_pack_output("project.zip", format="zip"), ""),
    ("arc", ["pack", "--password", "--keep-root", "project.zip"], 2, "", "Missing value for option: --password"),
    ("arc", ["pack", "--password=--keep-root", "project.zip"],
     0, arc_pack_output("project.zip", password_set=True), ""),
    ("arc", ["pack", "--password", "--unknown", "project.zip"], 2, "", "Missing value for option: --password"),
    ("arc", ["pack", "--password", "--", "project.zip"], 2, "", "Missing value for option: --password"),
    ("arc", ["--help=true"], 2, "", "Flag does not accept a value: --help"),
    ("arc", ["pack"], 2, "", "Missing required parameter: archive"),
    ("arc", ["version"], 2, "", "Unexpected argument: version"),
    ("arc", ["--version", "--version"], 2, "", "Repeated parameter: version"),
]

for tokens, command, kwargs in (
    ([], "", {}),
    (["remote"], "remote", {}),
    (["remote", "add", "origin"], "remote add", {"arguments": ("origin",)}),
    (["remote", "add", "deep", "value"], "remote add deep", {"arguments": ("value",)}),
    (["remote", "list"], "remote", {"arguments": ("list",)}),
    (["remoteadd"], "", {"arguments": ("remoteadd",)}),
    (["remote add"], "", {"arguments": ("remote add",)}),
    (["lonely"], "", {"arguments": ("lonely",)}),
    (["lonely", "child"], "lonely child", {}),
    (["--", "remote", "add"], "", {"arguments": ("remote", "add")}),
    (["remote", "--", "add", "deep"], "remote", {"arguments": ("add", "deep")}),
    (["--root-only", "remote", "add"], "", {"root_only": True, "arguments": ("remote", "add")}),
    (["remote", "add", "-vht", "a", "-t", "b", "--checkpoint=-3"], "remote add",
     {"verbose": True, "help": True, "tags": ("a", "b"), "checkpoints": (-3,)}),
    (["remote", "required", "target", "--count", "1", "--help"], "remote required",
     {"arguments": ("target",), "count": 1, "help": True}),
):
    CASES.append(("cli_tests", ["route", *tokens], 0, routing_output(command, **kwargs), ""))

CASES += [
    ("cli_tests", ["automatic-immutable", "target", "--count=1"], 0, "handled\n", ""),
    ("cli_tests", ["automatic-custom", "target", "--count=1", "--help"], 0, "custom help handled\n", ""),
    ("cli_tests", ["automatic-custom", "--help"], 2, "", "Missing required parameter: target"),
    ("cli_tests", ["route-root-first", "remote", "add", "deep"], 0, routing_output("remote add deep"), ""),
    ("cli_tests", ["route-no-default", "remote", "add"], 0, routing_output("remote add"), ""),
    ("cli_tests", ["route-no-default"], 2, "", "Missing command."),
    ("cli_tests", ["route-no-default", "unknown"], 2, "", "Unknown command: unknown"),
    ("cli_tests", ["route-no-default", "unknown", "--help"], 2, "", "Unknown command: unknown"),
    ("cli_tests", ["route-no-default", "lonely"], 2, "", "Unknown command: lonely"),
    ("cli_tests", ["route", "remote", "add", "--root-only"], 2, "", "Unknown option: --root-only"),
    ("cli_tests", ["route", "remote", "required", "--help"], 2, "", "Missing required parameter: target"),
    ("cli_tests", ["route", "remote", "required", "target", "--help"], 2, "", "Missing required parameter: count"),
    ("cli_tests", ["route", "remote", "required", "target", "extra", "--count", "1"], 2, "", "Unexpected argument: extra"),
    ("cli_tests", ["route", "remote", "add", "-tt", "value"], 2, "", "Option with a value must end the group: -t"),
    ("cli_tests", ["single-required"], 2, "", "Missing required parameter: target"),
    ("cli_tests", ["single-required", "--help"], 2, "", "Missing required parameter: target"),
    ("cli_tests", ["single-required", "target"], 2, "", "Missing required parameter: count"),
    ("cli_tests", ["single-required", "target", "--count", "1"],
     0, routing_output(arguments=("target",), count=1), ""),
    ("cli_tests", ["single-required", "target", "--count", "1", "--help"],
     0, routing_output(arguments=("target",), count=1, help=True), ""),
    ("cli_tests", ["single-required", "target", "extra", "--count", "1"], 2, "", "Unexpected argument: extra"),
]

CASES += [
    ("cli_tests", ["automatic-conflict", "-h"], 2, "", "Missing required parameter: target"),
    ("cli_tests", ["automatic-conflict", "target", "--count=1", "-h"], 0, "handled\n", ""),
    ("cli_tests", ["automatic", "--count", "--help"], 2, "", "Missing value for option: --count"),
    ("cli_tests", ["automatic", "--", "--help"], 2, "", "Missing required parameter: count"),
    ("cli_tests", ["automatic", "--unknown", "--help"], 2, "", "Unknown option: --unknown"),
]

HELP_CASES = [
    ("cli_tests", ["choices", "--help"], "routing - Choice fixture"),
    ("cli_tests", ["automatic-immutable", "--help"], "routing - "),
    ("arc", ["help"], "arc - "),
    ("cli_tests", ["automatic", "--help", "--unknown"], "routing - "),
    ("cli_tests", ["automatic", "-hZ"], "routing - "),
    ("cli_tests", ["automatic", "--help", "--help"], "routing - "),
    ("cli_tests", ["automatic", "--help"], "routing - "),
    ("cli_tests", ["automatic", "-h"], "routing - "),
    ("cli_tests", ["automatic", "-vh"], "routing - "),
    ("cli_tests", ["automatic-conflict", "--help"], "routing - "),
    ("greet", ["-h"], "greet - "),
    ("greet", ["Alice", "--help"], "greet - "),
    ("greet", ["-yh"], "greet - "),
    ("faketar", ["src", "--help"], "faketar - "),
    ("arc", ["pack", "project.zip", "--help"], "arc pack - "),
    ("arc", ["pack", "-h"], "arc pack - "),
    ("arc", ["pack", "--help", "project.zip"], "arc pack - "),
    ("greet", ["--help"], "greet - "),
    ("faketar", ["--help"], "faketar - "),
    ("text", ["--help"], "text - "),
    ("text", ["repeat", "--help"], "text repeat - "),
    ("arc", ["pack", "--help"], "arc pack - "),
    ("arc", ["list", "tree", "--help"], "arc list tree - "),
    ("cli_tests", ["route", "help", "remote", "add"], "routing remote add - "),
    ("arc", ["help", "list", "tree"], "arc list tree - "),
]


CONTRACT_CASES = [
    ("empty-integer", "valid_choices"),
    ("duplicate-integer", "valid_choices"),
    ("empty-string", "valid_choices"),
    ("duplicate-string", "valid_choices"),
    ("case-collision", "valid_choices"),
    ("integer-default", "valid_default"),
    ("string-default", "valid_default"),
    ("sensitive-default", "valid_default"),
]


def executable_path(name, compiler):
    project = ROOT / "tests" if name == "cli_tests" else ROOT / "examples" / name
    return project / "build" / compiler / name


def main():
    for compiler in sys.argv[1:] or ["gobo", "eiffelstudio"]:
        for name, tokens, code, stdout, error in CASES:
            result = subprocess.run(
                [str(executable_path(name, compiler)), *tokens],
                capture_output=True, text=True, timeout=10,
            )
            context = (compiler, name, tokens, result)
            assert (result.returncode, result.stdout) == (code, stdout), context
            assert error in result.stderr, context
            if not error:
                assert not result.stderr, context

        for name, tokens, prefix in HELP_CASES:
            result = subprocess.run(
                [str(executable_path(name, compiler)), *tokens],
                capture_output=True, text=True, timeout=10,
            )
            assert result.returncode == 0 and not result.stderr, (compiler, result)
            assert result.stdout.startswith(prefix), (compiler, result)
            assert "Usage:\n" in result.stdout, (compiler, result)
            if name == "cli_tests" and tokens[0].startswith("automatic"):
                for fragment in ("<target>", "--count <integer>", "--verbose", "--help"):
                    assert fragment in result.stdout, (compiler, fragment, result)
                if tokens[0] == "automatic-conflict":
                    assert "-h, --verbose" in result.stdout, (compiler, result)
                    assert "-h, --help" not in result.stdout, (compiler, result)
            if name == "greet":
                for fragment in ("greet [name] [options]", "--prefix <string>",
                                 'default: "Hello"', "--yell", "-h, --help"):
                    assert fragment in result.stdout, (compiler, fragment, result)
                assert "Commands:" not in result.stdout, (compiler, result)
            if name == "arc" and tokens == ["help"]:
                for fragment in ("Commands:", "pack", "unpack", "list tree", "verify"):
                    assert fragment in result.stdout, (compiler, fragment, result)
            if name == "arc" and "pack" in tokens:
                for fragment in ("<archive>", "--format", "--password", "-h, --help"):
                    assert fragment in result.stdout, (compiler, fragment, result)
        for case, assertion in CONTRACT_CASES:
            result = subprocess.run(
                [str(executable_path("cli_tests", compiler)), f"invalid-choice-{case}"],
                capture_output=True, text=True, timeout=10,
            )
            assert result.returncode != 0 and assertion in result.stderr, (compiler, case, result)
        print(f"{compiler}: {len(CASES) + len(HELP_CASES) + len(CONTRACT_CASES)} checks passed")


if __name__ == "__main__":
    main()

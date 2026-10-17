"""Check built examples: python3 tests/check_examples.py [gobo|eiffelstudio ...]."""

from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CASES = [
    ("greet", ["Alice", "--prefix=Hi"], 0, "Hi, Alice!\n", ""),
    ("greet", ["Alice", "--prefix="], 0, ", Alice!\n", ""),
    ("greet", ["Alice", "--prefix=a=b"], 0, "a=b, Alice!\n", ""),
    ("greet", ["Alice", "--prefix=--help"], 0, "--help, Alice!\n", ""),
    ("greet", ["--prefix", "--prefix=Hi", "Alice"], 0, "--prefix=Hi, Alice!\n", ""),
    ("greet", ["--", "--prefix=Hi"], 0, "Hello, --prefix=Hi!\n", ""),
    ("greet", ["Alice", "-p", "Hi", "-y"], 0, "HI, ALICE!\n", ""),
    ("greet", ["Alice", "--prefix=Hi", "--prefix", "Hey"], 2, "", "Repeated parameter: prefix"),
    ("greet", ["--yell=true"], 2, "", "Flag does not accept a value: --yell"),
    ("greet", ["--help="], 2, "", "Flag does not accept a value: --help"),
    ("greet", ["--unknown=x"], 2, "", "Unknown option: --unknown=x"),
    ("greet", ["-p=Hi"], 0, "Hi, world!\n", ""),
    ("text", ["join", "a", "b", "--separator=-", "--upper"], 0, "A-B\n", ""),
    ("text", ["join", "a", "b", "--separator="], 0, "ab\n", ""),
    ("text", ["join", "a", "b", "--separator=a=b"], 0, "aa=bb\n", ""),
    ("text", ["join", "file=name.txt", "b"], 0, "file=name.txt b\n", ""),
    ("text", ["join", "--", "--separator=x", "b"], 0, "--separator=x b\n", ""),
    ("text", ["join", "a", "b", "--separator", "--upper=x"], 0, "a--upper=xb\n", ""),
    ("text", ["repeat", "hello", "--count=2", "--prefix=> "], 0, "> hello\n> hello\n", ""),
    ("text", ["repeat", "hello", "--count", "2", "--prefix", "> "], 0, "> hello\n> hello\n", ""),
    ("text", ["repeat", "hello", "--count=0"], 0, "", ""),
    ("text", ["repeat", "hello", "--count=-3"], 2, "", "Count must be zero or greater."),
    ("text", ["repeat", "hello", "--count="], 2, "", "Invalid integer for count:"),
    ("text", ["repeat", "hello", "--count=abc"], 2, "", "Invalid integer for count: abc"),
    ("text", ["repeat", "hello", "--count=1", "--count", "2"], 2, "", "Repeated parameter: count"),
    ("text", ["repeat", "hello", "--count"], 2, "", "Missing value for option: --count"),
    ("text", ["join", "a", "--upper=true"], 2, "", "Flag does not accept a value: --upper"),
    ("text", ["join", "a", "--unknown=x"], 2, "", "Unknown option: --unknown=x"),
]


def faketar_output(flags=(), file="", directory=".", blocking_factor=20, paths=(), exclude=(), checkpoint=()):
    names = ("create", "extract", "list", "verbose", "gzip", "bzip2", "preserve")
    return (
        "".join(f"{name}={name in flags}\n" for name in names)
        + f"file={file}\ndirectory={directory}\nblocking-factor={blocking_factor}\npaths:\n"
        + "".join(f"  {path}\n" for path in paths)
        + "exclude:\n" + "".join(f"  {pattern}\n" for pattern in exclude)
        + "checkpoint:\n" + "".join(f"  {number}\n" for number in checkpoint)
    )


for tokens in (
    ["-c", "-v", "-z", "-f", "archive.tar"],
    ["-cvz", "-f=archive.tar"],
    ["-cvzfarchive.tar"],
    ["-cvzf=archive.tar"],
    ["-cvzf", "archive.tar"],
    ["--create", "--verbose", "--gzip", "--file=archive.tar"],
):
    CASES.append(("faketar", tokens, 0, faketar_output(("create", "verbose", "gzip"), "archive.tar"), ""))

CASES += [
    ("faketar", ["-vXa", "-X=b", "--exclude", "c", "-K1", "-K=2", "--checkpoint", "-3"],
     0, faketar_output(("verbose",), exclude=("a", "b", "c"), checkpoint=(1, 2, -3)), ""),
    ("faketar", ["-X="], 0, faketar_output(exclude=("",)), ""),
    ("faketar", ["-X", "-v"], 0, faketar_output(exclude=("-v",)), ""),
    ("faketar", ["-K1", "-Kbad"], 2, "", "Invalid integer for checkpoint: bad"),
    ("text", ["repeat", "hello", "-u"], 2, "", "Missing required parameter: count"),
    ("faketar", ["-cxtvzjpfarchive.tar", "-Ctmp", "-b=32", "src", "README.md"], 0,
     faketar_output(("create", "extract", "list", "verbose", "gzip", "bzip2", "preserve"),
                    "archive.tar", "tmp", 32, ("src", "README.md")), ""),
    ("faketar", ["-fcvz"], 0, faketar_output(file="cvz"), ""),
    ("faketar", ["-f="], 0, faketar_output(), ""),
    ("faketar", ["-f==name"], 0, faketar_output(file="=name"), ""),
    ("faketar", ["-f=a=b"], 0, faketar_output(file="a=b"), ""),
    ("faketar", ["-f", "--", "-v"], 0, faketar_output(("verbose",), "--"), ""),
    ("faketar", ["--", "-cvz", "-f=x"], 0, faketar_output(paths=("-cvz", "-f=x")), ""),
    ("faketar", ["a", "-cv", "b"], 0, faketar_output(("create", "verbose"), paths=("a", "b")), ""),
    ("faketar", ["-b-3"], 0, faketar_output(blocking_factor=-3), ""),
    ("faketar", ["-cb=-3"], 0, faketar_output(("create",), blocking_factor=-3), ""),
    ("faketar", ["-b", "-3"], 0, faketar_output(blocking_factor=-3), ""),
    ("faketar", ["-f", "--help"], 0, faketar_output(file="--help"), ""),
    ("faketar", ["-f", ""], 0, faketar_output(), ""),
    ("faketar", ["-"], 0, faketar_output(paths=("-",)), ""),
    ("faketar", ["cvzf"], 0, faketar_output(paths=("cvzf",)), ""),
    ("faketar", ["-cvQ"], 2, "", "Unknown option: -Q"),
    ("faketar", ["-vv"], 2, "", "Repeated parameter: verbose"),
    ("faketar", ["-cv", "--verbose"], 2, "", "Repeated parameter: verbose"),
    ("faketar", ["-cv=yes"], 2, "", "Flag does not accept a value: -v"),
    ("faketar", ["-v="], 2, "", "Flag does not accept a value: -v"),
    ("faketar", ["-cvf"], 2, "", "Missing value for option: -f"),
    ("faketar", ["-cb="], 2, "", "Invalid integer for blocking-factor:"),
    ("faketar", ["-cbxyz"], 2, "", "Invalid integer for blocking-factor: xyz"),
    ("faketar", ["-b2147483648"], 2, "", "Invalid integer for blocking-factor: 2147483648"),
    ("faketar", ["-fx", "--file=y"], 2, "", "Repeated parameter: file"),
    ("faketar", ["--help", "-vv"], 2, "", "Repeated parameter: verbose"),
    ("greet", ["Alice", "-ypHi"], 0, "HI, ALICE!\n", ""),
    ("text", ["repeat", "hello", "-un2"], 0, "HELLO\nHELLO\n", ""),
]

for compiler in sys.argv[1:] or ["gobo", "eiffelstudio"]:
    for example, tokens, code, stdout, error in CASES:
        executable = ROOT / "examples" / example / "build" / compiler / example
        result = subprocess.run([str(executable), *tokens], capture_output=True, text=True, timeout=10)
        assert (result.returncode, result.stdout) == (code, stdout), (compiler, example, tokens, result)
        assert error in result.stderr, (compiler, example, tokens, result.stderr)
        if not error:
            assert not result.stderr, (compiler, example, tokens, result.stderr)
    print(f"{compiler}: {len(CASES)} checks passed")

    result = subprocess.run(
        [str(ROOT / "examples/faketar/build" / compiler / "faketar"), "--help"],
        capture_output=True, text=True, timeout=10,
    )
    assert result.returncode == 0 and not result.stderr, (compiler, result)
    assert "first value option takes the entire" in result.stdout, (compiler, result.stdout)
    assert "-fcvz sets file=cvz" in result.stdout, (compiler, result.stdout)

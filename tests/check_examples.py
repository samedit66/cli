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
    ("greet", ["-p=Hi"], 2, "", "Unknown option: -p=Hi"),
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

for compiler in sys.argv[1:] or ["gobo", "eiffelstudio"]:
    for example, tokens, code, stdout, error in CASES:
        executable = ROOT / "examples" / example / "build" / compiler / example
        result = subprocess.run([str(executable), *tokens], capture_output=True, text=True, timeout=10)
        assert (result.returncode, result.stdout) == (code, stdout), (compiler, example, tokens, result)
        assert error in result.stderr, (compiler, example, tokens, result.stderr)
        if not error:
            assert not result.stderr, (compiler, example, tokens, result.stderr)
    print(f"{compiler}: {len(CASES)} checks passed")

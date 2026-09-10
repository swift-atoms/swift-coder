from pathlib import Path
import os
import subprocess
import sys
import tempfile

modules = Path(sys.argv[1]).resolve()
compiler = os.environ.get("CODER_SWIFTC", "swiftc")
fixtures = Path(__file__).parent
expected = {"OneWayMap": "conform to 'Coding'", "DiscardedValue": "requires the types 'String' and '()' be equivalent"}
with tempfile.TemporaryDirectory(prefix="coder-negative-") as cache:
    for name, diagnostic in expected.items():
        command = [compiler, "-typecheck", "-swift-version", "6", "-enable-experimental-feature", "Lifetimes", "-I", str(modules), "-module-cache-path", cache, str(fixtures / (name + ".swift"))]
        result = subprocess.run(command, capture_output=True, text=True)
        if result.returncode == 0 or diagnostic not in result.stderr:
            raise SystemExit(f"{name}: unexpected compiler result\n{result.stderr}")
        print(f"{name}: rejected for the expected capability restriction")

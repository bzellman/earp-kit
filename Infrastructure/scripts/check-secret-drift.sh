#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ALLOWLIST="${ROOT}/Infrastructure/scripts/secret-drift-allowlist.txt"

python3 - "$ROOT" "$ALLOWLIST" <<'PY'
from __future__ import annotations

import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1])
allowlist_path = pathlib.Path(sys.argv[2])

patterns = [
    re.compile(r"-----BEGIN (RSA|EC|OPENSSH|DSA|PGP) PRIVATE KEY-----"),
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(r"AIza[0-9A-Za-z\\-_]{35}"),
    re.compile(r"gh[pousr]_[A-Za-z0-9]{20,}"),
    re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}"),
    re.compile(r"(?i)(api[_-]?key|secret|token|password)\\s*[:=]\\s*['\\\"]?[A-Za-z0-9_./+=-]{12,}"),
]

allowlist: list[re.Pattern[str]] = []
if allowlist_path.exists():
    for raw_line in allowlist_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        allowlist.append(re.compile(line))

try:
    result = subprocess.run(
        ["git", "ls-files"],
        cwd=root,
        capture_output=True,
        text=True,
        check=True,
    )
    files = [root / line for line in result.stdout.splitlines() if line.strip()]
except subprocess.CalledProcessError as exc:
    print(exc.stderr, file=sys.stderr)
    raise SystemExit(exc.returncode)

matches: list[str] = []
for path in files:
    if ".git.nosync" in path.parts:
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        continue
    rel = path.relative_to(root).as_posix()
    for line_number, line in enumerate(text.splitlines(), start=1):
        if any(regex.search(rel) or regex.search(line) for regex in allowlist):
            continue
        if any(pattern.search(line) for pattern in patterns):
            matches.append(f"{rel}:{line_number}: {line.strip()}")

if matches:
    print("Potential secret drift detected:", file=sys.stderr)
    for match in matches:
        print(match, file=sys.stderr)
    raise SystemExit(1)

print("Secret drift scan passed.")
PY

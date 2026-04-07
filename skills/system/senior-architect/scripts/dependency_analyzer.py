#!/usr/bin/env python3
import argparse
from pathlib import Path

DEP_FILES = [
    "package.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "requirements.txt",
    "pyproject.toml",
    "Pipfile",
    "Pipfile.lock",
    "go.mod",
    "go.sum",
    "Cargo.toml",
    "Gemfile",
    "Podfile",
    "Package.swift",
    "build.gradle",
    "build.gradle.kts",
]


def find_dependency_files(root: Path):
    matches = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.name in DEP_FILES:
            matches.append(path)
    return matches


def main() -> int:
    parser = argparse.ArgumentParser(description="Detect common dependency files.")
    parser.add_argument("project_path", help="Path to the project root")
    parser.add_argument("--analyze", action="store_true", help="Enable dependency scan")
    args = parser.parse_args()

    root = Path(args.project_path).expanduser().resolve()
    if not args.analyze:
        print("Run with --analyze to scan for dependency files.")
        return 0

    matches = find_dependency_files(root)
    print(f"Scanned: {root}")
    if not matches:
        print("No dependency files found.")
        return 0

    print("Dependency files:")
    for match in matches:
        print(f"- {match}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

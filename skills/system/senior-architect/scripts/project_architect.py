#!/usr/bin/env python3
import argparse
from collections import Counter
from pathlib import Path

SIGNAL_FILES = {
    "package.json": "Node/JS",
    "next.config.js": "Next.js",
    "next.config.mjs": "Next.js",
    "tsconfig.json": "TypeScript",
    "yarn.lock": "Yarn",
    "pnpm-lock.yaml": "pnpm",
    "Podfile": "CocoaPods",
    "Package.swift": "SwiftPM",
    "*.xcodeproj": "Xcode",
    "*.xcworkspace": "Xcode",
    "*.csproj": ".NET",
    "*.sln": ".NET",
    "go.mod": "Go",
    "requirements.txt": "Python",
    "pyproject.toml": "Python",
    "pubspec.yaml": "Flutter",
    "build.gradle": "Android/Gradle",
    "build.gradle.kts": "Android/Gradle",
}

EXT_SIGNALS = {
    ".swift": "Swift",
    ".kt": "Kotlin",
    ".java": "Java",
    ".ts": "TypeScript",
    ".tsx": "TypeScript",
    ".js": "JavaScript",
    ".py": "Python",
    ".go": "Go",
    ".cs": "C#",
    ".dart": "Dart",
}


def scan_project(root: Path) -> Counter:
    counts = Counter()
    for path in root.rglob("*"):
        name = path.name
        if path.is_dir():
            continue
        for pattern, label in SIGNAL_FILES.items():
            if "*" in pattern:
                if path.match(pattern):
                    counts[label] += 1
            else:
                if name == pattern:
                    counts[label] += 1
        ext = path.suffix.lower()
        if ext in EXT_SIGNALS:
            counts[EXT_SIGNALS[ext]] += 1
    return counts


def main() -> int:
    parser = argparse.ArgumentParser(description="Summarize project footprint and likely components.")
    parser.add_argument("project_path", help="Path to the project root")
    parser.add_argument("--verbose", action="store_true", help="Print detailed counts")
    args = parser.parse_args()

    root = Path(args.project_path).expanduser().resolve()
    counts = scan_project(root)

    print(f"Scanned: {root}")
    if not counts:
        print("No stack signals detected.")
        return 0

    print("Signals:")
    for label, count in counts.most_common():
        if args.verbose:
            print(f"- {label}: {count}")
        else:
            print(f"- {label}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
import argparse
from pathlib import Path


def generate_mermaid(project_path: Path) -> str:
    name = project_path.name or "project"
    return (
        "%%{init: {'theme': 'base'} }%%\n"
        "flowchart LR\n"
        f"  User[User] --> App[{name} App]\n"
        f"  App --> Api[{name} API]\n"
        "  Api --> Db[(Database)]\n"
        "  Api --> Cache[(Cache)]\n"
        "  Api --> Blob[(Object Storage)]\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a starter Mermaid architecture diagram.")
    parser.add_argument("project_path", help="Path to the project root")
    parser.add_argument("--output", help="Optional output file (.mmd)")
    args = parser.parse_args()

    project_path = Path(args.project_path).expanduser().resolve()
    diagram = generate_mermaid(project_path)

    if args.output:
        out_path = Path(args.output).expanduser().resolve()
        out_path.write_text(diagram, encoding="utf-8")
    else:
        print(diagram)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

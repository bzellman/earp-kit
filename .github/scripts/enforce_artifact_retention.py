#!/usr/bin/env python3
"""Apply or preview lifecycle retention rules for build artifact buckets."""

from __future__ import annotations

import argparse
import json
import subprocess
import tempfile
from pathlib import Path


CANDIDATE_PATTERNS = (
    "cloudbuild",
    "run-sources",
    "gcf-v2-sources",
    "artifacts",
)


def run_json(command: list[str]) -> list[dict]:
    completed = subprocess.run(command, check=True, capture_output=True, text=True)
    payload = completed.stdout.strip() or "[]"
    return json.loads(payload)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-id", required=True)
    parser.add_argument("--mode", choices=("plan", "apply"), required=True)
    parser.add_argument("--retention-days", type=int, required=True)
    args = parser.parse_args()

    buckets = run_json(
        [
            "gcloud",
            "storage",
            "buckets",
            "list",
            "--project",
            args.project_id,
            "--format=json(name)",
        ]
    )

    candidates = [
        bucket["name"]
        for bucket in buckets
        if any(pattern in bucket["name"] for pattern in CANDIDATE_PATTERNS)
    ]

    print(f"## Artifact Retention ({args.mode})")
    print("")
    print(f"- Project: `{args.project_id}`")
    print(f"- Retention days: `{args.retention_days}`")

    if not candidates:
        print("- Candidate buckets: none found")
        return

    print("- Candidate buckets:")
    for bucket in sorted(candidates):
        print(f"  - `gs://{bucket}`")

    if args.mode == "plan":
        print("")
        print("No changes applied.")
        return

    lifecycle = {
        "rule": [
            {
                "action": {"type": "Delete"},
                "condition": {"age": args.retention_days},
            }
        ]
    }

    with tempfile.NamedTemporaryFile("w", delete=False, suffix=".json") as handle:
        json.dump(lifecycle, handle)
        handle.write("\n")
        lifecycle_path = Path(handle.name)

    for bucket in sorted(candidates):
        subprocess.run(
            [
                "gcloud",
                "storage",
                "buckets",
                "update",
                f"gs://{bucket}",
                f"--lifecycle-file={lifecycle_path}",
            ],
            check=True,
        )
        print(f"- Applied lifecycle policy to `gs://{bucket}`")


if __name__ == "__main__":
    main()

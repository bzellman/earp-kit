#!/usr/bin/env python3
"""Starter telemetry collector and aggregator for weekly ops reviews."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


def run_json(command: list[str]) -> list[dict]:
    completed = subprocess.run(command, check=True, capture_output=True, text=True)
    payload = completed.stdout.strip() or "[]"
    return json.loads(payload)


def collect(environment: str, mode: str, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    services = run_json(
        [
            "gcloud",
            "run",
            "services",
            "list",
            "--format=json(metadata.name,status.url,status.latestReadyRevisionName,status.conditions)",
        ]
    )

    findings: list[dict[str, str]] = []
    normalized_services = []
    for service in services:
        name = service.get("metadata", {}).get("name", "unknown")
        url = service.get("status", {}).get("url", "")
        revision = service.get("status", {}).get("latestReadyRevisionName", "")
        conditions = service.get("status", {}).get("conditions", [])
        ready = next(
            (
                condition.get("status", "")
                for condition in conditions
                if condition.get("type") == "Ready"
            ),
            "Unknown",
        )
        normalized_services.append(
            {
                "name": name,
                "url": url,
                "latestReadyRevisionName": revision,
                "ready": ready,
            }
        )
        if ready != "True":
            findings.append(
                {
                    "service": name,
                    "severity": "medium",
                    "summary": "Cloud Run service is not reporting a Ready=True condition.",
                }
            )

    report = {
        "environment": environment,
        "mode": mode,
        "collectedAt": datetime.now(timezone.utc).isoformat(),
        "services": normalized_services,
        "candidateFindings": findings,
    }
    (output_dir / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


def maybe_create_issue(body: str, title: str) -> dict | None:
    token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    repository = os.getenv("GITHUB_REPOSITORY", "")
    if not token or not repository:
        return None

    owner, repo = repository.split("/", 1)
    payload = json.dumps({"title": title, "body": body}).encode("utf-8")
    request = urllib.request.Request(
        f"https://api.github.com/repos/{owner}/{repo}/issues",
        data=payload,
        method="POST",
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "User-Agent": "agentic-sdlc-weekly-ops-review",
            "X-GitHub-Api-Version": "2022-11-28",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(request) as response:
        return json.loads(response.read().decode("utf-8"))


def aggregate(mode: str, input_dir: Path, output_dir: Path, publish: str, run_url: str) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)

    reports = []
    for path in sorted(input_dir.glob("*.json")):
        reports.append(json.loads(path.read_text(encoding="utf-8")))

    candidate_count = sum(len(report.get("candidateFindings", [])) for report in reports)
    published_count = 0
    parent_issue = None

    lines = [
        "# Weekly Ops Review",
        "",
        f"- Mode: `{mode}`",
        f"- Generated at: {datetime.now(timezone.utc).isoformat()}",
        f"- Workflow run: {run_url or 'n/a'}",
        "",
    ]

    for report in reports:
        lines.append(f"## {report['environment']}")
        services = report.get("services", [])
        lines.append(f"- Services discovered: **{len(services)}**")
        findings = report.get("candidateFindings", [])
        lines.append(f"- Candidate findings: **{len(findings)}**")
        for finding in findings:
          lines.append(f"  - `{finding['service']}`: {finding['summary']}")
        lines.append("")

    body = "\n".join(lines).strip() + "\n"

    if publish.lower() == "true":
        issue = maybe_create_issue(body, f"Weekly Ops Review - {datetime.now(timezone.utc).date().isoformat()}")
        if issue:
            published_count = 1
            parent_issue = {"url": issue.get("html_url"), "number": issue.get("number")}

    summary = {
        "run_url": run_url,
        "candidate_count": candidate_count,
        "candidate_count_above_threshold": candidate_count,
        "published_count": published_count,
        "parent_issue": parent_issue,
        "environments": [report["environment"] for report in reports],
    }

    (output_dir / "weekly-ops-review.md").write_text(body, encoding="utf-8")
    (output_dir / "weekly-ops-review.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    collect_parser = subparsers.add_parser("collect")
    collect_parser.add_argument("--environment", required=True)
    collect_parser.add_argument("--mode", required=True)
    collect_parser.add_argument("--output-dir", required=True, type=Path)

    aggregate_parser = subparsers.add_parser("aggregate")
    aggregate_parser.add_argument("--mode", required=True)
    aggregate_parser.add_argument("--input-dir", required=True, type=Path)
    aggregate_parser.add_argument("--output-dir", required=True, type=Path)
    aggregate_parser.add_argument("--publish", required=True)
    aggregate_parser.add_argument("--run-url", required=True)

    args = parser.parse_args()
    if args.command == "collect":
        collect(args.environment, args.mode, args.output_dir)
    else:
        aggregate(args.mode, args.input_dir, args.output_dir, args.publish, args.run_url)


if __name__ == "__main__":
    main()

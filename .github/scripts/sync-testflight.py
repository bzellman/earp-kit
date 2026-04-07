#!/usr/bin/env python3
"""Starter scaffold for syncing TestFlight feedback into GitHub issues.

This script intentionally stays generic. It validates the expected App Store
Connect inputs and opens a single reminder issue so adopters have a safe,
reviewable starting point instead of a missing script reference.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request


def require_env(name: str) -> str:
    value = os.getenv(name, "").strip()
    if not value:
        print(f"Missing required environment variable: {name}", file=sys.stderr)
        raise SystemExit(1)
    return value


def github_request(method: str, url: str, token: str, payload: dict | None = None) -> dict:
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "User-Agent": "agentic-sdlc-testflight-sync",
            "X-GitHub-Api-Version": "2022-11-28",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(request) as response:
        return json.loads(response.read().decode("utf-8"))


def main() -> None:
    token = require_env("GH_TOKEN")
    app_id = require_env("YOUR_APPLE_APP_ID")
    require_env("ASC_KEY_ID")
    require_env("ASC_ISSUER_ID")
    require_env("ASC_PRIVATE_KEY")

    repository = require_env("GITHUB_REPOSITORY")
    owner, repo = repository.split("/", 1)
    issues_url = f"https://api.github.com/repos/{owner}/{repo}/issues"

    body = (
        "This workflow scaffold validated the App Store Connect inputs for "
        f"`{app_id}`.\n\n"
        "Replace `.github/scripts/sync-testflight.py` with project-specific "
        "feedback ingestion logic once you have finalized the App Store Connect "
        "mapping and issue triage rules."
    )

    issue = github_request(
        "POST",
        issues_url,
        token,
        {
            "title": "TestFlight sync scaffold requires project-specific implementation",
            "body": body,
            "labels": ["automation", "testflight"],
        },
    )

    print(f"Created issue: {issue.get('html_url', 'unknown')}")


if __name__ == "__main__":
    main()

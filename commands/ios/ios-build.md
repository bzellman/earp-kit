---
description: Build or test the iOS app with formatted output and repo-local artifacts
---

# iOS Build Command

Use the repo-standard wrapper instead of raw `xcodebuild` when the default flow is sufficient.

## Default Commands

```bash
# Build the dev scheme
!./FULLSTACK_SCRIPTS/build-ios-formatted.sh --scheme "<YOUR_APP> Dev"

# Clean + rebuild
!./FULLSTACK_SCRIPTS/build-ios-formatted.sh clean --scheme "<YOUR_APP> Dev"

# Run simulator tests
!./FULLSTACK_SCRIPTS/build-ios-formatted.sh --action test --scheme "<YOUR_APP> Dev"
```

## Custom/Test-Targeted Usage

```bash
!./FULLSTACK_SCRIPTS/build-ios-formatted.sh --action test --scheme "<YOUR_APP> Dev" -- --only-testing:<YOUR_APP>Tests/SomeTests
```

## Notes

- Logs, summaries, and DerivedData stay under `<YOUR_APP>/.build-artifacts/ios/`.
- Do not default to `/tmp` for `-derivedDataPath`.
- For raw custom `xcodebuild` commands, pipe output through `FULLSTACK_SCRIPTS/format-build-log.py`.

$ARGUMENTS

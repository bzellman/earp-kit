---
name: <YOUR_IOS_BUILD>
description: Run <YOUR_APP> iOS builds and simulator tests through FULLSTACK_SCRIPTS/build-ios-formatted.sh and format-build-log.py. Use for build verification, test verification, or xcodebuild failure analysis when working in this repo.
---

# <YOUR_APP> iOS Build

Prefer the repo wrapper over raw `xcodebuild` unless the task truly needs a custom invocation.

## Standard Usage

```bash
./FULLSTACK_SCRIPTS/build-ios-formatted.sh --scheme "<YOUR_APP> Dev"
./FULLSTACK_SCRIPTS/build-ios-formatted.sh clean --scheme "<YOUR_APP> Dev"
./FULLSTACK_SCRIPTS/build-ios-formatted.sh --action test --scheme "<YOUR_APP> Dev"
```

## Targeted Tests

Pass custom `xcodebuild` flags after `--`:

```bash
./FULLSTACK_SCRIPTS/build-ios-formatted.sh --action test --scheme "<YOUR_APP> Dev" -- --only-testing:<YOUR_APP>Tests/SomeTests
```

## Required Practices

- Keep logs and DerivedData under `<YOUR_APP>/.build-artifacts/ios/`.
- Do not default to `/tmp` for `-derivedDataPath`.
- Read the generated `summary.md` first, then inspect `xcodebuild.log` only if the summary is insufficient.
- For raw custom `xcodebuild` commands, pipe output through `FULLSTACK_SCRIPTS/format-build-log.py`.

## Artifacts

Default wrapper output lives under:

```text
<YOUR_APP>/.build-artifacts/ios/<scheme>/<action>/
```

Files:
- `summary.md`
- `xcodebuild.log`
- `DerivedData/`

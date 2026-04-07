# Public Template Threat Model

## Summary

This repository is a public framework catalog, not a running product. The primary risks are:

1. Residual secrets, local paths, or private metadata leaking from the source environment.
2. Unsafe CI/CD or Claude Code defaults being copied into adopter environments without review.
3. Malicious future changes to workflows, hooks, or skill instructions being trusted by adopters.

The highest-risk assets are the GitHub Actions templates, shell helpers, Claude Code settings examples, and any file that can influence agent behavior or local command execution.

## Key Assets

| Asset | Why it matters | Main security objective |
|-------|----------------|-------------------------|
| `workflows/**/*.yml` | Can become executable CI/CD with real credentials when copied | Integrity |
| `.github/actions/**` and `.github/scripts/**` | Helper logic used by workflow templates | Integrity |
| `hooks/session-init.sh` | Can execute locally in a developer session | Integrity |
| `skills/**/SKILL.md` and `agents/**/*.md` | Influence Claude Code behavior and tool usage | Integrity |
| `configs/settings/*.json` | Define Claude Code permission boundaries | Integrity |
| Repository contents and history | Must not contain secrets, PII, or private provenance | Confidentiality |

## Primary Threats

| ID | Threat | Why it matters | Current mitigation |
|----|--------|----------------|--------------------|
| TM-001 | Residual secret or private metadata disclosure | Public repos are scanned aggressively and continuously | Embedded secret tooling removed, nested VCS metadata removed, local-path symlinks removed, secret-drift check added |
| TM-002 | Unsafe workflow adoption | Users may copy CI templates without understanding permissions or placeholders | Actions pinned to SHAs, helper scaffolding included, README documents placeholders and adoption steps |
| TM-003 | Prompt injection through skills, agents, or hooks | Adopters trust these files to shape agent behavior | Public docs emphasize review, settings baseline is narrower, hook is now opt-in |
| TM-004 | Public bot or CI abuse | Comment-triggered automation can burn money or expose credentials | Claude workflow restricted to trusted collaborators and no longer requests OIDC unnecessarily |
| TM-005 | Supply-chain tampering in downloaded tooling | CI scripts that fetch binaries can be subverted if unchecked | Cloud SQL Proxy downloads now verify SHA-256 before execution |

## Review Focus

Security review should concentrate on:

- `workflows/**/*.yml`
- `.github/actions/**`
- `.github/scripts/**`
- `Infrastructure/scripts/**`
- `hooks/session-init.sh`
- `configs/settings/*.json`
- `skills/**/SKILL.md`
- `agents/**/*.md`

## Publish Checklist

Before each public release:

1. Run the secret drift scan: `bash Infrastructure/scripts/check-secret-drift.sh`
2. Confirm there are no symlinks: `find . -type l`
3. Confirm there is no nested VCS metadata: `find . -type d -name '.git.nosync'`
4. Confirm workflow actions are pinned: search for mutable `uses:` refs
5. Confirm docs do not mention local usernames, private repo names, or private product names
6. Review any new shell scripts, hooks, workflow steps, or skill instructions as high-scrutiny changes

## Residual Risk

This repo is safe to publish as a template catalog, but it still assumes a technically literate adopter. The remaining risk is mostly misuse risk:

- adopters may widen permissions beyond the provided baseline
- adopters may copy workflow templates without replacing placeholders correctly
- future contributions could weaken the security posture if review discipline slips

That is acceptable for a public framework repo, but it should be enforced with release-time validation and maintainer review.

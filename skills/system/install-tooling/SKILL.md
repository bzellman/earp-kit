---
name: install-tooling
description: Use when installing new skills or agents from curated lists or GitHub repositories, when the user says "install", "add skill", "add agent", or wants to set up new tooling in their Claude Code environment
---

# Install Tooling

Install skills and agents with project-aware curation. Handles one or many items per invocation.

**Sources:** Curated lists (configurable in `references/curated-sources.md`) and ad-hoc GitHub URLs.

**Pipeline:** Intake → Audit → Install → Patch → Document

**Supports:** Both skills (directory with `SKILL.md`) and agents (single `.md` file with frontmatter). Both go through the same pipeline.

## Phase 1: Intake & Classify

Parse user input into a list of items.

**From curated list name:**
1. Read `references/curated-sources.md` for configured repos.
2. For each source, fetch the directory listing via GitHub API:
   ```bash
   curl -s "https://api.github.com/repos/{owner}/{repo}/contents/{path}?ref=main" \
     -H "Accept: application/vnd.github.v3+json"
   ```
3. Match the requested name against available items.
4. If not found in any source: report "not found in curated sources — provide a GitHub URL."

**From GitHub URL:**
1. Parse URL to extract `owner`, `repo`, `ref`, and `path`.
   - URL format: `https://github.com/{owner}/{repo}/tree/{ref}/{path}`
   - Short format: `owner/repo` + `--path path/to/skill`
2. Fetch and check for `SKILL.md` (→ skill) or single `.md` with `name:`/`description:` frontmatter and `tools:` field (→ agent).

**Listing mode:** When user asks "what's available?" without specifying items:
1. Fetch all curated sources.
2. Check each item against installed skills/agents — annotate `(installed)`.
3. Present grouped by source:
   ```
   Skills from openai/skills (.curated):
   1. skill-a
   2. skill-b (installed)
   3. skill-c

   Skills from openai/skills (.experimental):
   1. exp-skill-a
   2. exp-skill-b (installed)

   Which ones would you like to install?
   ```

**Output per item:** `{name, type: skill|agent, source: curated|github, repo, path, ref}`

## Phase 2: Audit

For each item, run three checks. Read `references/audit-checklist.md` for detailed criteria.

### 2a: Redundancy

Scan installed skills/agents in all four locations:
- `~/.agentConfig/skills/`
- `~/.agentConfig/agents/`
- `.claude/skills./` (if exists)
- `.claude/agents./` (if exists)

Read each item's YAML frontmatter and first 50 lines of body. Classify overlap as: exact duplicate, superset, partial overlap, or complementary. See `references/audit-checklist.md` for classification rules and examples.

### 2b: Value Alignment

Read `CLAUDE.md` to extract the project's tech stack. Compare against the item's description and domain. If the item targets technologies not in the project, produce a soft advisory. Never block — just inform.

### 2c: Conflict Detection

Check if the item's guidance contradicts:
- `CLAUDE.md` conventions and gotchas
- `agent-os/standards/` files matching the item's domain

See `references/audit-checklist.md` for common conflict patterns.

### Audit Report

Present one report per item:
```
Audit Report for: [name] ([skill|agent])
─────────────────────────────────────────
Redundancy:  [NONE | OVERLAP with X (type) — recommendation]
Value:       [ALIGNED | ADVISORY: details]
Conflicts:   [NONE | list with sources]

Proceed? [yes / skip / remove-overlap]
```

Wait for user decision on each item before proceeding.

## Phase 3: Install

### Location Prompt

Always ask before installing:
```
Where should [name] be installed?
  1. Global (~/.agentConfig/skills/ or ~/.agentConfig/agents/)
  2. Repo-local (.claude/skills./ or .claude/agents./)
```

Use the appropriate subdirectory based on item type (skill vs agent).

### Fetch from GitHub

**Step 1 — Direct download (public repos):**
```bash
# Get tree listing
TREE=$(curl -s "https://api.github.com/repos/{owner}/{repo}/git/trees/{ref}?recursive=1" \
  -H "Accept: application/vnd.github.v3+json")

# For skills: download each file in the skill directory
# For agents: download the single .md file
curl -s "https://raw.githubusercontent.com/{owner}/{repo}/{ref}/{filepath}" -o "{local_path}"
```

**Step 2 — Sparse checkout fallback (private repos or download failure):**
```bash
git clone --filter=blob:none --sparse "https://github.com/{owner}/{repo}.git" /tmp/install-tooling-tmp
cd /tmp/install-tooling-tmp
git sparse-checkout set "{path}"
git checkout {ref}
cp -r "{path}" "{destination}"
rm -rf /tmp/install-tooling-tmp
```

If HTTPS clone fails, retry with SSH: `git@github.com:{owner}/{repo}.git`

### Collision Handling

If destination already exists:
```
[name] already exists at [path].
  1. Overwrite (fresh install, regenerate project patches)
  2. Skip
```

Never silently overwrite. If overwriting, any existing `references/project-overrides.md` or skill-local `CLAUDE.md` will be replaced by a freshly generated patch in Phase 4.

### Stale Curated Sources

If a configured curated source path returns a 404 or error, warn the user and skip that source:
```
Warning: Curated source [owner/repo] path [path] returned 404 — skipping.
```
Continue with remaining sources. Do not fail the entire listing.

## Phase 4: Project Patch

Read project context and generate overrides. Skip this phase entirely if the item is fully aligned with the project (no conflicts found in Phase 2 and no project-specific additions needed). Note "no overrides needed" and move on.

### Context Sources (read-only)

1. `CLAUDE.md` — tech stack, coding style, conventions, gotchas
2. `agent-os/standards/` — domain-matching standards (e.g., `ios/state-management.md` for SwiftUI skills)
3. Existing repo-local skills — for pattern consistency in how overrides are written

### For Skills

Create `references/project-overrides.md` inside the skill directory. If the skill already has a `CLAUDE.md` or other project-context file from a prior install, remove it and consolidate all project context into `references/project-overrides.md` — this is the canonical location.

```markdown
# Project Overrides for [Project Name]

## Tech Stack Context
[Key facts from CLAUDE.md relevant to this skill's domain]

## Overrides
[Only items where the skill's defaults conflict with or miss project conventions.
Each override: what the skill says → what the project requires, with source reference.]

## Applicable Standards
[Pointers to relevant agent-os/standards/ files]
```

Append one line to the end of `SKILL.md`:
```
**Project context:** Read `references/project-overrides.md` for project-specific guidance.
```

This pointer line is the only modification to the original SKILL.md.

### For Agents

Append a section to the bottom of the agent `.md` file:

```markdown

## Project Context ([Project Name])

[Relevant project-specific guidance extracted from CLAUDE.md and standards.
Keep concise — agents are single files, context should be <20 lines.]
```

## Phase 5: Documentation

Runs once after all items are processed.

### CLAUDE.md Updates

- **New agents:** Add under the appropriate "Available Agents" subsection (iOS / Backend / Cross-Stack) in CLAUDE.md.
- **New skills with slash commands:** Add to the "Available Slash Commands" table in CLAUDE.md.
- **General-purpose skills:** Do NOT add to CLAUDE.md. They are discoverable via the skill system automatically.

### Removal Cleanup

If redundant items were removed during Phase 2 (user chose "remove-overlap"):
1. Delete the skill directory or agent file.
2. Remove references from CLAUDE.md.
3. If the removed item had `references/project-overrides.md`, migrate relevant overrides to the replacement item.

### Install Summary

Print to user (do not save to file):

```
Install Summary
────────────────
Installed:
  - [name] ([skill|agent], [global|repo-local], [patched with N overrides | no overrides needed])

Removed (redundant):
  - [name] (superseded by [replacement])

Documentation updated:
  - CLAUDE.md: [description of changes]

Restart Claude Code to pick up new skills.
```

## Multiple Items

When installing multiple items in one invocation:
1. Run Phase 1 (Intake) for all items first — build the full list.
2. Run Phase 2 (Audit) for all items — present a combined audit report.
3. After user confirms, run Phase 3-4 (Install + Patch) per item sequentially.
4. Run Phase 5 (Documentation) once at the end.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Installing without checking redundancy | Always run the full audit — even for "obvious" installs |
| Modifying the skill's original SKILL.md body | Only append the project-context pointer line. All overrides go in `references/project-overrides.md` |
| Installing repo-local when the skill is generic | Ask the user every time — don't assume |
| Skipping the patch for agents | Agents go through the same pipeline as skills |
| Forgetting to note "Restart Claude Code" | New skills aren't picked up until restart |

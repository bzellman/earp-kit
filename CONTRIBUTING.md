# Contributing

Contributions are welcome. Here's how to add to the catalog.

## Adding a Skill

1. Create a directory in `skills/system/your-skill-name/`
2. Include a `SKILL.md` file with frontmatter:
   ```yaml
   ---
   name: your-skill-name
   description: One-line description of when this skill triggers
   ---
   ```
3. Add an entry to `skills/README.md`
4. If the skill introduces a novel pattern, add a doc to `patterns/`

## Adding an Agent

1. Create `agents/<domain>/your-agent.md`
2. Include: Role, Capabilities, Constraints, and Context sections
3. Add an entry to `agents/README.md`

## Adding a Command

1. Create `commands/<category>/your-command.md`
2. Add an entry to `commands/README.md`
3. If it's part of a command suite, add to the appropriate subdirectory

## Adding a Workflow

1. Add the `.yml` file to the appropriate `workflows/` subdirectory
2. Add `# TEMPLATE: Replace <YOUR_*> placeholders` header comment
3. Replace all project-specific values with `<YOUR_*>` placeholders
4. Update `docs/ci-cd-catalog.md` with workflow documentation

## Adding a Pattern

1. Create `patterns/your-pattern.md`
2. Include: Overview, How It Works, When to Use, Integration Points, See Also
3. Add a summary to the Key Patterns section of `README.md`

## Sanitization Rules

Before submitting, ensure:
- No API keys, tokens, or credentials
- No GCP project IDs (use `<YOUR_GCP_PROJECT>`)
- No absolute file paths (use relative or `<YOUR_PROJECT_ROOT>`)
- No internal URLs (use `<YOUR_DOMAIN>`)
- No service account emails
- Project-specific items are annotated with `<!-- CUSTOMIZE: description -->` comments

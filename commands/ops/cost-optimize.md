---
description: Guided cost optimization with human-in-the-loop approval
---

# Cost Optimize

Guided cost optimization based on analysis. Requires user approval before making changes.

**Run `/cost-report` first** to identify opportunities, then use this command to apply changes.

## Arguments
Parse `$ARGUMENTS` for target: `compute`, `database`, `storage`, `ai`, or `all` (default)

## Optimization Areas

### 1. Compute Right-sizing
- Compare Cloud Run CPU/memory config vs actual utilization
- Propose scaling parameter adjustments
- Generate Terraform variable changes
- ASK for approval before editing

### 2. Database Right-sizing
- Compare Cloud SQL tier vs actual CPU/connection utilization
- Evaluate HA necessity for non-prod environments
- Propose tier changes
- ASK for approval before editing

### 3. Storage Lifecycle
- Review current lifecycle policies
- Compare with actual access patterns
- Propose lifecycle rule adjustments
- ASK for approval before editing

### 4. AI Cost Reduction
- Review AI operation volumes by type
- Identify opportunities for batching (embeddings)
- Identify opportunities for caching (vision analysis, search)
- Propose code changes for batch/cache strategies
- ASK for approval before code changes

## Important
This command is HUMAN-IN-THE-LOOP. Always present findings with estimated savings, then ask for explicit approval before making any modifications.

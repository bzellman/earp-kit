---
description: Guided performance optimization with human-in-the-loop approval
---

# Performance Optimize

Guided performance optimization based on analysis. Requires user approval before making changes.

**Run `/perf-report` first** to identify issues, then use this command to apply fixes.

## Arguments
Parse `$ARGUMENTS` for target area: `scaling`, `database`, `caching`, or `all` (default)

## Optimization Areas

### 1. Cloud Run Scaling
- Review current min/max instances, CPU, memory
- Compare with utilization data from `/perf-report`
- Propose Terraform changes in `Infrastructure/terraform/environments/{env}/main.tf`
- ASK for approval before editing

### 2. Database Performance
- Check for slow queries in Cloud Logging
- Analyze existing indexes via Cloud SQL Query Insights
- Propose new indexes or query optimizations
- ASK for approval before creating migration files

### 3. Redis Caching
- Identify hot endpoints from request timing metrics
- Suggest caching strategies for frequently accessed data
- Review existing cache TTLs in code
- ASK for approval before code changes

### 4. N+1 Query Detection
- Search for patterns in EF Core code that suggest N+1 queries
- Look for `.Include()` usage and missing eager loading
- Propose fixes with `.Include()` or projection queries
- ASK for approval before code changes

## Important
This command is HUMAN-IN-THE-LOOP. Always present findings and proposed changes, then ask for explicit approval before making any modifications.

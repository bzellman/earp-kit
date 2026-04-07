# `/perf-check`

Legacy compatibility alias.

`/perf-check` has been replaced by:

- `/perf-report` for performance analysis and observability review
- `/perf-optimize` for applying targeted fixes after a report

Recommended usage:

1. Run `/perf-report <environment> <window>` to identify bottlenecks.
2. Run `/perf-optimize <component>` to implement fixes.

If an existing workflow still calls `/perf-check`, treat it as a request to start with `/perf-report`.

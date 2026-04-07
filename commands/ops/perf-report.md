---
description: On-demand system performance analysis across GCP environments
---

# Performance Report

Analyze system performance for the <YOUR_APP> API platform. Defaults to dev environment and last 1 hour.

## Arguments
Parse `$ARGUMENTS` for:
- Environment: `dev` (default), `staging`, `prod`
- Time range: `1h` (default), `6h`, `24h`, `7d`

Example: `/perf-report prod 24h`

## Environment Mapping
| Environment | Project ID | Domain |
|-------------|-----------|--------|
| dev | <YOUR_GCP_PROJECT_DEV> | <YOUR_API_DEV_URL> |
| staging | <YOUR_GCP_PROJECT_STAGING> | <YOUR_API_STAGING_URL> |
| prod | <YOUR_GCP_PROJECT_PROD> | <YOUR_API_PROD_URL> |

## Analysis Steps

### 1. Service Health Check
```bash
# Check health endpoint
curl -s "https://{domain}/health/detailed" | jq .

# Get current Cloud Run revision
gcloud run services describe <YOUR_SERVICE_NAME> --region=us-central1 --project={project} --format='yaml(status.latestReadyRevisionName,spec.template.spec.containers[0].resources,spec.template.metadata.annotations)'
```

### 2. Latency Analysis
```bash
# p50, p90, p95, p99 latency
gcloud monitoring timeseries list \
  --filter='resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND metric.type="run.googleapis.com/request_latencies"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=300s,perSeriesAligner=ALIGN_PERCENTILE_99' \
  --project={project} --format=json | jq '.[0].points[:5]'
```
Run for p50, p90, p95, p99 separately.

### 3. Error Analysis
```bash
# Error count by response code
gcloud monitoring timeseries list \
  --filter='resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND metric.type="run.googleapis.com/request_count"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=3600s,perSeriesAligner=ALIGN_SUM,groupByFields=metric.labels.response_code_class' \
  --project={project} --format=json | jq '.[] | {code: .metric.labels.response_code_class, points: [.points[].value.int64Value]}'

# Recent error logs
gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND severity>=ERROR' \
  --limit=20 --project={project} \
  --format='table(timestamp,jsonPayload.message,textPayload)'
```

### 4. Resource Utilization
```bash
# Cloud Run CPU
gcloud monitoring timeseries list \
  --filter='resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND metric.type="run.googleapis.com/container/cpu/utilizations"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=300s,perSeriesAligner=ALIGN_PERCENTILE_99' \
  --project={project} --format=json | jq '.[0].points[:5]'

# Cloud Run Memory
gcloud monitoring timeseries list \
  --filter='resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND metric.type="run.googleapis.com/container/memory/utilizations"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=300s,perSeriesAligner=ALIGN_PERCENTILE_99' \
  --project={project} --format=json | jq '.[0].points[:5]'

# Cloud SQL CPU
gcloud monitoring timeseries list \
  --filter='resource.type="cloudsql_database" AND metric.type="cloudsql.googleapis.com/database/cpu/utilization"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=300s,perSeriesAligner=ALIGN_MEAN' \
  --project={project} --format=json | jq '.[0].points[:5]'

# Cloud SQL Connections
gcloud monitoring timeseries list \
  --filter='resource.type="cloudsql_database" AND metric.type="cloudsql.googleapis.com/database/postgresql/num_backends"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=300s,perSeriesAligner=ALIGN_MEAN' \
  --project={project} --format=json | jq '.[0].points[:5]'

# Instance count
gcloud monitoring timeseries list \
  --filter='resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND metric.type="run.googleapis.com/container/instance_count"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=300s,perSeriesAligner=ALIGN_MEAN,crossSeriesReducer=REDUCE_SUM' \
  --project={project} --format=json | jq '.[0].points[:5]'
```

### 5. AI Operations (from logs)
```bash
# Recent AI operations
gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND (textPayload=~"Vision analysis" OR textPayload=~"embedding" OR textPayload=~"Podcast generation" OR textPayload=~"Image generation" OR textPayload=~"Video generation")' \
  --limit=30 --project={project} \
  --format='table(timestamp,textPayload)'
```

## Output Format

Generate a structured report:

```
## Performance Report: {environment} ({time_range})
Generated: {timestamp}

### Service Health
- Status: {healthy/degraded/down}
- Revision: {revision_name}
- Resources: {cpu}vCPU / {memory} RAM
- Instance count: {current}

### Latency (SLA target: < 200ms p95)
| Percentile | Value | Status |
|------------|-------|--------|
| p50 | {value}ms | {ok/warn} |
| p90 | {value}ms | {ok/warn} |
| p95 | {value}ms | {ok/warn/BREACH} |
| p99 | {value}ms | {ok/warn} |

### Error Rate
- Total requests: {count}
- 2xx: {count} ({pct}%)
- 4xx: {count} ({pct}%)
- 5xx: {count} ({pct}%)
- Top errors: {list}

### Resource Utilization
| Resource | Current | Threshold | Status |
|----------|---------|-----------|--------|
| CR CPU | {pct}% | 80% | {ok/warn} |
| CR Memory | {pct}% | 80% | {ok/warn} |
| SQL CPU | {pct}% | 80% | {ok/warn} |
| SQL Connections | {count}/{max} | 80% | {ok/warn} |

### AI Operations
- {summary of recent AI operations}

### Recommendations
1. {actionable recommendation}
2. {actionable recommendation}
```

## Notes
- This command is fully autonomous (read-only gcloud commands)
- All gcloud commands require the user to have appropriate IAM permissions
- Time calculations: use `date -u -v-1H +%Y-%m-%dT%H:%M:%SZ` (macOS) for start_time

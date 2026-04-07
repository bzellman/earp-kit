---
description: On-demand cost analysis and optimization recommendations for GCP
---

# Cost Report

Analyze GCP costs and resource utilization for optimization opportunities. Defaults to dev, last 7 days.

## Arguments
Parse `$ARGUMENTS` for:
- Environment: `dev` (default), `staging`, `prod`
- Period: `7d` (default), `30d`

Example: `/cost-report prod 30d`

## Environment Mapping
| Environment | Project ID |
|-------------|-----------|
| dev | <YOUR_GCP_PROJECT_DEV> |
| staging | <YOUR_GCP_PROJECT_STAGING> |
| prod | <YOUR_GCP_PROJECT_PROD> |

## Analysis Steps

### 1. Current Resource Configuration
```bash
# Cloud Run config
gcloud run services describe <YOUR_SERVICE_NAME> --region=us-central1 --project={project} \
  --format='yaml(spec.template.spec.containers[0].resources,spec.template.metadata.annotations)'

# Cloud SQL tier
gcloud sql instances describe {sql_instance} --project={project} \
  --format='yaml(settings.tier,settings.dataDiskSizeGb,settings.dataDiskType,settings.availabilityType)'

# Redis config (if accessible)
gcloud redis instances list --region=us-central1 --project={project} \
  --format='table(name,tier,memorySizeGb,redisVersion)'
```

### 2. Resource Utilization (for right-sizing)
```bash
# Cloud Run billable instance time
gcloud monitoring timeseries list \
  --filter='resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND metric.type="run.googleapis.com/container/billable_instance_time"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=86400s,perSeriesAligner=ALIGN_SUM' \
  --project={project} --format=json | jq '.[] | .points[] | {time: .interval.endTime, value: .value}'

# Cloud Run average CPU utilization
gcloud monitoring timeseries list \
  --filter='resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND metric.type="run.googleapis.com/container/cpu/utilizations"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=86400s,perSeriesAligner=ALIGN_MEAN' \
  --project={project} --format=json | jq '.[0].points[:7]'

# Cloud Run average memory utilization
gcloud monitoring timeseries list \
  --filter='resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND metric.type="run.googleapis.com/container/memory/utilizations"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=86400s,perSeriesAligner=ALIGN_MEAN' \
  --project={project} --format=json | jq '.[0].points[:7]'

# Cloud SQL CPU utilization (daily average)
gcloud monitoring timeseries list \
  --filter='resource.type="cloudsql_database" AND metric.type="cloudsql.googleapis.com/database/cpu/utilization"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=86400s,perSeriesAligner=ALIGN_MEAN' \
  --project={project} --format=json | jq '.[0].points[:7]'

# Cloud SQL disk usage
gcloud monitoring timeseries list \
  --filter='resource.type="cloudsql_database" AND metric.type="cloudsql.googleapis.com/database/disk/bytes_used"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=86400s,perSeriesAligner=ALIGN_MEAN' \
  --project={project} --format=json | jq '.[0].points[:1]'

# Cloud Storage size
gcloud monitoring timeseries list \
  --filter='resource.type="gcs_bucket" AND metric.type="storage.googleapis.com/storage/total_bytes"' \
  --interval='startTime="{start_time}",endTime="{end_time}"' \
  --aggregation='alignmentPeriod=86400s,perSeriesAligner=ALIGN_MEAN' \
  --project={project} --format=json | jq '.[] | {bucket: .resource.labels.bucket_name, bytes: .points[0].value}'
```

### 3. AI Operations Volume
```bash
# AI operations from logs (count by type)
gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND (textPayload=~"Vision analysis completed" OR textPayload=~"embedding" OR textPayload=~"Podcast generation completed" OR textPayload=~"Image generation completed" OR textPayload=~"Video generation")' \
  --limit=100 --project={project} \
  --format='table(timestamp,textPayload)' | head -50
```

### 4. Right-sizing Recommendations
```bash
# Check if Recommender API is available
gcloud recommender recommendations list \
  --project={project} \
  --location=us-central1 \
  --recommender=google.cloudsql.instance.PerformanceRecommender \
  --format='table(name,description,primaryImpact)' 2>/dev/null || echo "Recommender not available"

gcloud recommender recommendations list \
  --project={project} \
  --location=us-central1 \
  --recommender=google.run.service.CostRecommender \
  --format='table(name,description,primaryImpact)' 2>/dev/null || echo "Recommender not available"
```

## Output Format

```
## Cost Report: {environment} ({period})
Generated: {timestamp}

### Resource Configuration
| Resource | Config | Utilization | Assessment |
|----------|--------|-------------|------------|
| Cloud Run | {cpu}vCPU / {memory} | CPU: {pct}%, Mem: {pct}% | {right-sized/over/under} |
| Cloud SQL | {tier}, {disk}GB | CPU: {pct}%, Disk: {used}/{total} | {right-sized/over/under} |
| Redis | {tier}, {size}GB | Mem: {pct}% | {right-sized/over/under} |

### AI Operations Summary
| Operation | Count | Est. Cost |
|-----------|-------|-----------|
| Vision | {count} | ~${cost} |
| Embeddings | {count} | ~${cost} |
| Podcast | {count} | ~${cost} |
| Image (Imagen) | {count} | ~${cost} |
| Video (Veo) | {count} | ~${cost} |

### Storage Usage
| Bucket | Size | Monthly Growth |
|--------|------|----------------|
| {bucket} | {size} | {growth} |

### Optimization Recommendations
1. {recommendation with estimated savings}
2. {recommendation with estimated savings}

### GCP Recommender Suggestions
{output from recommender API, if available}
```

## Notes
- Read-only analysis is fully autonomous
- Any recommended changes require user approval
- Cost estimates are approximate based on public GCP pricing

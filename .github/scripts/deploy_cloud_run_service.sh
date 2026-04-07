#!/usr/bin/env bash
set -euo pipefail

required_vars=(
  GCP_PROJECT_ID
  REGION
  SERVICE_NAME
  PRIMARY_IMAGE
)

for name in "${required_vars[@]}"; do
  if [ -z "${!name:-}" ]; then
    echo "::error::Missing required environment variable: ${name}"
    exit 1
  fi
done

cmd=(
  gcloud run deploy "$SERVICE_NAME"
  --image "$PRIMARY_IMAGE"
  --region "$REGION"
  --project "$GCP_PROJECT_ID"
  --quiet
)

if [ -n "${SERVICE_ACCOUNT:-}" ]; then
  cmd+=(--service-account "$SERVICE_ACCOUNT")
fi

if [ -n "${PORT:-}" ]; then
  cmd+=(--port "$PORT")
fi

if [ -n "${CPU:-}" ]; then
  cmd+=(--cpu "$CPU")
fi

if [ -n "${MEMORY:-}" ]; then
  cmd+=(--memory "$MEMORY")
fi

if [ -n "${MIN_INSTANCES:-}" ]; then
  cmd+=(--min-instances "$MIN_INSTANCES")
fi

if [ -n "${MAX_INSTANCES:-}" ]; then
  cmd+=(--max-instances "$MAX_INSTANCES")
fi

if [ "${ALLOW_UNAUTHENTICATED:-false}" = "true" ]; then
  cmd+=(--allow-unauthenticated)
else
  cmd+=(--no-allow-unauthenticated)
fi

"${cmd[@]}"

if [ -n "${COLLECTOR_IMAGE:-}" ]; then
  echo "::notice::COLLECTOR_IMAGE is set to '${COLLECTOR_IMAGE}'."
  echo "::notice::Configure multi-container Cloud Run revisions via Terraform or extend this script for your service manifest."
fi

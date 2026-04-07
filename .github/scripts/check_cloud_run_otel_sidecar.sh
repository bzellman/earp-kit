#!/usr/bin/env bash
set -euo pipefail

required_vars=(
  GCP_PROJECT_ID
  REGION
  SERVICE_NAME
)

for name in "${required_vars[@]}"; do
  if [ -z "${!name:-}" ]; then
    echo "::error::Missing required environment variable: ${name}"
    exit 1
  fi
done

if [ -z "${EXPECTED_COLLECTOR_IMAGE:-}" ]; then
  echo "::notice::EXPECTED_COLLECTOR_IMAGE is not set; skipping sidecar verification."
  exit 0
fi

SERVICE_JSON="$(gcloud run services describe "$SERVICE_NAME" \
  --project "$GCP_PROJECT_ID" \
  --region "$REGION" \
  --format=json)"

FOUND_IMAGE="$(printf '%s' "$SERVICE_JSON" | jq -r '
  .spec.template.spec.containers // []
  | map(select(.image == env.EXPECTED_COLLECTOR_IMAGE))
  | .[0].image // empty
')"

if [ "$FOUND_IMAGE" = "$EXPECTED_COLLECTOR_IMAGE" ]; then
  echo "OTel sidecar image is present: $FOUND_IMAGE"
  exit 0
fi

echo "::error::Expected OTel collector image '${EXPECTED_COLLECTOR_IMAGE}' was not found on service '${SERVICE_NAME}'."
echo "::error::If your platform manages sidecars through Terraform, verify the deployed service spec before promoting."
exit 1

#!/usr/bin/env bash
set -euo pipefail

BASE_URL=${1:-}
if [[ -z "$BASE_URL" ]]; then
  if command -v terraform >/dev/null 2>&1; then
    PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    BASE_URL=$(terraform -chdir="$PROJECT_DIR" output -raw app_url)
  else
    echo "Usage: $0 <app-url>" >&2
    exit 1
  fi
fi

BASE_URL=${BASE_URL%/}

for ((attempt = 1; attempt <= 30; attempt++)); do
  if response=$(curl --fail --silent --show-error --max-time 10 "$BASE_URL/api/health" 2>/dev/null) &&
     page=$(curl --fail --silent --show-error --max-time 10 "$BASE_URL/" 2>/dev/null) &&
     [[ "$page" == *"Frontend and backend are running."* ]]; then
    echo "Smoke test passed: $response"
    exit 0
  fi
  sleep 5
done

echo "Smoke test failed for $BASE_URL/api/health" >&2
exit 1

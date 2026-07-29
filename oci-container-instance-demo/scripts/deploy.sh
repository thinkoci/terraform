#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$PROJECT_DIR"

command -v terraform >/dev/null 2>&1 || {
  echo "terraform is required but was not found in PATH" >&2
  exit 1
}
command -v python3 >/dev/null 2>&1 || {
  echo "python3 is required but was not found in PATH" >&2
  exit 1
}
command -v curl >/dev/null 2>&1 || {
  echo "curl is required by the post-deploy smoke test but was not found in PATH" >&2
  exit 1
}

terraform init
terraform fmt -recursive
terraform validate
terraform apply "$@"

APP_URL=$(terraform output -raw app_url)
printf '\nApplication URL: %s\n' "$APP_URL"
"$PROJECT_DIR/scripts/smoke-test.sh" "$APP_URL"

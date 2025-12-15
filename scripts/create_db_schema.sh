#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "ERROR: DATABASE_URL is not set."
  echo "Set it to your Postgres connection string, e.g.:"
  echo "  export DATABASE_URL=\"postgres://user:password@localhost:5432/voice_agent\""
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Applying schema from ${PROJECT_ROOT}/db/schema.sql to ${DATABASE_URL}"

psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -f "${PROJECT_ROOT}/db/schema.sql"

echo "✅ Database schema applied successfully."



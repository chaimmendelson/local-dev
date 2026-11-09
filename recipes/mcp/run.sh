#!/usr/bin/env bash
# Tandoor MCP. Reads .env.
set -euo pipefail
cd "$(dirname "$0")/../.."
set -a; . ./.env; set +a
export TANDOOR_BASE_URL="http://127.0.0.1:${TANDOOR_PORT:-6060}"
export TANDOOR_API_TOKEN="${TANDOOR_API_TOKEN:?set in .env}"
exec ./recipes/mcp/dist/tandoor-mcp

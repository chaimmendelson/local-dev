#!/usr/bin/env bash
# Keycloak admin MCP (community: paoloamato2/keycloak-mcp-server), pinned to an
# exact commit and run through uvx - nothing to build. Reads .env.
# mcp is pinned to the version in the repo's uv.lock (1.27.0): uvx ignores the
# lockfile and the latest mcp (2.x) breaks this server (no Server.list_tools).
# NOTE: it exposes ALL Keycloak admin endpoints (incl. writes). Local dev only.
set -euo pipefail
cd "$(dirname "$0")/../.."
set -a; . ./.env; set +a
export KEYCLOAK_URL="http://127.0.0.1:${KEYCLOAK_PORT:-8081}"
export KEYCLOAK_ADMIN_REALM=master
export KEYCLOAK_ADMIN_USERNAME="${KEYCLOAK_ADMIN_USERNAME:?set in .env}"
export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:?set in .env}"
exec uvx --with "mcp==1.27.0" --from "git+https://github.com/paoloamato2/keycloak-mcp-server@d602e32455dd018984a442f72aa0e06b8884551a" keycloak-mcp-server

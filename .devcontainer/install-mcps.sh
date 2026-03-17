#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Adding MCP servers..."
claude mcp add MCP_DOCKER --scope user -- docker mcp gateway run
claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: ${CONTEXT7_API_KEY:-}"
echo "✅ MCP servers configured."

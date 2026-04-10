#!/usr/bin/env bash
# Hook: UserPromptSubmit
#
# Fires on every user message. Searches Memoric for relevant memories
# and injects them into Claude's context before processing.
#
# Auth: reads OAuth token from ~/.claude/.credentials.json (mcpOAuth)
# Falls back to MEMORIC_API_KEY env var if OAuth token not found.
#
# Skips search for very short prompts (< 20 chars).
# Uses a 3s timeout to minimize latency.

set -uo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null || echo "")

# Skip trivial prompts
if [ ${#PROMPT} -lt 20 ]; then
  exit 0
fi

# Try OAuth token from Claude Code credentials
CREDS_FILE="$HOME/.claude/.credentials.json"
API_KEY=""
if [ -f "$CREDS_FILE" ]; then
  API_KEY=$(jq -r '[.mcpOAuth | to_entries[] | select(.key | test("memoric";"i")) | .value.accessToken] | first // empty' "$CREDS_FILE" 2>/dev/null || echo "")
fi

# Fall back to env var
if [ -z "$API_KEY" ]; then
  API_KEY="${MEMORIC_API_KEY:-}"
fi

if [ -z "$API_KEY" ]; then
  exit 0
fi

# Build curl args — only include user_id if explicitly set
CURL_ARGS=(-s --max-time 3 -G "https://memoric.dev/v1/memories/search" --data-urlencode "q=$PROMPT" -d "limit=5" -H "Authorization: Bearer $API_KEY")
if [ -n "${MEMORIC_USER_ID:-}" ]; then
  CURL_ARGS+=(-d "user_id=$MEMORIC_USER_ID")
fi

# Search Memoric for memories relevant to this prompt
RESPONSE=$(curl "${CURL_ARGS[@]}" 2>/dev/null || echo "")

if [ -z "$RESPONSE" ]; then
  exit 0
fi

# Extract memories from response
MEMORIES=$(echo "$RESPONSE" | jq -r '
  .results // [] |
  if length == 0 then empty else
  "## Relevant memories from Memoric\n\n" +
  (map(select(.content != null) | "- " + .content) | join("\n"))
  end
' 2>/dev/null || echo "")

if [ -n "$MEMORIES" ]; then
  echo "$MEMORIES"
fi

exit 0

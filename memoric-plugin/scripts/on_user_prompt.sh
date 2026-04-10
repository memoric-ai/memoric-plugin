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
API_KEY=""
CREDS_FILE="$HOME/.claude/.credentials.json"
if [ -f "$CREDS_FILE" ]; then
  API_KEY=$(python3 -c "
import json, sys
try:
    with open('$CREDS_FILE') as f:
        creds = json.load(f)
    oauth = creds.get('mcpOAuth', {})
    for key, val in oauth.items():
        if 'memoric' in key.lower():
            print(val.get('accessToken', ''))
            break
except:
    pass
" 2>/dev/null || echo "")
fi

# Fall back to env var
if [ -z "$API_KEY" ]; then
  API_KEY="${MEMORIC_API_KEY:-}"
fi

if [ -z "$API_KEY" ]; then
  exit 0
fi

USER_ID="${MEMORIC_USER_ID:-${USER:-default}}"

# Search Memoric for memories relevant to this prompt
RESPONSE=$(curl -s --max-time 3 \
  -G "https://memoric.dev/v1/memories/search" \
  --data-urlencode "q=$PROMPT" \
  -d "limit=5" \
  -d "user_id=$USER_ID" \
  -H "Authorization: Bearer $API_KEY" \
  2>/dev/null || echo "")

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

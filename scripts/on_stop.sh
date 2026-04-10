#!/usr/bin/env bash
# Hook: Stop
#
# Fires when Claude finishes responding.
# Reminds Claude to store unsaved learnings, then spawns a background
# process to capture transcript state via the Memoric REST API.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

cat <<'EOF'
Before finishing, check if there are important learnings from this interaction that should be persisted using the Memoric `add_memory` tool:

1. Were any significant decisions made? -> Store with metadata `{"type": "decision"}`
2. Were any new patterns or strategies discovered? -> Store with metadata `{"type": "lesson"}`
3. Did any approach fail? -> Store with metadata `{"type": "anti_pattern"}`
4. Did you learn anything about the user's preferences? -> Store with metadata `{"type": "preference"}`
5. Were there environment/setup discoveries? -> Store with metadata `{"type": "fact"}`

Include full context, reasoning, file paths, and examples. Longer, searchable memories are more valuable than vague one-liners.

If nothing notable happened, skip. Only store genuinely useful learnings.
EOF

# Capture transcript state in the background via Memoric REST API
echo "$INPUT" | python3 "$SCRIPT_DIR/on_pre_compact.py" --source=session-end 2>/dev/null &

exit 0

#!/usr/bin/env bash
# Hook: SessionStart (matcher: startup|resume|compact)
#
# Bootstraps Memoric context at the start of every session.
# Output becomes part of Claude's context so it uses Memoric MCP tools.

set -uo pipefail

INPUT=$(cat)
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"' 2>/dev/null || echo "startup")

if [ "$SOURCE" = "startup" ]; then
  cat <<'EOF'
## Memoric Session Bootstrap

You have access to persistent memory via the Memoric MCP tools. Before doing anything else:

1. Call `search_memories` with a query related to the current project or task to load relevant context.
2. Review the returned memories to understand what has been learned in prior sessions.
3. Use memories to inform your approach — don't re-discover things you already know.

IMPORTANT: Always search for relevant context before starting work.
EOF

elif [ "$SOURCE" = "resume" ]; then
  cat <<'EOF'
## Memoric Session Resumed

This is a resumed session. Before continuing:

1. Call `search_memories` with a query related to the current task to refresh relevant memories.
2. If significant time has passed, search for recent session state memories.

Continue where you left off.
EOF

elif [ "$SOURCE" = "compact" ]; then
  cat <<'EOF'
## Memoric Post-Compaction Recovery

Context was just compacted. You may have lost important session context.

1. Call `search_memories` with queries related to what you were working on to reload relevant knowledge.
2. Search for memories with type "session_state" for pre-compaction summaries.
3. Continue working based on the recovered context.
EOF
fi

exit 0

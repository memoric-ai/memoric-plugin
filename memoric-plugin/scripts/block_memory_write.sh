#!/usr/bin/env bash
# Hook: PreToolUse (matcher: Write|Edit)
#
# Blocks writes to MEMORY.md and auto-memory files, redirecting Claude
# to use the Memoric MCP add_memory tool instead.
#
# Exit codes:
#   0 = allow the tool call
#   2 = block the tool call (stderr shown to Claude as feedback)

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

case "$FILE_PATH" in
  */MEMORY.md|*/memory/*.md|*/.claude/*/memory/*)
    echo "BLOCKED: Do not write to $FILE_PATH. Use the Memoric MCP \`add_memory\` tool instead to persist memories. This project uses Memoric for all memory storage." >&2
    exit 2
    ;;
  *)
    exit 0
    ;;
esac

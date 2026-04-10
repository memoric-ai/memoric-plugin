---
name: memoric
description: >
  Integrate Memoric into AI applications for persistent memory, semantic search, and intelligent deduplication.
  Use this skill when the user mentions "memoric", "memory layer", "remember", "persistent context",
  "personalization", or needs to add long-term memory to agents, chatbots, or AI workflows.
  Covers REST API and MCP integration. Use even when the user doesn't explicitly say "memoric"
  but describes needing conversation memory, context retention, or knowledge retrieval across sessions.
license: MIT
metadata:
  author: memoric
  version: "1.0.0"
  category: ai-memory
  tags: "memory, personalization, ai, semantic-search, deduplication"
compatibility: Requires MEMORIC_API_KEY env var and internet access to memoric.dev
---

# Memoric Integration

Memoric is a persistent memory layer for AI agents. It stores, searches, and deduplicates memories via API — no infrastructure to deploy.

## Step 1: Get your API key

Sign up at https://memoric.dev and create an API key from the dashboard.

```bash
export MEMORIC_API_KEY="mk_your-api-key"
```

## Step 2: Connect via MCP (recommended)

**Claude Code:**
```bash
claude mcp add --transport http memoric https://memoric.dev/mcp --header "Authorization:Bearer $MEMORIC_API_KEY"
```

**Cursor (.cursor/mcp.json):**
```json
{
  "mcpServers": {
    "memoric": {
      "url": "https://memoric.dev/mcp",
      "headers": { "Authorization": "Bearer ${MEMORIC_API_KEY}" }
    }
  }
}
```

## Step 3: Core operations

Memoric follows a simple pattern: **store → search → use**.

### Add a memory
```bash
curl -X POST https://memoric.dev/v1/memories \
  -H "Authorization: Bearer $MEMORIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content": "User prefers TypeScript and dark mode", "user_id": "alice"}'
```

Memoric automatically deduplicates — if a similar memory exists, it merges instead of creating a duplicate.

### Search memories
```bash
curl https://memoric.dev/v1/memories/search \
  -H "Authorization: Bearer $MEMORIC_API_KEY" \
  -G -d "q=what+are+the+user+preferences" -d "user_id=alice"
```

Returns memories ranked by semantic similarity.

### List all memories
```bash
curl https://memoric.dev/v1/memories \
  -H "Authorization: Bearer $MEMORIC_API_KEY"
```

### Delete a memory
```bash
curl -X DELETE https://memoric.dev/v1/memories/MEMORY_ID \
  -H "Authorization: Bearer $MEMORIC_API_KEY"
```

## MCP Tools (when connected via MCP)

| Tool | Purpose |
|------|---------|
| `add_memory` | Store a memory with intelligent deduplication |
| `search_memories` | Search by semantic similarity |
| `get_memories` | List stored memories |
| `delete_memory` | Delete a memory by ID |

## Common integration pattern

```python
import requests

MEMORIC_API_KEY = "mk_your-key"
BASE = "https://memoric.dev/v1"
HEADERS = {"Authorization": f"Bearer {MEMORIC_API_KEY}", "Content-Type": "application/json"}

def chat_with_memory(user_input: str, user_id: str) -> str:
    # 1. Search for relevant context
    search = requests.get(f"{BASE}/memories/search",
        headers=HEADERS, params={"q": user_input, "user_id": user_id})
    context = "\n".join(m["content"] for m in search.json().get("results", []))

    # 2. Generate response with your LLM (using context)
    response = generate_with_llm(user_input, context)

    # 3. Store the interaction
    requests.post(f"{BASE}/memories", headers=HEADERS,
        json={"content": f"User asked: {user_input}. Response: {response}", "user_id": user_id})

    return response
```

## Scoping

Memories can be scoped by entity to keep them organized:

| Parameter | Use for |
|-----------|---------|
| `user_id` | Per-user memories (preferences, history) |
| `agent_id` | Per-agent memories (learned behaviors) |
| `app_id` | Per-application memories |
| `run_id` | Per-session memories |

## Memory types

Use metadata to categorize memories:

| Type | When to use |
|------|------------|
| `decision` | Architectural or design choices |
| `lesson` | Strategies that worked |
| `anti_pattern` | Approaches that failed |
| `preference` | User preferences |
| `fact` | Important context or information |
| `convention` | Coding or process conventions |
| `session_state` | Pre-compaction session summaries |

## Pricing

| Tier | Adds/month | Search | Price |
|------|-----------|--------|-------|
| Free | 10,000 | Unlimited | $0 |
| Starter | 50,000 | Unlimited | $9/mo |
| Pro | 500,000 | Unlimited | $199/mo |

Search is unlimited at every tier.

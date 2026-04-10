# Memoric Plugin

Persistent memory for AI agents. Store, retrieve, and manage memories across sessions with intelligent deduplication and semantic search.

Works with **Claude Code**, **Cursor**, and **Codex**.

## Step 1: Get your API key

1. Sign up at [memoric.dev](https://memoric.dev)
2. Create an API key from the dashboard
3. Add it to your shell profile:

```bash
# zsh (macOS default)
echo 'export MEMORIC_API_KEY="mk_your_key"' >> ~/.zshrc
source ~/.zshrc

# bash
echo 'export MEMORIC_API_KEY="mk_your_key"' >> ~/.bashrc
source ~/.bashrc
```

## Step 2: Install the plugin

### Claude Code

```
/install-plugin memoric-ai/memoric-plugin
```

This installs the MCP server, lifecycle hooks, and skills automatically.

### Cursor

Add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "memoric": {
      "url": "https://memoric.dev/mcp",
      "headers": {
        "Authorization": "Bearer ${env:MEMORIC_API_KEY}"
      }
    }
  }
}
```

### Codex

Add to your Codex MCP config:

```json
{
  "mcpServers": {
    "memoric": {
      "url": "https://memoric.dev/mcp",
      "bearer_token_env_var": "MEMORIC_API_KEY"
    }
  }
}
```

## Verify it works

Start a new session and ask: *"Search my memories for hello"*

If the `memoric` tools appear and respond, you're all set.

## What's included

| Component | Claude Code | Cursor | Codex |
|-----------|:-----------:|:------:|:-----:|
| MCP Server (cloud) | Yes | Yes | Yes |
| Lifecycle Hooks | Yes | No | No |
| Skills | Yes | No | Yes |

- **MCP Server** — Cloud-hosted at `memoric.dev/mcp`. No local dependencies.
- **Lifecycle Hooks** — Automatic memory capture at session start, compaction, task completion, and session end.
- **Skills** — Guides the AI on how to use Memoric effectively.

## MCP Tools

| Tool | Description |
|------|-------------|
| `add_memory` | Store a memory with intelligent deduplication |
| `search_memories` | Semantic search across stored memories |
| `get_memories` | List stored memories with optional filters |
| `delete_memory` | Delete a memory by ID |

## Links

- [Dashboard](https://memoric.dev/dashboard)
- [Website](https://memoric.dev)

## License

MIT

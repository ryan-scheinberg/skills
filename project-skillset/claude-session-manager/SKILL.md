---
name: Claude Session Manager
description: Spawn and manage multiple independent Claude --remote-control sessions. Each is controllable from terminal and ios Claude simultaneously. Use when Ryan wants to dispatch remote sessions.
---

Spawn independent `claude --remote-control` sessions in Terminal windows.

## Quick Start

Spawn 3 sessions:

```bash
bash scripts/spawn.sh Worker1 ~/project haiku
bash scripts/spawn.sh Worker2 ~/project claude-opus-4-7[1m]
bash scripts/spawn.sh Worker3 ~/project sonnet
```

List sessions:

```bash
bash scripts/list.sh
```

Shut down a session:

```bash
bash scripts/shutdown.sh Worker1
```

## How It Works

Each spawned session:
- Runs in a new Terminal window (visible and interactive)
- Can be controlled from terminal directly or from phone
- Changes sync bidirectionally across terminal and remote

Sessions are registered in `~/.claude/session-registry.json` — managed automatically, no manual editing needed

Note: Multiple dispatcher agents may spawn sessions concurrently. `list.sh` shows all registered sessions regardless of which dispatcher created them. Only clean up extra sessions if Ryan requests it

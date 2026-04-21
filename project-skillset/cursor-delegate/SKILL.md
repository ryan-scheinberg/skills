---
name: cursor-delegate
description: Delegate tasks to Composer 2 agent. Use this different model to code, QA, attack your design, catch blind spots, or explore alternatives.
---

Spawn a Composer 2 job on a task. Runs async in background so your chat isn't blocked. Max 2 concurrent jobs per Claude session

**Important**: Composer has no session history, but will draw on agent skills. Give it full context: what branch/files to work with, what you've tried, what you want back, and where to write results. Set the workspace to the project it needs to read or edit

## Usage

Spawn a job (returns job_id):
```bash
bash scripts/delegate.sh "I'm on branch feature/auth in this repo. QA my changes for bugs and edge cases." ~/my-project
bash scripts/delegate.sh "Read docs/plan.md. Write a revised version addressing [issues] to docs/plan-v2.md." ~/my-project
```

Poll for results:
```bash
bash scripts/status.sh cursor-1234567890-5678
```

List your active jobs:
```bash
bash scripts/list.sh
```

## How it works

- `delegate.sh` spawns Composer 2 in background with `--trust` (edit mode) and returns a `job_id`
- Output streams to `/tmp/cursor-delegate-<job_id>.log`
- `status.sh` returns `running` or `done` + full JSON output
- Jobs end on their own (no shutdown needed)
- Registry at `~/.claude/cursor-registry.json` tracks jobs per Claude session (resolved by walking the process tree to the ancestor `claude` process). Do not manually edit unless asked

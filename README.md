# Cursor Skills

SOPs for agents. Reusable, composable skills for building projects top-to-bottom with AI — from napkin idea to production.

## Skills

| Skill | What It Does |
|---|---|
| `define-project` | Take a few sentences and produce a complete `PROJECT_BRIEF.md` |
| `iterate-plan` | Challenge every assumption in an artifact until every decision is resolved |
| `plan-to-jira` | Translate a brief into right-sized Jira tickets (epic + stories or standalone story) |
| `complete-ticket` | Implement a Jira story end-to-end with TDD |

## The Pipeline

```
define-project → iterate-plan → plan-to-jira → complete-ticket
```

## Install

Clone into `~/.cursor/skills/` or copy individual skill directories there. Each skill is a directory with a `SKILL.md` that Cursor picks up automatically.

## License

MIT

# Skills

Personal agent skills: reusable `SKILL.md` workflows for Claude Code, Cursor, and similar tooling. This repo is the **source of truth**; nested **skillset** folders keep things organized in git, while your machine uses a **flat** layout under `~/.claude/skills/` and `~/.cursor/skills/`.

## Install

```bash
git clone <this-repo-url> ~/Documents/skills   # or anywhere you like
cd ~/path/to/skills
./setup-skills.sh
```

Re-run `./setup-skills.sh` whenever you add, move, or rename a skill directory so symlinks stay correct.

## Skills in this repo

| Skill | Role |
| --- | --- |
| `claude-session-manager` | Spawn and manage multiple independent `--remote-control` sessions |
| `complete-slice` | Implement a vertical slice from `SLICES.md` end-to-end with TDD |
| `cursor-delegate` | Delegate async tasks to Composer 2 for adversarial review, alternative solutions, or independent analysis |
| `define-project` | Turn a short idea into a full `PROJECT_BRIEF.md` |
| `iterate-plan` | Stress-test a plan or brief until decisions are settled |
| `plan-to-slices` | Break a `PROJECT_BRIEF.md` into vertical, TDD-ready slices |
| `updating-ai-knowledge` | When and how to update skills and repo `AGENTS.md` after friction |
| `skillscake-marketing` | Marketing copy for SkillsCake |
| `skillscake-marketing-ideation` | Structured marketing angles from notes and signals |
| `skillscake-marketing-production` | Turn angles into drafts and publishing workflows |

## Layout

- **`project-skillset/`** — project workflow skills (briefs, slices, TDD, knowledge upkeep).
- **`skillscake-skillset/`** — SkillsCake marketing skills.
- **Gitignored paths** — Optional local-only skill trees (not in git) are still linked by `./setup-skills.sh` when present on disk.

Each skill is a directory whose **name** matches the `name:` field in `SKILL.md` and becomes the flat symlink name under `~/.claude/skills/` and `~/.cursor/skills/`.

## Ops for agents

See **`AGENTS.md`** for symlink behavior, uniqueness rules, and pointers to `updating-ai-knowledge`.

## License

MIT

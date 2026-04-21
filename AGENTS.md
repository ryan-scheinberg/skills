# Skills repo — agent notes

This repository is the **source of truth** for personal agent skills. The tree is grouped by skillset folders (e.g. `project-skillset/`, `skillscake-skillset/`), but **loaders expect a flat list of skill directories** (each directory contains a `SKILL.md`).

## Install / refresh symlinks

From the repo root (`setup-skills` is Python 3 so it runs on macOS’s default Bash without Bash 4+ features):

```bash
./setup-skills
```

This discovers every directory that contains a `SKILL.md` at any depth under the repo root (skipping `.git/`), including trees that are not tracked by git, then:

- Creates **flat** symlinks under `~/.claude/skills/<skill-name>/` and `~/.cursor/skills/<skill-name>/`, where `<skill-name>` is the **folder name** (parent of `SKILL.md`).
- Removes **stale** symlinks in those directories that pointed at paths under this repo (e.g. after a skill folder was removed or renamed).

Re-run after adding, moving, or renaming a skill folder. Optional: `./setup-skills --dry-run` to print actions without changing anything.

**Constraint:** two skill folders with the same basename anywhere in the repo will fail the script — names must be unique across the tree.

## Editing skills

When you fix friction and the right place to capture it is a skill (cross-repo tool/platform knowledge), follow **`updating-ai-knowledge`** — especially: do not change the YAML `name:` field (it aligns with symlink names and loaders), and prefer small, evidence-based edits.

**Always keep README.md in sync** with new skills and major changes. The README is the canonical reference for available skillsets.

---
name: updating-ai-knowledge
description: Guidance for updating agent files when you discover they are wrong, incomplete, or stale. Use when you've solved a problem that revealed a gap or when the user says to update a skill or AGENTS.md. The trigger is friction; you learned something that the knowledge base should have told you.
---

## The friction

You hit something the knowledge base should have warned you about. Before editing anything, articulate the gap in one sentence: *"This file says X, but the correct behavior is Y."* If you can't say that yet, you don't have the fix yet — synthesize from what the session already produced.

## Where it belongs

Ask: *"Would this be true if I were working in a different repo?"*

- **Yes** → a personal skill in git repo `~/Documents/skills/`, grouped by skillset folder (`project-skillset/`, `harness-skillset/`, `skillscake-skillset/`). Run `./setup-skills.sh` to update symlinks after adding or moving a skill directory.
- **No** → `AGENTS.md` at the affected repo root. Nearest file wins; most agents read it automatically.

## Making the edit

**Read the full skill directory or `AGENTS.md` file first.** Then make the smallest edit that closes the gap. Preserve everything accurate. Restructure only if the structure itself caused the confusion.

**Write with reasoning, not just rules.** *"Use `--runInBand` because tests share a database and parallel runs corrupt each other"* is durable. *"Always use `--runInBand`"* is fragile — it breaks the moment the flag name changes or someone needs to know why. Reasoning survives cases your example doesn't cover.

If you reach for all-caps emphasis or absolute prohibitions, pause and ask whether explaining the consequence would be clearer.

## Skill constraints

- Don't change the `name:` field — it's tied to symlinks and the loader.
- Update `description:` only if triggering is wrong (fires when it shouldn't, or doesn't fire when it should).

## Example calls

- Jira skill has a wrong field name → skill.
- Repo needs `npm ci` before tests but `AGENTS.md` doesn't say so → AGENTS.md.
- Terraform module changed its variable interface → skill.
- Build kept failing because of an undocumented env var → AGENTS.md.
- `iterate-plan` asked shallow clarifying questions and missed the real trade-off → skill (what kinds of questions surface hard decisions).

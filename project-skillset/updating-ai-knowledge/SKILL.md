---
name: updating-ai-knowledge
description: Guidance for updating agent files when you discover they are wrong, incomplete, or stale. Use when you've solved a problem that revealed a gap, when the user says to update a skill or AGENTS.md, or when you find a platform or API change that contradicts documented guidance. The trigger is friction; you learned something that the knowledge base should have told you.
---

## Why this matters

A skill or AGENTS.md gets read by agents across many sessions. One wrong fact wastes time every time it fires. One clean correction pays forward to every future agent. That's why updates should be small, precise, and grounded in what you actually observed — not speculative improvements or wholesale rewrites.

## Two knowledge layers

### Personal skills

Cross-repo knowledge about tools, platforms, and workflows — things that are true regardless of which project you're working in.

**When**: You hit friction in any repo and the fix is about how a tool or platform works, not about how that codebase is structured. "The Jira API requires bearer auth on this instance." "GitLab template projects need the default branch set to `develop` after creation."

**Where to edit**: Skills are version-controlled in ~/Documents/skills/ and symlinked into skills directories. Edit the skills/ git repo after reading its AGENTS.md

```
<skills-repo>/
  project-skillset/       # workflow skills (define-project, plan-to-slices, updating-ai-knowledge, etc.)
  skillscake-skillset/    # SkillsCake marketing skills
```

Gitignored directories under the clone can hold extra skills locally; `./setup-skills` still picks them up.

Each skill directory contains a `SKILL.md` and optionally supporting files. The repo is nested for organization; loaders use a flat `~/.claude/skills/` and `~/.cursor/skills/`. After adding or moving a skill directory, run `./setup-skills` from the repo root to refresh symlinks.

**Constraints when editing a skill**:
- Do not change the `name` field — it's tied to symlinks and the loader.
- Update the `description` only if it causes incorrect triggering (firing when it shouldn't, or not firing when it should).

### AGENTS.md (repo-level)

Project-specific context that every agent needs to work effectively in a given repository. The standard (from agents.md, now under the Linux Foundation's Agentic AI Foundation) is a plain Markdown file at the repo root — no required fields, just what helps an agent work without re-exploring from scratch.

**When**: You discovered something repo-specific that cost you time. A build step that requires a non-obvious prerequisite. A test flag that's always needed. A convention the codebase follows that isn't obvious from the code. If stating it in AGENTS.md would have saved you the detour, it belongs there.

**What goes in it** (the most useful sections):
- Setup and build commands — exact commands, in order, with known failure modes noted
- Test commands — how to run the suite, how to run a single test
- Code style and conventions — patterns the codebase enforces
- Architecture overview — key directories and what lives where
- PR / commit conventions — title formats, pre-commit checks required
- Security or deployment gotchas

**How it works**: The nearest `AGENTS.md` in the directory tree takes precedence. Agents (Copilot, Claude, Cursor, Gemini CLI, Devin, and most others) read it automatically. Agents will actually attempt to run commands listed in it. Explicit user instructions override it.

**Constraints**: Treat it as living documentation. Keep it focused on what an agent needs, not what a human contributor needs (that's what README is for).

## How to choose between them

"Would this be true if I were working in a different repo?"
- **Yes** → personal skill
- **No** → AGENTS.md in the affected repo

## Finding the minimal true fact

Before editing anything, articulate the gap in one sentence: "This file says X, but the correct behaviour is Y." If you can't say that yet, synthesize from what the session already produced:

- **Terminal / command history** — what failed or needed correcting?
- **Chat history** — what did you have to figure out that should have been documented?
- **Codebase** — do existing patterns contradict the guidance?
- **External docs** — has a dependency, API, or platform changed?

## Making and writing the change

Read the full file first. Then make the smallest edit that closes the gap — one fact, one correction, one example. Preserve everything accurate. Restructure only if the structure itself caused confusion.

Use `replace_string_in_file` with 3–5 lines of context. Re-read the changed section after editing to confirm it flows naturally in context.

**Write with reasoning, not just rules.** "Use `--runInBand` because tests share a database and parallel runs corrupt each other" is durable. "Always use `--runInBand`" is fragile — it breaks the moment the flag name changes or someone needs to understand why. An agent given the reasoning will apply it correctly in situations the example doesn't cover.

If you find yourself reaching for all-caps emphasis or absolute prohibitions, pause and ask whether explaining the consequence would be clearer and more durable.

## Example situations

- The Jira skill has a wrong field name → update the skill.
- This repo requires `npm ci` before tests run but the AGENTS.md doesn't say so → update AGENTS.md.
- A Terraform module changed its variable interface → update the terraform skill.
- The GitLab skill is missing the default branch step → update the skill.
- Build kept failing because of an undocumented env var → add it to AGENTS.md.
- The iterate-plan skill kept asking shallow clarifying questions and missed the core trade-off you had to resolve manually → update the skill with what kind of questions actually surface the hard decisions.
- The complete-slice skill didn't enforce the red-green cycle — it wrote passing tests and code together → update the skill to make the TDD sequence explicit and explain why the order matters.

# Skills Buildout Plan

## Philosophy

Skills are **SOPs for agents.** Standard operating procedures that happen to be executed by AI instead of humans. Same rigor, same repeatability, same auditability. This is infrastructure engineering applied to AI — not "prompt engineering."

Everything ships to `~/.cursor/skills/` for personal use, eventually public on GitHub. Inspired by mattp's patterns but rewritten from scratch: infra-first, Jira-native, business-scoped, agentic.

---

## Design Principles

1. **SOPs, not prompts** — Each skill is a repeatable procedure with clear inputs, outputs, and checkpoints. If a human couldn't follow it as a runbook, it's not ready.
2. **Jira-native** — Skills that produce tickets use Jira API/MCP directly. Epics, stories, tasks — Jira's hierarchy, not markdown files pretending to be tickets.
3. **Business-scoped** — Works whether standing up a SaaS, internal tool, content product, or consulting gig. The interview determines the context, not the skill's assumptions.
4. **Agentic-first, human-reviewed** — Design for delegation with human review on every output. Clear inputs, clear outputs, always written so a human can read, review, and iterate with agents.
5. **Terse** — If the agent already knows it, don't explain it. Trust the agent, trust the user.
6. **Infra concerns are slices, not skills** — CI/CD, o11y, deployment, rollout — these are vertical slices of whatever you're building, not standalone ceremonies. They show up as sections in the brief, stories in the epic, and tickets to complete.
7. **O11y is opinionated on WHAT, agnostic on HOW** — Always: structured logging, distributed tracing, metrics, alerting. Never assume the vendor. This principle is baked into `define-project` and `plan-to-jira`, not isolated in its own skill.

---

## The 5 Skills

Build order top to bottom. Each skill gets tested on a real task before moving to the next. `iterate-plan` stress-tests every subsequent skill's design.

### 1. `define-project`

**What:** Single-shot skill to define a new project/product/business. Problem, audience, tech stack, infra requirements, MVP scope. Outputs a structured markdown brief — no repo initialization, no file generation beyond the document itself.

**Output:** `PROJECT_BRIEF.md` — the single artifact that feeds `iterate-plan`, `plan-to-jira`, and everything downstream.

---

### 2. `iterate-plan`

**What:** Relentless interview on any artifact — a brief, an epic, a ticket, an architecture doc, a business model. Walk every branch of the decision tree. Provide recommended answers. Resolve dependencies between decisions. Updates the artifact in place.

**Output:** Refined version of whatever was fed in.

**Default slot:** After `define-project`, but invocable on anything at any time.

**Key:** General-purpose refinement tool. Uses grill-me prompting style — relentless, branch-by-branch, recommended answers for every question. The scope comes from what you point it at.

---

### 3. `plan-to-jira`

**What:** Translate a `PROJECT_BRIEF.md` into Jira tickets via MCP. Determines the right hierarchy for the scope — could be an epic with stories or a single story. Brief remains the living reference and gets updated with ticket keys. When slicing epics, o11y instrumentation and deployment/rollout are stories like any other — not separate phases.

**Output:** Jira tickets created via MCP. If the scope warrants it: epic + vertical-slice stories, each independently deployable. If it's small enough: a single story. Brief updated with ticket keys/links.

**Key:** One skill, right-sized Jira output. The brief has the context; the tickets have the work. Every ticket is written for human review — agents draft, humans approve.

---

### 4. `complete-ticket`

**What:** Take a Jira story and deliver on it — code, infra, research, content, process changes, whatever the ticket requires. Read the ticket, understand acceptance criteria, do the work, verify, update. TDD for software/infra; incremental delivery for everything else.

**Output:** The deliverable the ticket describes — could be code, a document, a config, research findings. Ticket updated with completion notes.

**Reference docs:** TDD methodology (red-green-refactor, vertical slices, testing philosophy, mocking, refactoring).

**Key:** The execution skill. Every other skill produces plans; this one delivers. Language/framework/domain agnostic. Works with or without an existing codebase.

---

### 5. `improve-codebase`

**What:** Explore a codebase for architectural debt. Identify friction, shallow modules, missing abstractions. Spawn parallel sub-agents with different design constraints to generate competing redesigns. User picks the best, files it as a Jira epic.

**Output:** Architecture RFC as Jira epic, produced from competing agent-generated designs.

**Build last:** Most complex skill. Uses parallel sub-agents (Cursor Task tool). Building it last means you understand the platform's capabilities from building the other 4.

**Key:** The only skill that uses parallel agents. O11y audit, dependency hygiene, and agent-navigability baked in.

---

## Deferred Skills

Build later when patterns emerge from usage:

| Skill | Why Deferred |
|---|---|
| `ubiquitous-language` | DDD glossary. Useful for multi-business term collision, but not blocking anything. |
| `agentic-workflow` | Agent orchestration design. Let composition patterns emerge from building the 5 core skills first. |
| `triage-issue` | Bug diagnosis + TDD fix plan. `plan-to-jira` handles this for now; dedicated skill when the volume justifies it. |

---

## Patterns Carried Forward

- **YAML frontmatter** with `description` ending in "Use when..." — mandatory for discoverability
- **Interview loops** before generating artifacts — human review at the right moments
- **Parallel sub-agents** for competing designs — `improve-codebase` only
- **Progressive disclosure** — SKILL.md under 500 lines, reference docs for depth
- **Vertical slices** — core philosophy everywhere
- **Human-in-the-loop always** — every ticket, every output is written for human review and iteration

## Patterns Dropped

- GitHub-only assumptions → Jira API/MCP
- Claude Code hooks → N/A for Cursor
- Hardcoded paths → parameterized or removed
- SWE-only framing → business/infra/product agnostic
- Tiers/phases → flat list, build order is sequential
- Explicit modes/templates in skills → interview determines shape
- Standalone pipeline/pre-commit/o11y/deployment skills → vertical slices baked into existing skills

---

## The Pipeline

```
define-project → iterate-plan → plan-to-jira → complete-ticket
                                                       ↓
                                               improve-codebase
                                              (iterate as needed)
```

Napkin idea to production. SOPs all the way down.

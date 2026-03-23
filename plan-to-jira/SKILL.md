---
name: plan-to-jira
description: Create Jira tickets from a PROJECT_BRIEF.md — right-sized to the scope. Could be an epic with stories or a single story. Use when user wants to create tickets, convert a brief to Jira, or mentions "plan to jira", "create tickets", or "write epic".
---

# Plan to Jira

Read `PROJECT_BRIEF.md` and create Jira tickets via MCP. Right-size the output to the scope — not everything is an epic.

Always require a `PROJECT_BRIEF.md`. If one doesn't exist, tell the user to run `define-project` first.

Write every ticket so a human can review it and iterate on it with an agent. Clear language, testable criteria, no jargon that only makes sense to the machine.

## Process

1. Read `PROJECT_BRIEF.md`. Understand the scope, technical approach, and slice.
2. If there's a codebase, explore it to identify modules, boundaries, and existing patterns that inform how to slice the work.
3. Determine the right ticket hierarchy (see below).
4. Create tickets via Jira MCP.
5. Update `PROJECT_BRIEF.md` with ticket keys at the top of the document.

## Choosing the Hierarchy

| Scope | Jira Structure |
|---|---|
| Multi-story effort with distinct vertical slices | Epic + Stories |
| Single coherent change, testable in one pass | Story |

Default to the simplest structure that fits. Don't create an epic for something that's one story.

## Epic Structure

Only when the scope warrants multiple stories.

### Summary

Action-oriented. `[Verb] [what]`.

### Description

```
## Problem

What's broken, missing, or needed. 1-2 sentences.

## Solution

What we're building. The approach, not implementation details. 1-2 sentences.

## Acceptance Criteria

Numbered. Each one testable and observable.

## Key Decisions

Technical/architectural decisions from the brief that constrain implementation. No file paths. Interfaces, boundaries, constraints. Include o11y and deployment decisions here when relevant.

## Out of Scope

What this epic does NOT cover.

## References

- Link to PROJECT_BRIEF.md
```

### Fields

| Field | Value |
|---|---|
| Issue Type | Epic |
| Summary | Action-oriented title |
| Description | Structured per above |
| Priority | Infer from brief — default Medium |

## Story Structure

Each story is one vertical slice — independently deployable and demoable.

### Slicing Rules

- Every story is independently deployable and demoable
- The first story is the **mvp-slice** — thinnest end-to-end path that proves the approach. Maps to the brief's scope section.
- Subsequent stories add depth, breadth, or hardening
- Repo setup (deps, linting, CI, hooks, test runner) is the first story for greenfield projects
- O11y instrumentation (logging, metrics, alerts) is a story or acceptance criteria within stories — not a separate phase after the fact
- Deployment and rollout (pipeline config, environment setup, rollback plan) are stories when the brief calls for them — treat them like any other vertical slice

### Summary

`[Verb] [what]` — same as epics.

### Description

```
## What

What this story delivers. One demoable outcome.

## Acceptance Criteria

Numbered. Testable. Specific to this slice.

## Dependencies

Which stories must be completed first. Use ticket keys once created.

## Notes

Implementation hints or constraints from the brief that apply to this slice.
```

### Fields

| Field | Value |
|---|---|
| Issue Type | Story |
| Summary | Verb-first title |
| Description | Structured per above |
| Priority | Inherit from epic unless there's reason to differ |
| Labels | `mvp-slice` on the first story |
| Epic Link | Parent epic |

## Standalone Story

When the scope doesn't warrant an epic, create a single Story.

Use the same description structure as above. No epic link needed.

## Ordering

Create tickets in dependency order — blockers first. The first ticket should be what gets built first.

## Quality Bar

- Ticket hierarchy matches the actual scope — no epic for a one-story effort
- Every story is a vertical slice, not a horizontal layer
- Acceptance criteria are testable — a human or agent can write a test from each one
- Dependencies between stories are explicit
- The tickets are shorter and simpler than the brief they came from
- Every ticket is readable and reviewable by a human — written for collaboration, not automation

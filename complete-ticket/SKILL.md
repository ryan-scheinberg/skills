---
name: complete-ticket
description: Complete a Jira story end-to-end — code, infra, research, content, whatever the ticket requires. Reads the ticket, delivers to acceptance criteria, updates the ticket when done. Use when user wants to implement a story, complete a ticket, build a feature, fix a bug, or mentions "complete ticket" or "build this story".
---

# Complete Ticket

Take a Jira story and deliver on it. Could be code, could be infra, could be research, could be content, could be a process change. The skill is the same: read the ticket, understand the criteria, do the work, verify, update.

For software and infra tickets, use TDD. For everything else, the process still applies — understand the criteria, deliver incrementally, verify.

## Process

### 1. Read the ticket

Pull the story from Jira via MCP or read what the user provides. Understand:

- **What** the story delivers (the demoable outcome)
- **Acceptance criteria** (these become your verification targets)
- **Dependencies** (what must exist before you start)
- **Notes** (implementation hints, constraints from the brief)

If the acceptance criteria are vague or unverifiable, flag it before starting. Each criterion must be something you can confirm is done.

### 2. Understand the context

**If there's a codebase:** explore it. Understand existing architecture, patterns, conventions. Find prior art. Check test setup. Identify modules and interfaces you'll touch.

**If there's no codebase yet:** this might be greenfield. The first ticket may be repo setup — deps, linting, CI, test runner. Or it might not be a code ticket at all.

**If it's not a code ticket:** understand what deliverable format the criteria require — a document, a config, a process, a decision, research findings.

Read the `PROJECT_BRIEF.md` if one exists for broader context.

### 3. Plan the approach

Map acceptance criteria to steps. For code tickets, each step is a vertical slice — one test, one piece of implementation, verified. For non-code tickets, break the work into incremental deliverables you can check off.

Decide:

- Which criterion to tackle first (start with the one that proves the approach)
- What the boundaries are (what's in scope for this ticket vs future tickets)
- How you'll verify each criterion is satisfied

Don't overplan. The work itself will surface details you can't predict upfront.

### 4. Do the work

**For software/infra tickets — build with TDD:**

Follow the red-green-refactor loop for each acceptance criterion. See [tdd-reference.md](tdd-reference.md) for the full methodology.

The short version:

1. **Write one failing test** that describes the next behavior from your acceptance criteria
2. **Write minimal code** to make it pass
3. **Refactor** if needed — only when tests are green
4. Repeat for the next criterion

Rules:

- One test at a time. Don't write all tests first.
- Tests verify behavior through public interfaces, not implementation details
- Tests should survive internal refactors
- Only mock at system boundaries (external APIs, databases, time)

**For non-code tickets:**

Deliver incrementally against the acceptance criteria. Verify each one as you go. The output format depends on what the ticket asks for — a document, a config change, research findings, a design, whatever.

### 5. Verify against acceptance criteria

When all criteria are addressed:

- [ ] Every acceptance criterion is demonstrably satisfied
- [ ] For code: all tests pass, conventions followed, no unrelated changes
- [ ] The deliverable matches what the ticket describes

### 6. Update the ticket

Add completion notes to the Jira story via MCP:

- What was delivered (brief summary)
- Any deviations from the original plan and why
- Any new risks or follow-up work discovered
- Link to branch/MR if applicable

## What This Skill Handles

- New features
- Bug fixes
- Refactors
- Infra changes (IaC, pipeline config, environment setup)
- Research spikes
- Documentation or content creation
- Process or config changes
- Any Jira story with verifiable acceptance criteria

Language, framework, and domain agnostic.

## Additional Resources

- For TDD methodology, testing philosophy, mocking guidelines, and refactoring patterns, see [tdd-reference.md](tdd-reference.md)

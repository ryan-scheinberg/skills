---
name: plan-to-slices
description: Decompose a PROJECT_BRIEF.md into vertical, TDD-ready implementation slices. Each slice is independently buildable and testable, with tests defined before code. Use when user wants to break down a project into slices.
---

# Plan to Slices

Read `PROJECT_BRIEF.md` and produce a directory slices/slice_#.md — a ordered sequence of vertical, TDD-ready implementation slices.

Always require a `PROJECT_BRIEF.md`. If one doesn't exist, tell the user to run `define-project` first.

## Why vertical slices

Horizontal slicing (build the DB layer, then the API, then the UI) delays feedback and creates integration risk. A vertical slice cuts through every layer needed to deliver one observable outcome. You can demo it, test it end-to-end, and ship it. Each slice proves something works before you move on.

## Why TDD-ready

A slice isn't ready to build until you can describe the tests you'd write first. If you can't articulate a failing test, the slice is too vague. The tests *are* the spec — they define what "done" means for the slice and force precision about inputs, outputs, and behavior.

## Process

1. Read `PROJECT_BRIEF.md`. Understand scope, technical approach, MVP definition, and risks.
2. If there's a codebase, explore it — understand module boundaries, existing test patterns, what's already there. This shapes where slices land.
3. Identify the vertical slices (see slicing rules below).
4. For each slice, define the tests you'd write first (see TDD structure below).
5. Order slices by dependency and risk — build confidence early.
6. Write a file for each slice that will be implemented by a tdd agent.

## Slicing Rules

- **Every slice is vertical** — it touches whatever layers are needed (data, logic, API, UI, infra) to deliver one demoable outcome. No "set up the database" slices unless the project is pure infra.
- **Slice 1 is the MVP slice** — the thinnest end-to-end path from the brief's scope section. This slice proves the core approach works. It should be surprisingly thin.
- **Each subsequent slice adds one dimension** — more depth (handle edge cases), more breadth (another entity/flow), or hardening (error handling, performance, security).
- **Greenfield projects**: the first slice is project scaffolding + the MVP path. Include repo setup, test runner config, and CI in this slice — they're part of proving the approach, not a separate phase.
- **O11y is woven in, not bolted on** — structured logging, key metrics, and health checks belong inside slices, not in a dedicated "add observability" slice at the end.
- **Deployment is a slice when warranted** — pipeline config, environment setup, rollback plan. If the brief mentions deployment, it's a first-class slice.
- **Each slice should take roughly the same effort** — if one slice is 10x bigger than the others, break it down further.

## TDD-Ready — Not TDD-Done

The slicer doesn't write tests. It describes the *behaviors* each slice must exhibit — concrete enough that an implementer can immediately start red-green-refactor without asking clarifying questions. Think of each entry as a one-line spec: what scenario, what action, what observable outcome.

The implementer (human or AI agent) takes each behavior description and runs tiny TDD cycles against it — one failing test, minimal code to pass, refactor, next. They'll discover additional tests along the way. The slice just needs to give them a clear starting point and a finish line.

Keeping slices focused matters for AI context too — each slice should be completable in a single agent session without losing track of what's been built and what's left. Our agents' ability to complete tdd code is strong, but you can help by creating these useful vertical slices.

### Behavior categories to consider

- **Happy path**: the core behavior this slice delivers. Always present.
- **Input validation**: what happens with bad/missing input. Include when the slice introduces a new interface.
- **Edge cases**: boundary conditions, empty states, concurrent access. Include when they're core to the slice's purpose (not speculative).
- **Integration**: does this slice work with what's already built? Include from slice 2 onward.

Don't over-specify. 3-5 behavior descriptions per slice is typical. The goal is to define the boundary of "done" — not to write a test plan. The implementer will flesh these out into real tests and discover more during red-green-refactor.

## Output Format — SLICES.md

```markdown
# [Project Name] — Implementation Slices

> Generated from [PROJECT_BRIEF.md](./PROJECT_BRIEF.md)

## Slice 1: [Verb] [what] *(MVP)*

### What this delivers
One sentence: what a user/system can do after this slice ships.

### Tests to write first
1. **test_[descriptive_name]** — [what this test asserts]. [Setup] → [action] → [expected outcome].
2. **test_[descriptive_name]** — ...
3. ...

### Implementation notes
Key decisions, constraints, or patterns from the brief that apply here. What layers this touches.

### Done when
- [ ] All tests pass
- [ ] [Observable outcome — can demo X / can hit endpoint Y / logs show Z]

---

## Slice 2: [Verb] [what]

### What this delivers
...

### Tests to write first
...

### Implementation notes
- **Depends on**: Slice 1
- ...

### Done when
...

---

(repeat for each slice)
```

## Ordering Principles

1. **MVP first** — always. Prove the approach before expanding.
2. **Dependencies before dependents** — a slice that introduces an API comes before the slice that consumes it.
3. **Risk early** — if a slice involves an uncertain technology or integration, push it forward. Learn if it works before building on top of it.
4. **User-facing before internal polish** — deliver visible value, then harden.

## Quality Bar

- Every slice is vertical — no "build the data layer" or "set up auth middleware" slices that aren't independently demoable
- Test specs are concrete enough that an implementer can write the test code without asking clarifying questions
- Tests use the Arrange-Act-Assert / Given-When-Then pattern implicitly (setup → action → expected outcome)
- Slice 1 is genuinely thin — if it takes more than a day or two, it's too thick
- Dependencies between slices are explicit
- The slice plan is shorter and more actionable than the brief it came from
- A developer reading SLICES.md knows exactly what to build first, what tests to write, and when they're done

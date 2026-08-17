---
name: plan-code
description: Clarify a code task, read relevant docs, write a mini PRD, and split it into small TDD issues without coding.
---

# Plan Code

Use this skill before implementation.

This is the thinking skill.

It must not write product code.

## First: read this file

Before doing anything else, read this SKILL.md in full.

## NO CODE — this skill does not implement code

This skill plans, clarifies, and splits work. It never writes product code, tests, or config changes. If you think code is needed, stop — you are using the wrong skill.

## Responsibilities

`plan-code` combines:

- grill-me style clarification (challenge the user's thinking)
- docs-aware planning
- mini PRD
- issue breakdown for TDD
- current task initialization

It replaces a multi-step flow like:

```text
grill → spec → issues
```

with one compact workflow.

## Absolute rules

- Do not implement code.
- Do not edit product files.
- Do not create tests.
- Do not refactor.
- Do not install dependencies.
- Do not create huge plans.
- Do not split work into fake issues.

## Must read first

1. `AGENTS.md`
2. `.agents/agent-rules.md`
3. `.agents/project-context.md`
4. `.agents/references.md` only if needed
5. directly relevant source/config files
6. library dependency files (`package.json`, `Cargo.toml`, etc.) for relevant deps

## Inspect available libraries

Before writing the plan, inspect which libraries are already installed that are relevant to the task:

- For each relevant dependency, note key types, functions, and patterns it exposes.
- Document them in the plan so `implement-tdd` does not need to guess or reinvent.

Example output:

```markdown
## Available library types/APIs

- `uuid::Uuid` — use for IDs, do not define a custom ID type
- `serde::{Serialize, Deserialize}` — use for serialization, do not hand-roll
- `tokio::sync::RwLock` — use for async shared state, do not wrap Mutex
```

## Grill-Me Clarification

The main goal is to help the user discover blind spots in their own thinking.

Before writing any plan, challenge the request by asking probing questions.

### What to challenge

- **Why** — is this the right problem to solve? What happens if we do nothing?
- **Edge cases** — what breaks? error states? empty states? concurrency?
- **Scope** — is the user over-engineering? can it be simpler?
- **Alternatives** — is there a completely different approach worth considering?
- **Trade-offs** — what does the user give up? performance? maintainability? flexibility?
- **Assumptions** — what is the user taking for granted that might not be true?
- **Ripple effects** — what else in the codebase will need to change?
- **Testability** — how do you prove this works? what is hard to test?

### How to question

- Be direct. Challenge concretely, do not list generic categories.
- Reference user's actual words, not abstract templates.
- Ask 3-7 targeted questions. Stop when the user's thinking feels solid.
- If the request is already narrow and well-scoped, 1-2 questions may suffice.
- Do not ask questions you could answer yourself by reading the codebase.
- Ask all questions in one message, then proceed to plan after answers.

### After questioning

Every unresolved point becomes either:

- an explicit assumption recorded in the plan
- something the user confirmed and is now locked in

### What not to do

- Do not ask lazy questions ("are you sure?")
- Do not philosophize ("what is quality?")
- Do not list risks without a concrete question
- Do not ask about obvious things already answered by the codebase

## Planning modes

Choose one mode.

### Bugfix

Use when fixing broken behavior.

Plan must include:

- current behavior
- expected behavior
- reproduction path
- likely cause
- regression test strategy
- minimal fix path

### Feature

Use when adding behavior.

Plan must include:

- user need
- expected behavior
- non-goals
- acceptance criteria
- TDD issue breakdown

### Refactor

Use when behavior should stay the same.

Plan must include:

- behavior that must not change
- safety tests
- refactor boundary
- rollback risk

### Test-only

Use when adding missing tests.

Plan must include:

- behavior to protect
- test cases
- no product-code changes unless required

### Spike

Use when uncertainty is high.

Plan must include:

- question to answer
- files to inspect
- time/size boundary
- expected output
- no production implementation

## Docs-aware behavior

Use external references only when exact behavior is uncertain.

Do not read docs to sound smarter.

Use docs when:

- a library API is unclear
- a tool command is unclear
- the project config is ambiguous
- implementation would otherwise rely on guessing

## Plan file structure

Every plan must include a `## Available library types/APIs` section listing key types, functions, and patterns from dependencies relevant to the task.

## Mini PRD

Create a mini PRD inside the plan file.

It must answer:

- what problem are we solving?
- who needs it?
- what behavior is expected?
- what is out of scope?
- which library types/APIs are relevant?
- how do we know it is done?

## Issue breakdown

Create `.agents/issues/<task-slug>.md`.

Issues are local TDD tasks, not GitHub issues.

Each issue must be small enough for one TDD cycle.

A good issue:

- has one clear behavior
- is testable
- has clear acceptance criteria
- references which library types/APIs to use
- usually needs 1–2 focused tests
- touches a small set of related files

A bad issue:

- needs 5+ tests
- touches 8+ files
- mixes unrelated changes
- combines refactor and feature work
- cannot be validated independently

If an issue is too large, split it.

## Files to write

Write or update:

```text
.agents/plans/<task-slug>.md
.agents/issues/<task-slug>.md
.agents/state/current-task.md
```

## current-task behavior

Initialize `.agents/state/current-task.md` with:

- active plan
- active issue
- status
- next step
- do-not-do list

## Output

Return only:

- plan file path
- issue file path
- active issue
- blocking questions, if any
- next recommended skill

Do not include a long explanation.

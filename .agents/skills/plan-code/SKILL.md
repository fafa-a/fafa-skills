---
name: plan-code
description: Aggressively clarify a code task by scanning the relevant files first, write an evidence-based mini PRD, and split it into small TDD issues without coding.
---

# Plan Code

Use this skill before implementation.

This is the thinking and specification skill. It ends at an explicit approval
request; implementation runs in a fresh agent session.

It must not write product code, tests, or configuration.

## First: read this file

Before doing anything else, read this SKILL.md in full.

## NO CODE — this skill does not implement code

This skill plans, clarifies, and splits work. It never writes product code, tests, or config changes. If you think code is needed, stop — you are using the wrong skill.

## Responsibilities

`plan-code` combines:

- targeted repository reconnaissance before clarification
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
- Do not create a plan or issue files before the user answers the blocking questions.
- Do not mark a plan ready for implementation without explicit user approval.
- Do not interpret silence, a generic acknowledgement, or a request to continue as approval.

## Must read first

Follow the shared startup read order in `.agents/agent-rules.md` (skip plan/issue
files — there is no active task yet). In addition, read:

- `.agents/references.md` only if needed
- library dependency files (`package.json`, `Cargo.toml`, etc.) for relevant deps

## Phase 0: evidence-first reconnaissance

Before asking questions, inspect the repository area implicated by the request.
Use the user's nouns, paths, symbols, commands, and error messages to locate:

1. the entry points and callers
2. the relevant implementation and tests
3. configuration, schemas, migrations, and persistence boundaries
4. adjacent code that may be affected by the requested behavior
5. existing conventions and available library APIs

Do not scan the whole repository by default. Start with targeted file search and
content search, then read the smallest set of relevant files deeply enough to
state current behavior. If a named file or symbol does not exist, report that
fact and ask whether it is new work. Questions must be based on this evidence,
not on generic checklists.

### Delegate wide searches

Do not burn your own context doing broad exploration. Delegate:

- broad "where does X live / how does Y work" searches to the `explore`
  subagent (read-only, fast) via the `task` tool
- external library/dependency research (unclear API, upstream source,
  version-specific behavior) to the `scout` subagent via the `task` tool

Keep your own reads focused on the small set of files you need to state
current behavior precisely and to draft questions. Use the subagents' returned
summaries, not their full search trails, in your reconnaissance note.

Record a short reconnaissance note in your working context before questioning:
`Observed`, `Likely impact`, `Unknown`, and `Files inspected`. Do not write it
to the plan yet; the plan does not exist until clarification is complete.

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

After reconnaissance, challenge the request by asking probing questions. Ask
before creating or updating any plan, issue, or current-task file.

Read `.agents/skills/plan-code/clarification-checklist.md` for what to
challenge and what to avoid.

### Question depth: risk-based, not vibes-based

Use the aggressive mode (5-10 decision-forcing questions) if reconnaissance
shows ANY of:

- touches authentication, authorization, or permission checks
- touches payment, billing, or money-affecting logic
- touches a public API contract (breaking change risk)
- involves a data migration or irreversible data change
- touches more than one service/module boundary
- security-sensitive I/O (file paths, shell commands, deserialization, SQL)

Use the light mode (1-2 questions, or zero if truly unambiguous) only when
reconnaissance proves ALL of:

- single file or single narrow module
- no schema/data/API contract change
- fully reversible (a revert has no side effects)
- behavior described by the user matches what the code already does elsewhere

If reconnaissance is inconclusive about which bucket applies, default to the
aggressive mode.

### How to question

- Be direct. Challenge concretely, do not list generic categories.
- Reference user's actual words, not abstract templates.
- Make questions decision-forcing: present the concrete choice and its impact
  where possible. Include boundary cases, failure behavior, compatibility,
  security, data migration, observability, and rollback questions when relevant.
- Cite the inspected file/symbol that triggered each question.
- Stop only when every decision that changes behavior, scope, data, or API is
  answered or explicitly delegated to an assumption the user accepts.
- Do not ask questions you could answer yourself by reading the codebase.
- Ask all currently discoverable questions in one message. If an answer reveals
  a new affected area, scan that area before asking the next question.
- Do not proceed to planning while blocking questions remain unanswered.

### After questioning

Every unresolved point becomes either:

- an explicit assumption recorded in the plan
- something the user confirmed and is now locked in

If answers materially change scope, repeat targeted reconnaissance and surface
the delta before drafting the plan.

## Planning modes

Choose one mode, then read only that mode's section in
`.agents/skills/plan-code/modes.md`: Bugfix, Feature, Refactor, Test-only, or
Spike.

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

Every plan must also include:

- `## Reconnaissance` with observed current behavior and inspected files
- `## Decisions Locked` with the user's answers
- `## Approval` with `Status: AWAITING_APPROVAL`, approval scope, and the exact
  instruction that implementation must wait for explicit approval
- concrete file/symbol references for each issue

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

Write these files only after clarification is complete. Set:

- plan `Status: READY` and `Approval Status: AWAITING_APPROVAL`
- current task `Status: AWAITING_APPROVAL`
- issue statuses `TODO`

The active issue is selected for implementation, but is not authorized to run.
The user must explicitly approve the plan and issue set, for example:
`APPROVED: implement plan <task-slug>, starting with issue 1`.
Record the exact approval and date in the plan and set current task status to
`READY` only after receiving it. A changed plan, issue list, or scope invalidates
the approval and returns the task to `AWAITING_APPROVAL`.

## Session boundary

Do not hand off to `implement-tdd` in the current conversation. After the plan
and issues are written, tell the user to open another terminal/session and run
the implementation agent there, providing the plan slug and active issue. This
keeps planning evidence and implementation context separate.

Do not update `.agents/project-context.md` for task-specific discoveries by
default. Preserve important discoveries in the plan under `Reconnaissance` and
`Available library types/APIs`. A later workflow can promote a discovery to
project context only when it is durable and useful beyond this task.

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
- approval status (always explicit)
- next action: ask the user to open another terminal/session and run
  `implement-tdd` after explicit approval; never perform that handoff in this
  session

Do not include a long explanation.

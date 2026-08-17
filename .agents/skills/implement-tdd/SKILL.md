---
name: implement-tdd
description: PRIMARY coding skill. Use when implementing any issue, task, feature, bugfix, or code change. This is the default implementation skill. Other skills are domain supplements only.
---

# Implement TDD

Use this skill to implement code.

This is the coding skill.

It must follow the active plan and active issue.

## First: read this file

Before doing anything else, read this SKILL.md in full.

## Absolute rules

- Do not plan from scratch.
- Do not invent work.
- Do not code if there is no active task.
- Do not code if the active plan is missing.
- Do not code if the active issue is missing.
- Do not make unrelated changes.
- Do not add dependencies unless the plan explicitly allows it.
- Do not rewrite, redefine, or wrap library types. Use them as-is.
- Do not continue through multiple issues by default.

## Startup behavior

Read:

1. `AGENTS.md`
2. `.agents/agent-rules.md`
3. `.agents/project-context.md`
4. `.agents/state/current-task.md`
5. active plan file
6. active issue file

If `.agents/state/current-task.md` is missing:

- stop
- say that there is no active task
- ask the user to run `plan-code` first

If current task status is `NONE`, `DONE`, or empty:

- stop
- do not search for random work

If active plan or active issue cannot be found:

- set current task to `BLOCKED`
- explain the missing file
- stop

## Domain skills

After reading the active issue, check the available skills. If the issue touches a specific technology, load the relevant domain skill. Domain skills provide technology-specific rules and best practices. Control always stays with this skill.

## Default execution mode

Default mode:

```text
one issue → one TDD cycle → stop
```

Do not complete multiple issues unless the user explicitly asks.

If multiple issues are ready, continue only with the active issue from `current-task.md`.

## TDD cycle

For the active issue:

1. Confirm the acceptance criteria.
2. Set `current-task.md` status to `IN_PROGRESS`.
3. Inspect only directly relevant files.
4. Write or update one failing test first.
5. Run the smallest relevant test command.
6. Confirm the test fails for the expected reason.
7. Implement the smallest change.
8. Run the test again.
9. Refactor only if needed for clarity.
10. Run the relevant checks.
11. Update `.agents/state/current-task.md`.
12. Stop.

## Red phase

The failing test must prove the behavior required by the active issue.

Do not write tests for implementation details.

Do not write broad snapshot tests unless the project already uses them.

## Green phase

Implement the smallest code change that passes the test.

Prefer:

- existing patterns
- existing helpers
- library types (do not rewrite them)
- library best practices
- simple branches
- explicit types
- readable code

Avoid:

- new abstractions
- new dependencies
- broad refactors
- clever generic code
- touching unrelated files

## Library usage

- Use types from libraries as-is. Do not rewrite, re-export, or copy them.
- Follow each library's documented best practices and patterns.
- Do not wrap library functions in unnecessary abstractions.

## Refactor phase

Only refactor when:

- the test is green
- the refactor is local
- readability improves
- behavior does not change

## When blocked

If a decision is required:

1. update `current-task.md` with `BLOCKED`
2. describe the blocker
3. stop

Do not guess when the guess could change architecture or behavior.

## Updating current-task

`current-task.md` must be updated at every transition, not only at the end.

The `current-task.md` fields are (see `current-task-template.md`):

- `Status`
- `Active Plan`
- `Active Issue`
- `Last Completed Step`
- `Current Failure`
- `Last Command`
- `Next Step`
- `Do Not Do`
- `Notes`

Status transitions:

- start of cycle: `Status: IN_PROGRESS`
- test fails as expected: update `Last Completed Step`
- test passes: update `Last Completed Step`, clear `Current Failure`
- code done, checks green: `Status: DONE`, `Last Command`, `Next Step`
- blocked: `Status: BLOCKED`, `Current Failure` = the blocker

Also update the issue file (`Status:` line in `.agents/issues/<task-slug>.md`) to match: `TODO` → `IN_PROGRESS` → `DONE` or `BLOCKED`.

Keep `current-task.md` short.

## Output

Return:

- issue completed or blocked
- test added or changed
- implementation summary
- command run
- next step

Keep the response concise.

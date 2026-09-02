---
name: implement-tdd
description: PRIMARY coding skill. Use when implementing any issue, task, feature, bugfix, or code change. This is the default implementation skill. Other skills are domain supplements only.
---

# Implement TDD

Use this skill to implement code in a fresh session after `plan-code` has
produced a plan and issue.

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
- Do not narrate the rules or the process. Report facts and results, not
  intentions.

## Startup behavior

Follow the shared startup read order in `.agents/agent-rules.md`.

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

1. Confirm the acceptance criteria. If starting a new issue named by the
   "continue"/"next" resolution above, update `Active Issue` in
   `current-task.md` to that issue before doing anything else.
2. Set `current-task.md` status to `IN_PROGRESS`.
3. Inspect only directly relevant files — read the files/symbols the issue
   points to and confirm the issue's assumptions still match the current
   code (signatures, existing patterns, whether the described behavior
   already exists). The issue may be stale or incomplete; verify before
   coding instead of trusting the text blindly. If reality diverges from
   the issue in a way that changes scope or approach, treat it as a
   blocker (see "When blocked") instead of silently improvising.
4. Write or update one failing test first.
5. Run the smallest relevant test command.

Command selection guidance:

- When the project has a detected Bun environment (e.g. `bun.lock`, or project-context.md lists Bun as the preferred runtime), prefer running tests and scripts with `bun` (e.g. `bun test`, `bun run <script>`) rather than node/npm/pnpm/yarn. Do not change the project's declared preference if it explicitly uses a different manager.
- If the detected project tooling is ambiguous, do not guess — consult the user or `plan-code`/`manage-project-context` output (project-context.md) before choosing a command.
6. Confirm the test fails for the expected reason.
7. Implement the smallest change.
8. Run the test again.
9. Refactor only if needed for clarity.
10. Run the relevant checks.

Checks guidance:

- After the test is green, run linting and style checks at least on the changed files (not necessarily the whole repo) to catch formatting, typing, or obvious issues introduced by the change. Use the project's preferred command from `project-context.md` (for JS/TS, prefer `bun`-based commands when Bun is the preferred runtime).
- If the `aislop` MCP tool set is available in this session, call the mechanical-fix tool (non-aggressive mode only) before manual checks — it clears formatting/lint/ai-slop issues deterministically without spending review effort on them. Never use the aggressive mode; it can delete files or rewrite `package.json`.
- If the `aislop` MCP tool set is not available, fall back to a project-local `aislop` script only when it is explicitly present (package.json scripts or project-context.md). Do not invent or run unknown scripts.

See `.agents/references.md` for concrete commands and a safe example script to run checks only on changed/new files. If `.agents/scripts/run_checks_changed.sh` exists, prefer using it to ensure consistent behavior across agents.
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
- When unsure how to use a library API, prefer reading its real source
  (vendored repo, `node_modules` unflattened source, or the project's own
  existing usages) over guessing or fetching web docs. Source code shows
  actual usage patterns; docs written for humans often don't.
- If a project vendors a library's source under a dedicated directory (e.g.
  `repos/<lib>`), treat it as read-only reference material: never import
  from it and never edit it unless explicitly asked.
- If, while implementing, you notice recurring non-obvious usage patterns
  for a library the project relies on heavily, consider creating or
  updating a short pattern file at `agent-patterns/<lib>.md` summarizing
  the idioms (constructors, error handling, common pitfalls) with examples
  drawn from the real source or the project's own code. Keep it practical,
  not exhaustive. This is optional and must not block or delay the active
  issue.

## Refactor phase

Only refactor when:

- the test is green
- the refactor is local
- readability improves
- behavior does not change

## Scope drift check

Before the refactor phase (or before stopping, if there is no refactor), diff
the files actually changed against the issue's `Files` list.

- Every changed file must be in `Files`, or be a direct, unavoidable
  consequence documented in `Notes` (e.g. a barrel/export file).
- If a changed file is not covered and cannot be justified as unavoidable:
  stop, set `current-task.md` to `BLOCKED`, and describe the drift instead of
  continuing silently.
- Do not add files to the issue's `Files` list retroactively to make a drift
  disappear. Update the issue file first only if the user or `plan-code`
  confirms the extra scope is correct.

## When blocked

If a decision is required:

1. update `current-task.md` with `BLOCKED`
2. describe the blocker
3. stop

Do not guess when the guess could change architecture or behavior.

Treat the following as concrete blocking cases (not exhaustive, but do not
silently improvise on any of these — stop and ask instead):

- introducing or changing a public API surface (exported function signature,
  route, type) beyond what the issue explicitly describes
- changing the data model (new/changed field, schema, table, persisted shape)
- choosing an error-handling strategy not already established by the
  project's existing patterns (e.g. throw vs. Result vs. error union) when
  the issue does not specify one
- picking between two or more materially different implementation
  approaches where the issue does not name one
- anything that would require touching a file outside the issue's `Files`
  list in a way not already covered by "Scope drift check" below

### Ask one question at a time

If the blocker needs user input, ask exactly one question at a time using the
`question` tool, and wait for the answer before asking the next one. Never
dump a list of questions in a single message. When the blocker has a concrete,
enumerable set of choices (e.g. which of two approaches, yes/no, which file to
touch), use the `question` tool's `options` so the user picks instead of
typing free text — same convention `plan-code` uses for its clarification
questions.

## Resuming after BLOCKED

If `current-task.md` status is `BLOCKED` at startup:

1. Read `Current Failure` — it describes the blocker.
2. Do not resume the TDD cycle until you can state, concretely, why the
   blocker no longer applies (e.g. the user answered the question, the plan
   or issue was updated, a dependency was installed).
3. If the blocker's resolution is not evident from the plan/issue/conversation,
   stop and ask the user to confirm it is resolved before setting
   `Status: IN_PROGRESS`.
4. Never resume by assumption just because time has passed or the session is
   new.

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

On `Status: DONE`, also look at the active issues file
(`.agents/issues/<task-slug>.md`) for the next issue with `Status: TODO`:

- if one exists, set `Next Step` to name it explicitly (e.g. `Issue 2 -
  <title> is next, TODO`) — do not start it, just record it so the next
  session does not need the issue number restated
- if none exists (all issues `DONE`), set `Next Step` to say the plan is
  fully implemented and recommend `review-code`

### Resuming with "continue" / "next"

If the user says "continue" or "next" without naming an issue number, and
`current-task.md`'s `Next Step` already names the next issue (from the rule
above), use that issue — do not ask the user to repeat the number. Only ask
for a number if `Next Step` is ambiguous or does not name a specific issue.

Also update the issue file (`Status:` line in `.agents/issues/<task-slug>.md`) to match: `TODO` → `IN_PROGRESS` → `DONE` or `BLOCKED`.

Keep `current-task.md` short.

## Output

Report only, in this order, one line each:

- issue completed or blocked
- test added or changed (file + name)
- implementation summary (1 line)
- command run
- next step

No preamble, no restating the rules, no decorative summary. If nothing
noteworthy happened in a category, omit the line instead of padding it.

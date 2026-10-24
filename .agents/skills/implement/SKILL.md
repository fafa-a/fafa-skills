---
name: implement
description: PRIMARY coding skill. Use when implementing any issue, task, feature, bugfix, or code change. This is the default implementation skill. Other skills are domain supplements only.
---

# Implement

Use this skill to implement code in a fresh session after `planner` has
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
- Execute all remaining TODO issues for the active plan in the same implement session unless blocked or explicitly told to stop.
- Do not narrate the rules or the process. Report facts and results, not
  intentions.

## Startup behavior

Follow the shared startup read order in `.agents/agent-rules.md`.

If `.agents/state/current-task.md` is missing:

- stop
- say that there is no active task
- ask the user to run `planner` first

If current task status is `NONE`, `DONE`, or empty:

- stop
- do not search for random work

At the start of a new implement session, read the active plan once, then read
the active issue. The plan remains the session-level source of truth and must
not be re-read for every subsequent issue.

- Resolve the plan path from `current-task.md`'s `Active Plan` field and read it
  once before starting the first issue in this session.
- For each later issue in the same plan, read only `current-task.md` and that
  issue unless the plan changed, the issue is ambiguous, or a blocker requires
  plan-level context.
- If `current-task.md` is missing, stale, or does not name a plan, fall back to
  the issue file's `Related Plan` field.

If active plan or active issue cannot be found:

- set current task to `BLOCKED`
- explain the missing file
- stop

## Domain skills

After reading the active issue, check available domain skills and load only those relevant to the technology being changed. Project rules still come from `AGENTS.md`, project context, the plan, and the issue. Control stays with `implement`.

## Default execution mode

Default mode:

```text
one plan → one implement session → sequential TDD cycles → stop when plan is complete
```

Start with the active issue from `current-task.md`. When an issue is DONE, move
directly to the next TODO issue in the same plan without starting a new agent
session or asking the user to restate context.

Stop early only when blocked, when the plan changes materially, or when the user
explicitly asks to stop.

## TDD cycle

For the active issue:

1. Confirm the acceptance criteria. If starting a new issue named by the
   "continue"/"next" resolution above, update `Active Issue` in
   `current-task.md` to that issue before doing anything else.
2. Set `current-task.md` status to `IN_PROGRESS`.
3. Inspect only directly relevant files and confirm the issue assumptions still match current code. If the issue names an existing precedent, verify it. If the intended repository pattern is unclear or the named precedent is stale, call `pattern-scout` once with the narrow question before coding. If reality changes scope or approach, block instead of silently re-planning.
4. Write or update one failing test first.
5. Run only the test file(s) added or modified for the active issue, using the smallest command that targets them directly. Do not run the full test suite, an entire package test suite, or unrelated existing tests unless the user explicitly asks.

Command selection guidance:

- When the project has a detected Bun environment (e.g. `bun.lock`, or project-context.md lists Bun as the preferred runtime), prefer running tests and scripts with `bun` (e.g. `bun test`, `bun run <script>`) rather than node/npm/pnpm/yarn. Do not change the project's declared preference if it explicitly uses a different manager.
- If the detected project tooling is ambiguous, do not guess — consult the user or `planner`/`manage-project-context` output (project-context.md) before choosing a command.
1. Confirm the changed/added test fails for the expected reason.
2. Implement the smallest change.
3. Run only the changed/added test file(s) again.
4. Refactor only if needed for clarity.
5. Run the relevant changed-file checks.

Checks guidance:

- After the changed/added test is green, run linting and style checks only on the changed files when the tooling supports targeted checks. Do not broaden to repo-wide or package-wide checks by default. Use the project's preferred command from `project-context.md` (for JS/TS, prefer `bun`-based commands when Bun is the preferred runtime).
- If the `aislop` MCP tool set is available in this session, call the mechanical-fix tool (non-aggressive mode only) before manual checks — it clears formatting/lint/ai-slop issues deterministically without spending review effort on them. Never use the aggressive mode; it can delete files or rewrite `package.json`.
- If the `aislop` MCP tool set is not available, fall back to a project-local `aislop` script only when it is explicitly present (package.json scripts or project-context.md). Do not invent or run unknown scripts.

See `.agents/references.md` for concrete commands and a safe example script to run checks only on changed/new files. If `.agents/scripts/run_checks_changed.sh` exists, prefer using it to ensure consistent behavior across agents.
11. Update `.agents/state/current-task.md` and the issue status.
12. If another TODO issue exists in the same plan, set it as `Active Issue` and
    immediately start its TDD cycle in this same session.
13. Stop only when all issues are DONE or execution is blocked.

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
  disappear. Update the issue file first only if the user or `planner`
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
typing free text — same convention `planner` uses for its clarification
questions.

Any closed-choice question (2–4 concrete options) must use `question.options`,
never free text. Keep labels short (1–3 words) and explicit enough to act on
without reading the description — e.g. `Yes` / `No` for a binary choice, or
short distinct names for 3–4 choices. Reserve free-text answers for genuinely
open-ended questions with no enumerable set of choices.

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

## Runtime UI verification

When implementation changes visible UI, layout, positioning, interaction, or browser behavior:

- use Playwright CLI first to verify the affected user-visible behavior;
- keep the Playwright flow narrow: reproduce only the interaction changed by the active issue;
- use the `chrome-devtools` skill and Chrome DevTools MCP only when Playwright CLI cannot verify the behavior, fails in a way that needs browser-level diagnosis, or deeper runtime inspection is required;
- do not use both tools by default;
- verify the observable result instead of relying only on code inspection;
- fix any regression introduced by the implementation before handing off to Reviewer.

Do not use browser inspection when the change has no observable browser impact.

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

On issue completion, look at the active issues file
(`.agents/issues/<task-slug>.md`) for the next issue with `Status: TODO`:

- if one exists, set it as `Active Issue`, set `Next Step` to that issue, and
  continue it immediately in the same implement session;
- if none exists, set `Status: DONE` and `Next Step` to say the plan is fully
  implemented and ready for `reviewer`.

### Resuming after an interruption

If the implement session is interrupted and later resumed, use `Active Issue`
and `Next Step` from `current-task.md`; do not ask the user to repeat an issue
number already recorded there.

Also update the issue file (`Status:` line in `.agents/issues/<task-slug>.md`) to match: `TODO` → `IN_PROGRESS` → `DONE` or `BLOCKED`.

Keep `current-task.md` short.

## Output

On successful completion of the full plan, keep the handoff extremely compact:
maximum 5 lines, one fact per line, in this order when relevant:

- `DONE: <plan> | Issues: <count>`
- `Tests: <changed/added test files only>`
- `Changed: <one-line implementation summary>`
- `Checks: <targeted command/result>`
- `Next: reviewer`

Do not emit a user-facing handoff after each successful issue; update the task
Markdown and continue to the next issue.

On `BLOCKED` or execution/check failure, switch to a targeted diagnostic. Include
only the sections needed to continue safely:

- `BLOCKED` or `ERROR: <issue>`
- `Cause: <concrete cause>`
- `Evidence: <file/symbol/error>`
- `Tried: <short list of relevant attempts>` when useful
- `Failing check: <command + relevant failure>` when applicable
- `Need:` or `Next: <decision/action required>`

Failure output may exceed 5 lines when the extra detail is required to diagnose
or hand off the problem. Do not narrate the investigation, restate rules, or
include a chronological work log. Omit empty sections.

---
name: review-code
description: Review code changes against the active plan, issues, tests, and project rules.
---

# Review Code

Use this skill after implementation.

This is the verification skill.

## First: read this file

Before doing anything else, read this SKILL.md in full.

## Responsibilities

- Compare the diff against the plan.
- Check the active issue acceptance criteria.
- Check tests.
- Check scope.
- Check simplicity.
- Check project conventions.
- Verify `current-task.md` is accurate: status matches reality (`DONE` only when tests and checks pass, `BLOCKED` only when a blocker exists), fields are filled, and it matches the actual diff.
- Create follow-up TDD issues when needed.

## Must read first

1. `AGENTS.md`
2. `.agents/agent-rules.md`
3. `.agents/project-context.md`
4. `.agents/state/current-task.md`
5. active plan file
6. active issue file
7. current diff

## Review checklist

Check:

- does the code solve the requested issue?
- does it respect the plan?
- does the plan reference which library types/APIs to use?
- does the code use those library types/APIs as-is?
- does it avoid non-goals?
- is the diff small?
- are tests meaningful?
- are tests behavior-focused?
- are errors handled?
- are types clean?
- are library types used as-is (not rewritten)?
- are library best practices followed?
- are project conventions respected?
- is there unrelated refactor?
- is there any obvious performance problem?
- is `current-task.md` updated and accurate?

Checks guidance:

- Reviewers must verify that linting/style checks pass for the changed files. Prefer running the project's preferred lint/test runner (from project-context.md). When Bun is the preferred runtime, prefer `bun`-based commands.
- If the repository defines a verification script named `aislop`, the reviewer should run it (e.g. `bun run aislop`) to ensure the change did not introduce issues. Only run `aislop` when it is explicitly present in the project.

See `.agents/references.md` for concrete commands and a safe example script to run checks only on changed/new files. If `.agents/scripts/run_checks_changed.sh` exists, reviewers should prefer using it to ensure consistent behavior.

## Verdicts

Use one of these, with this exact meaning:

- `PASS` — code matches the plan and the issue, tests are meaningful and green, `current-task.md` is accurate. Nothing to change.
- `NEEDS CHANGES` — the current issue is mostly implemented but has fixable problems (missing/failing test, scope drift, `current-task.md` wrong, minor correctness issue). Hand off with ONE `implement-tdd` prompt on the current issue.
- `BLOCKED` — cannot finish the review because a decision is required or context is missing (plan contradicts the issue, ambiguous acceptance criteria, no failing test possible). No prompt; ask the user the blocking question.

## Correction behavior

Default:

- review first
- do not make broad changes

Decide the size of a problem before acting:

- **Tiny fix** (single-file, no behavior change, no new test needed, e.g. typo, wrong `current-task.md` field): fix it here using TDD discipline, then update `current-task.md`.
- **Real change** (any behavior change, a new or modified test, more than one file, or anything unclear): do not fix it here. Hand off to `implement-tdd` with a prompt. Use this rule even for small-looking changes.
- If the change is out of the current issue's scope: create or update a follow-up issue in `.agents/issues/<task-slug>.md`, update `current-task.md`, and hand off.

## Handing off to implement-tdd

On verdict `NEEDS CHANGES`, produce ONE single ready-to-use prompt for the `implement-tdd` agent. The prompt is about the CURRENT issue only: it tells `implement-tdd` what to improve in the issue that was just reviewed. Do not leave the reviewer response as free-form notes.

The single prompt must:

- name the issue slug to work on (the current issue, or the new follow-up issue if out of scope)
- state the acceptance criteria (from the issue)
- list exactly ALL improvements for that issue (files, behavior) in one `Changes required` list
- reference the plan and issue files
- state the failing test(s) or the missing test(s) to add
- state the expected command to run
- forbid unrelated changes

Format:

```text
implement-tdd prompt:
---
Active issue: <issue-slug>
Task: <one-line summary>
Acceptance criteria:
- <criterion>
- <criterion>
Changes required:
- <file/behavior to change>
- <file/behavior to change>
Test: <the test to add or fix, and why it fails/does not exist>
    Command: <smallest relevant test command>

Command selection guidance:

- When the project has a detected Bun environment (e.g. `bun.lock`, or project-context.md lists Bun as the preferred runtime), prefer the reviewer to state `bun`-based commands (e.g. `bun test`, `bun run <script>`) as the expected command to run.
- If the repository's preferred runtime/tooling differs or is ambiguous, the reviewer must reference `project-context.md` or ask the user before asserting a command. Do not override an explicit project preference.
Do not: <unrelated changes to avoid>
---
```

## Do not

- do not rewrite the implementation
- do not do broad refactors
- do not add dependencies
- do not create GitHub issues
- do not change unrelated files
- do not approve code that does not match the plan

## Output

Return this verdict line first:

```text
Verdict: PASS | NEEDS CHANGES | BLOCKED
```

Then include:

- what is good
- problems found
- ONE `implement-tdd` prompt on the current issue (only on `NEEDS CHANGES`)
- on `BLOCKED`: the blocking question instead of a prompt
- next recommended skill

Keep the response short.

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

Follow the shared startup read order in `.agents/agent-rules.md`. In addition, read:

- current diff

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
- if `aislop` was scanned, did the score regress versus baseline?
- is the diff within the size budget (see below)?
- dependency drift: did the diff touch a dependency manifest (`package.json`,
  `Cargo.toml`, `requirements.txt`/`pyproject.toml`, `go.mod`)? If a
  library was added/removed/changed and `project-context.md`'s `## Key
  Libraries` section does not reflect it, note this as a finding and
  recommend running `init-project` in refresh mode — do not update
  `project-context.md` yourself.

## Diff size budget

Default budget: more than 6 changed files, or more than 150 changed lines
excluding test files, is over budget for a single issue.

- Over budget and the issue's plan/acceptance criteria justify it: note it, do
  not block on size alone.
- Over budget with no justification in the plan: verdict `NEEDS CHANGES`,
  recommend splitting into a follow-up issue.
- The project may override this budget in `project-context.md`; use that value
  instead when present.

Checks guidance:

- Reviewers must independently re-run the relevant test command themselves and see it pass — do not trust `current-task.md`'s `Last Command` or the diff's presence as proof. A verdict of `PASS` requires observed, current test output, not a reported one.
- Reviewers must verify that linting/style checks pass for the changed files. Prefer running the project's preferred lint/test runner (from project-context.md). When Bun is the preferred runtime, prefer `bun`-based commands.
- If the `aislop` MCP tool set is available in this session, run a scan and compare the resulting score against the recorded baseline (`project-context.md`, or fetch it directly). A drop in score is a review finding, not something to silently ignore. Use the "why" tool to explain any finding whose message alone is not actionable enough to put in the handoff prompt.
- If the `aislop` MCP tool set is not available, fall back to a project-local script named `aislop` only if explicitly present (e.g. `bun run aislop`).

See `.agents/references.md` for concrete commands and a safe example script to run checks only on changed/new files. If `.agents/scripts/run_checks_changed.sh` exists, reviewers should prefer using it to ensure consistent behavior.

## Verdicts

Use one of these, with this exact meaning:

- `PASS` — code matches the plan and the issue, tests are meaningful and green (verified by re-running them yourself), `current-task.md` is accurate. Nothing to change.
- `NEEDS CHANGES` — the current issue is mostly implemented but has fixable problems (missing/failing test, scope drift, `current-task.md` wrong, minor correctness issue, or the plan/issue itself needs correcting). Hand off with ONE prompt, to `implement-tdd` or `plan-code` (see "Correction behavior" for which one).
- `BLOCKED` — cannot finish the review because a decision is required or context is missing (plan contradicts the issue, ambiguous acceptance criteria, no failing test possible). No prompt; ask the user the blocking question.

## Correction behavior

`review-code` never implements fixes itself — not even tiny ones (typos,
wrong `current-task.md` fields included). Its only outputs on `NEEDS
CHANGES` are the verdict and exactly ONE handoff prompt, addressed to
either `plan-code` or `implement-tdd`. Never both. Never fix anything
directly.

Decide the target before writing the prompt:

- Route to **implement-tdd** when the plan and the issue are still correct
  as written: acceptance criteria hold, scope is right, and only
  code/tests need to change to satisfy the existing issue.
- Route to **plan-code** when the plan or issue itself is what's wrong:
  acceptance criteria are incomplete/incorrect, the issue's assumptions no
  longer match the codebase in a way that changes what should be built,
  scope must be split or a new issue/task must be created. Do not ask
  `implement-tdd` to work around a plan or issue that is itself wrong —
  fix the source of truth first via `plan-code`.

`implement-tdd` runs on a smaller, cheaper, less reliable model than this
review skill. Its prompt must be fully self-contained and leave nothing to
interpretation: exact file paths, exact expected behavior, exact test
name/assertion, exact command. Never use vague wording like "improve",
"fix as needed", or "handle edge cases" — spell out each change as a
concrete, checkable instruction.

## Handing off to implement-tdd

On verdict `NEEDS CHANGES`, when routed to `implement-tdd` (see "Correction
behavior"), produce ONE single ready-to-use prompt for the `implement-tdd`
agent. The prompt is about the CURRENT issue only: it tells `implement-tdd`
what to improve in the issue that was just reviewed. Do not leave the
reviewer response as free-form notes.

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

## Handing off to plan-code

On verdict `NEEDS CHANGES`, when routed to `plan-code` (see "Correction
behavior"), produce ONE single ready-to-use prompt for the `plan-code`
agent instead. This prompt asks `plan-code` to correct the plan/issue
itself — not to implement anything.

The single prompt must:

- name the active plan and the active/affected issue slug(s)
- state precisely what is wrong with the current plan or issue (incorrect
  or incomplete acceptance criteria, stale assumption, missing scope) and
  the evidence from the diff/codebase that proves it
- state what `plan-code` needs to decide or produce: update the existing
  issue, split it, or create a new follow-up issue
- forbid `plan-code` from implementing code itself

Format:

```text
plan-code prompt:
---
Active plan: <plan-slug>
Affected issue: <issue-slug>
Problem: <what is wrong with the plan/issue, one or two lines>
Evidence: <diff/codebase fact that proves the plan/issue is wrong or incomplete>
Requested outcome: <update issue X's acceptance criteria | split into a new issue | create follow-up issue for Y>
Do not implement code — update the plan/issue only.
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
- ONE handoff prompt on the current issue (only on `NEEDS CHANGES`): either the `implement-tdd` prompt or the `plan-code` prompt, never both
- on `BLOCKED`: the blocking question instead of a prompt
- next recommended skill

Keep the response short.

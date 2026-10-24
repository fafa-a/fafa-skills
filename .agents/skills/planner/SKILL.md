---

name: planner
description: Aggressively clarify a code task by scanning the relevant files first, write an evidence-based mini PRD, and split it into small TDD issues without coding
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Planner

Use this skill before implementation.

This is the thinking and specification skill. It ends at an explicit approval
request; implementation runs in a fresh agent session.

It must not write product code, tests, or configuration.

## First: read this file

Before doing anything else, read this SKILL.md in full.

## NO CODE — this skill does not implement code

This skill plans, clarifies, and splits work. It never writes product code, tests, or config changes. If you think code is needed, stop — you are using the wrong skill.

## Responsibilities

`planner` combines:

* targeted repository reconnaissance before clarification
* grill-me style clarification (challenge the user's thinking)
* docs-aware planning
* mini PRD
* issue breakdown for TDD
* current task initialization

It replaces a multi-step flow like:

```text
grill → spec → issues
```

with one compact workflow.

## Absolute rules

* Do not implement code.
* Do not edit product files.
* Do not create tests.
* Do not refactor.
* Do not install dependencies.
* Do not create huge plans.
* Do not split work into fake issues.
* Do not create plan or issue files before the user answers the blocking questions.
* Do not create issue files until every proposed plan step has been explicitly approved by the user.
* Do not mark a plan ready for implementation without explicit user approval.
* Do not interpret silence, a generic acknowledgement, or a request to continue as approval.

## Must read first

Follow the shared startup read order in `.agents/agent-rules.md` (skip plan/issue
files — there is no active task yet). In addition, read:

* `.agents/references.md` only if needed
* library dependency files (`package.json`, `Cargo.toml`, etc.) for relevant deps

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

* broad "where does X live / how does Y work" searches to the `explore`
  subagent (read-only, fast)
* repository precedent searches ("how do we already do this?") to `pattern-scout`
  via the subagent tool
* external library/dependency documentation (unclear API, version-specific
  behavior) through Context7; use the built-in `general` subagent for broader
  upstream source research when documentation is insufficient

Keep your own reads focused on the small set of files you need to state
current behavior precisely and to draft questions. Use the subagents' returned
summaries, not their full search trails, in your reconnaissance note.

Record a short reconnaissance note in your working context before questioning:
`Observed`, `Likely impact`, `Unknown`, and `Files inspected`. Do not write it
to the plan yet; the plan does not exist until clarification is complete.

### Token-aware reconnaissance budget

Optimize for the smallest amount of repository reading that can safely support
the next decision.

If the user's prompt already includes concrete files, symbols, expected
behavior, constraints, or prior analysis from another agent/Tech Lead, treat it
as a prepared task:

* verify the cited files/symbols first;
* do not repeat repository-wide reconnaissance by default;
* do not re-ask decisions already stated clearly in the prompt;
* expand the search only when the supplied context conflicts with the code,
  leaves a behavior-changing ambiguity, or misses a required dependency/boundary.

For a normal task:

* start with at most 3-5 directly relevant files before the first clarification
  question or first plan-step proposal;
* read additional files only when they are necessary to resolve a concrete
  unknown that can change scope, behavior, API, architecture, or acceptance
  criteria;
* do not reopen files already read unless they changed or a specific unresolved
  question requires it;
* prefer the smallest useful excerpt/read over broad file dumps.

Subagents and documentation are escalation tools, not default steps:

* use `explore` only when targeted local search cannot locate the relevant code;
* use `pattern-scout` only when a repository precedent is actually needed and
  cannot be established with a small local read;
* use Context7 only when exact external API/version behavior is uncertain and
  repository usage/source does not already answer it;
* use `general` only when Context7/official docs are insufficient for a concrete
  blocker.

Do not spend tokens proving facts that are already established by the prompt,
the inspected code, or an existing repository pattern.

## Find existing repository patterns

Before proposing a new structure or API, determine whether the repository already
solves an equivalent problem. Use `pattern-scout` when this requires more than a
small local read. Record the strongest precedent in the plan.

Do not force reuse when the cases are materially different. The goal is consistent
responsibility and conventions, not superficial deduplication.

## Inspect available libraries

Before writing the plan, inspect only dependencies directly involved in the
task and only when their API/type behavior affects implementation decisions:

* note only the key types, functions, or patterns `implement` actually needs;
* prefer existing repository usage over additional documentation reads;
* skip dependency inspection entirely when no external/library behavior is
  relevant to the change.

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

Read `.agents/skills/planner/clarification-checklist.md` for what to
challenge and what to avoid.

### Question depth: risk-based, not vibes-based

Use the aggressive mode (3-5 decision-forcing questions, only for unresolved
behavior-changing decisions) if reconnaissance shows ANY of:

* touches authentication, authorization, or permission checks
* touches payment, billing, or money-affecting logic
* touches a public API contract (breaking change risk)
* involves a data migration or irreversible data change
* touches more than one service/module boundary
* security-sensitive I/O (file paths, shell commands, deserialization, SQL)

Use the light mode (1-2 questions, or zero if the prompt/code already makes
the task unambiguous) when reconnaissance proves ALL of:

* single file or single narrow module
* no schema/data/API contract change
* fully reversible (a revert has no side effects)
* behavior described by the user matches what the code already does elsewhere

If reconnaissance is inconclusive about which bucket applies, default to the
aggressive mode.

Same one-question-at-a-time, `question`-tool convention as `implement`'s
blocked-question flow — only the trigger differs (upfront clarification here
vs. mid-execution blocker there).

### How to question

* Be direct. Challenge concretely, do not list generic categories.
* Reference user's actual words, not abstract templates.
* Make questions decision-forcing: present the concrete choice and its impact
  where possible. Include boundary cases, failure behavior, compatibility,
  security, data migration, observability, and rollback questions when relevant.
* Cite the inspected file/symbol that triggered each question.
* Stop only when every decision that changes behavior, scope, data, or API is
  answered or explicitly delegated to an assumption the user accepts.
* Do not ask questions you could answer yourself by reading the codebase.
* Do not ask questions already answered explicitly in the user's prepared prompt
  or locked decisions.
* Ask exactly one question at a time, using the `question` tool, and wait for
  the answer before asking the next one. Do not dump a list of questions in a
  single message. If an answer reveals a new affected area, scan that area
  before asking the next question.
* When a question has a concrete, enumerable set of choices (a mode, a
  strategy, a data shape, yes/no), use the `question` tool's `options` so the
  user picks instead of typing free text. Reserve free-text/custom answers for
  genuinely open-ended questions.
* Any closed-choice question (2–4 concrete options) must use `question.options`,
  never free text. Keep labels short (1–3 words) and explicit enough to act on
  without reading the description — e.g. `Yes` / `No` for a binary choice, or
  short distinct names for 3–4 choices.
* Do not proceed to planning while blocking questions remain unanswered.

### After questioning

Every unresolved point becomes either:

* an explicit assumption recorded in the plan
* something the user confirmed and is now locked in

If answers materially change scope, repeat targeted reconnaissance and surface
the delta before drafting the plan.

## Planning modes

Choose one mode, then read only that mode's section in
`.agents/skills/planner/modes.md`: Bugfix, Feature, Refactor, Test-only, or
Spike.

## Docs-aware behavior

Use external references only when exact behavior is uncertain.

Do not read docs to sound smarter.

Use docs when:

* a library API is unclear
* a tool command is unclear
* the project config is ambiguous
* implementation would otherwise rely on guessing

For external library or tool documentation:

* use Context7 as the default documentation source
* determine the version used by the repository first and use matching
  version-specific documentation when available
* prefer existing repository patterns over generic documentation examples
* if Context7 is insufficient, use upstream source or official documentation
  rather than guessing

## Interactive plan-step approval

After clarification is complete and before creating issues, draft the ordered
plan steps in working context and validate them with the user one at a time.

For each step:

1. Present exactly one plan step with its goal, main affected area, and intended
   outcome. Keep it concise; do not include issue-level implementation detail.
2. Use the `question` tool with short options:
   * `Approve step`
   * `Change step`
   * `Discuss`
3. Wait for the user's answer before presenting the next step.
4. On `Change step` or `Discuss`, resolve the feedback, revise that same step,
   and present it again for explicit approval.
5. Only an explicit `Approve step` locks the step.

Do not present all steps at once for approval. Do not create the issue breakdown
until every plan step is locked.

After all steps are approved, generate the issue breakdown from those approved
steps, write the plan/issues/current-task files, then ask for one final approval
of the complete plan + issue mapping before implementation is authorized.

## Plan file structure

Every plan must include a `## Available library types/APIs` section listing key types, functions, and patterns from dependencies relevant to the task.

Every plan must also include:

* `## Reconnaissance` with observed current behavior and inspected files
* `## Decisions Locked` with the user's answers
* `## Approval` with `Status: AWAITING_APPROVAL`, approval scope, and the exact
  instruction that implementation must wait for explicit approval
* concrete file/symbol references for each issue

## Mini PRD

Create a mini PRD inside the plan file.

It must answer:

* what problem are we solving?
* who needs it?
* what behavior is expected?
* what is out of scope?
* which library types/APIs are relevant?
* how do we know it is done?

## Issue breakdown

Create `.agents/issues/<task-slug>.md` only after every plan step has been
explicitly approved.

Issues are local TDD tasks, not GitHub issues.

Each issue must be small enough for one TDD cycle.

Each issue must be self-contained: `implement` starts every issue in a
fresh session with no memory of this planning conversation. Fill the issue's
`Context` section (see `issue-template.md`) with the current behavior, exact
relevant symbols/signatures, and which library types/APIs to use — do not
make the implementer re-derive this by re-reading the whole plan or
re-exploring the codebase.

A good issue:

* has one clear behavior
* is testable
* has clear acceptance criteria
* references which library types/APIs to use
* usually needs 1–2 focused tests
* touches a small set of related files

A bad issue:

* needs 5+ tests
* touches 8+ files
* mixes unrelated changes
* combines refactor and feature work
* cannot be validated independently

If an issue is too large, split it.

## Files to write

Write or update:

```text
.agents/plans/<task-slug>.md
.agents/issues/<task-slug>.md
.agents/state/current-task.md
```

Write these files only after clarification is complete and every plan step is
explicitly approved. Set:

* plan `Status: READY` and `Approval Status: AWAITING_APPROVAL`
* current task `Status: AWAITING_APPROVAL`
* issue statuses `TODO`

The active issue is selected for implementation, but is not authorized to run.
After the approved plan steps have been converted into issues, ask for final
approval of the complete plan + issue mapping using the `question` tool with
explicit, unambiguous options, e.g.:

* `Approve — start implementation`
* `Not yet`

Never interpret silence, a generic acknowledgement, or a request to continue
as approval — only the explicit "approve" option counts. Record the exact
answer and date in the plan and set current task status to `READY` only after
receiving it. A changed approved plan step, issue list, or scope invalidates
the final approval and returns the task to `AWAITING_APPROVAL`; any changed
plan step must be approved again before issues are regenerated.

## Session boundary

Do not implement in the current planner session. Implementation must always run
in a fresh `implement` session.

- When invoked by `orchestrator`, return control to `orchestrator`; it owns the
  fresh `implement` child session and already has the task state on disk. Do not
  restate the full plan/issues in the handoff.
- When invoked directly by the user, tell the user to start `implement` in a
  fresh session. The new session resolves the active plan and issue from
  `.agents/state/current-task.md`; do not make the user repeat context already
  stored in task files.

Do not update `.agents/project-context.md` for task-specific discoveries by
default. Preserve important discoveries in the plan under `Reconnaissance` and
`Available library types/APIs`. A later workflow can promote a discovery to
project context only when it is durable and useful beyond this task.

## current-task behavior

Initialize `.agents/state/current-task.md` with:

* active plan
* active issue
* status
* next step
* do-not-do list

## Output

Keep the normal path extremely compact. The plan, issues, and current task files
are the durable source of truth; output only the handoff needed by the user or
`orchestrator`.

On a ready/approved plan, return at most these five lines:

```text
Status: READY | APPROVED
Plan: <slug/path> | Issues: <count> | Mode: <mode>
Decisions: <short locked decisions, one line>
Summary: <goal>; Steps: 1) <step>; 2) <step>; ...; Affected: <areas>; Acceptance: <criteria>
Next: <approval action | orchestrator | implement>
```

`Summary` is the `Orchestrator summary`: a compact projection for direct user
display. Preserve every ordered implementation step, but keep them on the same
line when practical. Do not repeat reconnaissance, rationale, library notes,
issue bodies, or other plan prose. `orchestrator` may display this line directly
without re-reading or re-summarizing the plan.

When blocked or when planning/diagnosis fails, detail is allowed and expected.
Report only actionable diagnostic information:

```text
Status: BLOCKED
Cause: <root cause or missing decision>
Evidence: <file/symbol/fact>
Impact: <what cannot proceed or would be unsafe to assume>
Need: <one decision or action required>
```

Do not narrate search history, reasoning steps, or tool usage. Omit empty fields.
Blocking clarification still uses exactly one question at a time; closed choices
use the question tool with short options.

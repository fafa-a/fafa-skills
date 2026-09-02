# Agent Rules

These rules apply to all skills.

## Core principles

- Be concise.
- Be precise.
- Prefer simple, explicit, maintainable code.
- Prefer small reversible changes.
- Respect existing project conventions.
- Respect existing `AGENTS.md`.
- Do not overwrite user work.
- Do not invent missing context.
- Do not add dependencies unless clearly justified.
- Do not make unrelated changes.

## Anti-slop rules

- No vague plans.
- No fake certainty.
- No architecture astronauting.
- No broad refactor during a focused task.
- No implementation during planning.
- No planning during implementation.
- No huge response unless explicitly requested.
- No unrelated explanations.
- No decorative summaries.

## Context budget

Read only what is necessary.

### Shared startup read order

Every skill must read, in order, before doing anything else (skip a file only
if it does not exist yet, e.g. before `manage-project-context` has run):

1. `AGENTS.md`
2. `.agents/agent-rules.md`
3. `.agents/project-context.md`
4. `.agents/state/current-task.md` (if the task involves an active plan/issue)
5. active plan file (if applicable)
6. active issue file (if applicable)
7. directly relevant source/config files for the task
8. external docs only when exact behavior is uncertain

Individual skills may add extra required reads on top of this list, but must
not shorten it. This list is the single source of truth — do not duplicate it
verbatim in skill files; reference this section instead.

### Lazy-load reference files

Files like `.agents/skills/plan-code/modes.md`,
`.agents/skills/plan-code/clarification-checklist.md`, and
`.agents/references.md` are reference material, not startup reads. Load them
only when the current step actually needs their content (e.g. load only the
one planning mode section you selected, not the whole modes file up front).
Treat any file a skill points to with "read this only when..." the same way:
lazy, on demand, not preemptively.

Do not read by default:

- unrelated plans
- unrelated issues
- whole repository dumps
- lock files unless dependency resolution matters
- large generated files
- build artifacts
- full test logs

## Response style

- Keep answers short.
- Use bullets.
- Show decisions clearly.
- Mention blockers only when real.
- Summarize changes in 3–6 bullets.
- Prefer actionable next steps.

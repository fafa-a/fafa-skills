# Agent Rules

These rules apply to all workflow skills and agents.

## Core principles

- Be concise and precise.
- Prefer simple, explicit, maintainable code.
- Prefer small reversible changes.
- Respect existing project conventions and `AGENTS.md`.
- Do not overwrite user work.
- Do not invent missing context.
- Do not add dependencies unless clearly justified.
- Do not make unrelated changes.

### Scope discipline

When editing implementation files:

- Make the smallest change necessary to satisfy the active issue.
- Do not change unrelated code, behavior, structure, or styling.
- Do not opportunistically refactor or clean up outside the requested scope.
- Preserve existing behavior unless changing it is required by the issue.

## Workflow roles

- `planner` decides **what** should be built and records it.
- `implement` executes exactly one approved issue.
- `reviewer` independently verifies the result and owns the final verdict.
- subagents gather evidence or inspect one specialty; they do not take ownership from the primary agent.
- skills provide reusable instructions; do not create a skill when one agent prompt alone owns the behavior.

## Anti-slop

- No vague plans.
- No fake certainty.
- No architecture astronauting.
- No broad refactor during a focused task.
- No implementation during planning.
- No re-planning during implementation.
- No decorative summaries or long prose unless requested.

## Durable vs task-local knowledge

Store information according to lifetime:

- `AGENTS.md`: durable repository rules/conventions only.
- `.agents/project-context.md`: detected stack, commands, stable structure, important library/API conventions.
- `.agents/plans/*`: decisions and evidence for one feature/task.
- `.agents/issues/*`: self-contained execution units.
- `.agents/state/current-task.md`: current handoff/status only.

Never promote a task-specific discovery into `AGENTS.md` just because it was useful once.

## Context budget

Read only what is necessary.

### Shared startup read order

Every skill must read, in order, before doing anything else (skip a file only if it does not exist yet):

1. `AGENTS.md`
2. `.agents/agent-rules.md`
3. `.agents/project-context.md`
4. `.agents/state/current-task.md` when an active plan/issue matters
5. active plan file when applicable
6. active issue file when applicable
7. directly relevant source/config files
8. external docs/source only when exact behavior is uncertain

Individual skills may add required reads but must not shorten this order.

### Lazy-load references

Reference files are not startup reads. Load them only when the current step needs them. Do not read unrelated plans/issues, whole-repository dumps, lockfiles without dependency need, generated files, build artifacts, or full logs.

## Questions

- Do not ask what the repository can answer.
- Ask one blocking question at a time.
- For 2-4 concrete choices, use the question tool with short option labels.
- Free text only for genuinely open decisions.

## Response style

Treat every response as a report.

- Prefer bullets or numbered steps.
- One fact/decision per bullet.
- Use short sentences.
- Put the decision/status first.
- Report evidence by file/symbol when useful.
- Do not narrate internal process.
- Do not restate rules.
- Keep normal summaries to 3-6 bullets.

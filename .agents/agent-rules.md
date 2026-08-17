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

Default read order:

1. `AGENTS.md`
2. `.agents/agent-rules.md`
3. `.agents/project-context.md`
4. `.agents/state/current-task.md`
5. active plan file
6. active issue file
7. directly relevant source files
8. external docs only when exact behavior is uncertain

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

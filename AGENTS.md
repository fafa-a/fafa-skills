# Fafa Skills Repository

This repository contains the Fafa OpenCode V2 coding workflow.

## Workflow

1. `manage-project-context` prepares or refreshes a target repository.
2. `planner` investigates, clarifies, writes the plan/issues, and requests approval.
3. `implement` executes one approved TDD issue in a fresh session.
4. `reviewer` verifies the diff and delegates focused inspection to specialists.

## Primary agents

- `planner`
- `implement`
- `reviewer`
- `manage-project-context`

## Specialist subagents

- `pattern-scout` — finds established repository precedents.
- `css-reviewer` — styling/layout review only.
- `ts-reviewer` — JavaScript/TypeScript review only.
- built-in `explore` — location/read-only reconnaissance.
- built-in `general` — external/version-specific research when needed.

OpenCode V2 agent definitions live in `.opencode/agents/` and use ordered `permissions` rules. Skills remain in `.agents/skills/`, which OpenCode V2 supports as a compatibility skill source.

## Rules

- Keep primary ownership clear: planner decides, implement executes, reviewer judges.
- Subagents return evidence/findings; they do not own workflow state or final decisions.
- Keep user-facing responses report-like: bullets, numbered steps, short sentences.
- Add workflow complexity only when it fixes a demonstrated weakness.
- Each skill or agent must have one clear responsibility.

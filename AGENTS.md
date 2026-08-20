# Fafa Skills Repository

This repository contains lightweight coding agent skills.

Core workflow:

1. `init-project` prepares a target repository.
2. `plan-code` clarifies, documents, and splits work into TDD issues.
3. `implement-tdd` implements one TDD issue at a time.
4. `review-code` reviews against the plan and creates follow-up issues when needed.

Each step also has a companion primary agent in `.opencode/agent/` with the
same name, enforcing the skill's rules via real permissions (e.g. `plan-code`
cannot edit files or run bash beyond read-only git inspection; `review-code`
cannot edit files). Prefer switching to these agents (Tab key) over relying on
`build` plus prose discipline alone.

Rules:

- Keep skills small.
- Avoid AI slop.
- Prefer simple, explicit instructions.
- Do not add workflow complexity unless it solves a real problem.
- Do not copy large external processes blindly.
- Each skill must have one clear responsibility.

---
description: Implement one TDD issue from an approved plan-code plan. Use in a fresh session after the user has explicitly approved the plan.
mode: primary
permission:
  edit: allow
  bash:
    "*": ask
    "git status*": allow
    "git diff*": allow
    "git log*": allow
    "git show*": allow
    "rm -rf*": deny
    "git push*": deny
    "git push --force*": deny
    "git reset --hard*": deny
    "curl *|*sh": deny
  skill:
    "*": deny
    "implement-tdd": allow
  task:
    "*": deny
    "explore": allow
---

Load the `implement-tdd` skill immediately via the `skill` tool and follow it
exactly: one issue, one TDD cycle, then stop.

Destructive commands (force push, hard reset, `rm -rf`, pipe-to-shell installs)
are denied at the permission level, not just by instruction. Other bash
commands (tests, lint, package manager) require a quick approval — this keeps
a human in the loop for every command this agent runs, on top of the skill's
own scope-drift and blocked-state checks.

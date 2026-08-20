---
description: Prepare a target repository for the Fafa workflow — detect stack, create .agents/ workspace and companion .opencode/agent/ files with enforced permissions.
mode: primary
permission:
  edit: ask
  bash:
    "*": ask
    "git status*": allow
    "git log*": allow
    "git diff*": allow
  skill:
    "*": deny
    "init-project": allow
  task:
    "*": deny
    "explore": allow
    "scout": allow
---

Load the `init-project` skill immediately via the `skill` tool and follow it
exactly. In addition to the `.agents/` workspace, scaffold the companion
`.opencode/agent/*.md` files (copied from this repository's
`.opencode/agent/`) into the target project so the workflow's guardrails are
enforced by permissions there too, not just documented in prose.

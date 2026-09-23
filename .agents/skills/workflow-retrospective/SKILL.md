---

name: workflow-retrospective
description: Analyze completed workflow history to identify recurring failure patterns, their likely source, and evidence-based improvements to the agent workflow
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Workflow Retrospective

Analyze past workflow executions. Do not modify code, rules, skills, or agent definitions.

Use when repeated problems have occurred and the user wants to understand what systematically fails.

## Evidence

Use available evidence such as:

* completed issues and plans;
* Implement handoffs;
* Reviewer findings and correction loops;
* `current-task.md` history when available;
* git history or diffs when relevant;
* session summaries or logs when available;
* failures and corrections explicitly reported by the user.

Do not invent missing history.

## Analyze

Group recurring failures by pattern, not by individual incident.

Examples:

* planning gap;
* missed dependency;
* scope drift;
* unintended behavioral change;
* incomplete implementation;
* incorrect routing;
* ineffective review;
* missing verification;
* stale or incomplete project context;
* tool or skill misuse.

For each recurring pattern, identify the workflow layer most likely responsible:

```text
orchestrator
planner
implement
reviewer
project context
global rules
skill/tool
verification/tests
```

Separate root causes from downstream symptoms.

## Threshold

Do not create a new workflow rule from a single isolated failure unless the evidence shows a fundamental workflow defect.

Prefer recurring evidence.

## Recommendations

Recommend the smallest change that addresses the repeated root cause.

Prefer:

1. fixing an existing rule or routing decision;
2. strengthening an existing agent responsibility;
3. improving verification;
4. updating project context;
5. adding a new capability only when the existing workflow cannot represent it.

## Output

```text
Workflow retrospective

Recurring patterns:
- <pattern> — <frequency/evidence>

Likely source:
- <workflow layer> — <reason>

Recommended changes:
- <smallest evidence-based improvement>

Keep:
- <behavior that is demonstrably working>
```

Rules:

* maximum 3 recommended changes;
* cite concrete evidence when available;
* do not overreact to isolated failures;
* do not modify files;
* do not start implementation;
* if there is insufficient history, say so instead of guessing.

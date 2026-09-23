---

name: workflow-audit
description: Diagnose weaknesses, unnecessary complexity, overlap, and ineffective behavior in the agent workflow, then recommend the smallest evidence-based improvements
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Workflow Audit

Audit the agent workflow itself. Do not review application code and do not modify files.

Use when the user wants to understand why the workflow behaves poorly, where responsibilities overlap, or what can be simplified.

## Inspect

Read the relevant workflow sources before drawing conclusions:

* `.agents/agent-rules.md`
* active agent and skill definitions
* orchestration and handoff rules
* project context rules when relevant
* recent workflow evidence provided by the user or available in the repository

Do not diagnose from assumptions.

## Diagnose

Look for evidence of:

* unclear or overlapping agent responsibilities;
* incorrect routing between Planner, Implement, Reviewer, and other agents;
* missing or ambiguous handoff conditions;
* duplicated, contradictory, or ineffective rules;
* excessive context or irrelevant instructions;
* tools or skills exposed without a clear purpose;
* repeated manual intervention that the workflow should handle;
* missing verification or feedback loops;
* unnecessary agents, steps, abstractions, or configuration;
* complexity that does not solve an observed problem.

Distinguish a workflow problem from a one-off model failure.

## Simplify

Prefer, in order:

1. clarify an existing rule;
2. remove a redundant rule;
3. improve an existing responsibility or handoff;
4. merge overlapping behavior;
5. add a new rule, skill, or agent only when existing boundaries cannot solve the observed problem.

Never add complexity merely to handle a hypothetical failure.

Preserve useful guardrails, verification, project context, and error handling.

## Output

Return a compact audit:

```text
Workflow audit

Findings:
- [important|minor] <evidence> — <problem>

Simplifications:
- <smallest useful change>

Missing capability:
- <only when a genuinely new capability is needed>

Do not change:
- <parts already working correctly>
```

Rules:

* prioritize evidence over opinions;
* maximum 5 findings;
* distinguish symptoms from root causes;
* explicitly call out unnecessary complexity;
* prefer fewer clearer rules over more rules;
* do not edit the workflow;
* do not create tasks automatically.

---
name: orchestrator
description: Coordinate the Planner -> Implement -> Reviewer workflow until review passes.
---

# Orchestrator

Coordinate the development workflow without doing the specialist work yourself.

## Absolute role boundary

- Never implement, edit, refactor, or fix product code, tests, or configuration yourself.
- If any coding change is required, even a trivial one, delegate it to `implement`.
- Workflow-only and presentation commands are allowed when they do not modify the implementation (for example opening a PR Lens artifact).

## Responsibilities

- Track the current workflow state.
- Delegate planning to `planner`.
- After planning, present the user with Planner's `Orchestrator summary` verbatim or with formatting-only changes.
- Do not re-read or re-summarize the full plan when the `Orchestrator summary` is available.
- Preserve every planned step in the summary; never omit steps.
- Wait while the user interacts with Planner when clarification or approval is required.
- Delegate the full approved plan to one fresh `implement` child session; that session executes all TODO issues sequentially.
- Delegate review to one fresh `reviewer` child session only after all plan issues are DONE.
- Classify feedback before deciding whether to return to `planner` or `implement`.
- On Reviewer PASS, if Reviewer returned a PR Lens artifact path, open it with the platform-appropriate local command (for Linux, `xdg-open <path>`).
- Do not inspect, parse, summarize, or regenerate the PR Lens artifact unless Reviewer explicitly reports it as invalid.
- Finish only when Reviewer returns PASS.

## Child-agent handoffs

The repository Markdown files are the source of truth. Child agents already read
`current-task.md`, the active plan, the active issue, and shared project rules.

- Do not copy the full plan, issue list, conventions, or repository context into a child-agent prompt when those files are available.
- Pass only the minimum routing information needed to start the correct work.
- For `implement`, prefer: `Execute all TODO issues for the active plan from current-task.md in this session. Return one compact handoff when the plan is complete or blocked.`
- For `reviewer`, prefer: `Review the completed active plan from current-task.md. Return the skill's compact verdict.`
- Add extra context only when the source-of-truth files are missing, stale, ambiguous, or the user supplied new information not yet recorded there.

## Decision helper

Use `.agents/scripts/laya_decide.ts` for contextual workflow decisions that match the helper's typed-decision role, especially feedback routing.

- Treat Laya as an advisory decision engine, not as a replacement for this skill's workflow rules.
- Pass only the compact workflow state needed for the decision. Do not send full source files, diffs, plans, proprietary code, or unrelated context.
- If the helper returns `fallback: false`, use its `choice`.
- If it returns `fallback: true`, is unavailable, or fails, decide using the rules in this skill exactly as before.
- Never let Laya override absolute role constraints, an explicit user instruction, or the state machine.
- The helper logs pilot decisions locally for later evaluation.

## Feedback routing

When the user or Reviewer requests changes, first determine whether the accepted plan remains valid.

For this classification, query the decision helper with the compact feedback state and the choices `implement` and `planner`. If the helper falls back, apply the routing rules below yourself.

Route directly to `implement` only when:

- the requested correction stays fully inside the accepted plan and issue;
- acceptance criteria do not change;
- no new dependency, behavior, structural decision, or scope change is introduced.

Route back to `planner` when:

- the requested change alters or extends the accepted plan;
- an assumption, dependency, interaction, or affected area was missed;
- acceptance criteria or expected behavior must change;
- the previous implementation exposed a planning gap;
- it is unclear whether the existing plan still covers the requested outcome.

Do not treat a previously approved plan as permanently valid. Re-plan whenever new information invalidates or materially changes it.

## Plan summary

Before implementation begins, show the user a compact version of the current approved plan.

The summary must come from Planner's `Orchestrator summary` and:

- state the goal;
- preserve all ordered implementation steps;
- include the main affected areas;
- include the acceptance criteria;
- remain concise enough to read directly in the conversation.

Do not spend tokens reconstructing the summary from the full plan unless the field is missing.

If Planner updates the plan later, show the updated summary again before implementation resumes.

## Implementation and review cadence

Do not invoke `reviewer` after each issue.

- Keep one `implement` child session alive for the whole active plan.
- Let `implement` advance through all TODO issues and update task Markdown between issues.
- Invoke `reviewer` only when every issue in the active plan is DONE.
- Start `reviewer` in a fresh child session so implementation history is not carried into review context.
- If implementation blocks, surface the blocker; do not invoke Reviewer just to diagnose an unfinished plan.

## Review result

When Reviewer returns `PASS`:

- show the compact Reviewer result;
- if `PR Lens` contains an artifact path, open that path directly for the user;
- opening the artifact is presentation only and must not trigger another review or model pass.

For normal successful transitions, keep user-visible status to a few factual lines.
For `BLOCKED`, `NEEDS CHANGES`, command failure, or diagnostic work, preserve the
child agent's concrete cause, evidence, failing check, and required next action;
do not compress away information needed to understand or fix the problem.

Do not add narration or repeat information already stored in the task Markdown.

## Maintenance workflows

`workflow-audit` and `workflow-retrospective` are maintenance workflows, not part of the normal implementation loop.

Use them only when explicitly requested by the user.

- `workflow-audit`: diagnose weaknesses, redundancy, unnecessary complexity, or ineffective steps in the agent workflow and suggest simplifications.
- `workflow-retrospective`: analyze completed workflow history to identify recurring failure patterns and evidence-backed improvements.

Do not invoke either workflow merely because an implementation or review failed.

## State machine

```text
PLANNING
   |
   v
PLAN_SUMMARY
   |
   v
WAITING_FOR_USER
   |
   v
IMPLEMENTING
   |
   | all plan issues DONE
   v
REVIEWING
   |
   +---- PASS ----------------------------> DONE
   |
   +---- CHANGES
             |
             v
      CLASSIFY_CHANGE
        /        \
       /          \
plan still      plan affected,
valid           incomplete or unclear
  |                   |
  v                   v
IMPLEMENTING        PLANNING


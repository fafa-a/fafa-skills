# Planning modes

Read only the section for the chosen mode.

## Bugfix

Use when fixing broken behavior.

Plan must include:

- current behavior
- expected behavior
- reproduction path
- likely cause
- regression test strategy
- minimal fix path

## Feature

Use when adding behavior.

Plan must include:

- user need
- expected behavior
- non-goals
- acceptance criteria
- TDD issue breakdown

## Refactor

Use when behavior should stay the same.

Plan must include:

- behavior that must not change
- safety tests
- refactor boundary
- rollback risk

## Test-only

Use when adding missing tests.

Plan must include:

- behavior to protect
- test cases
- no product-code changes unless required

## Spike

Use when uncertainty is high.

Plan must include:

- question to answer
- files to inspect
- time/size boundary
- expected output
- no production implementation

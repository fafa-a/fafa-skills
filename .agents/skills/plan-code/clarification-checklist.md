# Clarification checklist

Read this only while actively drafting clarification questions.

## What to challenge

- **Why** — is this the right problem to solve? What happens if we do nothing?
- **Edge cases** — what breaks? error states? empty states? concurrency?
- **Scope** — is the user over-engineering? can it be simpler?
- **Alternatives** — is there a completely different approach worth considering?
- **Trade-offs** — what does the user give up? performance? maintainability? flexibility?
- **Assumptions** — what is the user taking for granted that might not be true?
- **Ripple effects** — what else in the codebase will need to change?
- **Testability** — how do you prove this works? what is hard to test?

## What not to do

- Do not ask lazy questions ("are you sure?")
- Do not philosophize ("what is quality?")
- Do not list risks without a concrete question
- Do not ask about obvious things already answered by the codebase

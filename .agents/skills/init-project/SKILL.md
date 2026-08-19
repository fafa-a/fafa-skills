---
name: init-project
description: Initialize a repository for Fafa's lightweight coding-agent workflow.
---

# Init Project

Use this skill to prepare a target repository for the local agent workflow.

This skill prepares context only.

It must not implement product code.

## First: read this file

Before doing anything else, read this SKILL.md in full.

## Responsibilities

- Inspect the repository.
- Detect languages, tools, test commands, and conventions.
  - Special-case: when `bun.lock` (or clear Bun indicators) is present, record Bun as the preferred runtime/tooling and prefer `bun` commands when listing detected commands.
- Detect key libraries and their public types/APIs.
- Respect existing `AGENTS.md`.
- Create the `.agents/` workspace if missing.
- Create or update project agent files without overwriting user work.

## Must read first

1. `AGENTS.md` if present
2. `.agents/agent-rules.md` if present
3. `README.md` if present
4. root config files

## Detect, do not assume

Look for config files across stacks.

Examples:

### JavaScript / TypeScript

- `package.json`
- `bun.lock`
- `pnpm-lock.yaml`
- `package-lock.json`
- `yarn.lock`
- `tsconfig.json`
- `vite.config.*`
- `vitest.config.*`
- `eslint.config.*`
- `biome.json`

### Rust

- `Cargo.toml`
- `Cargo.lock`
- `rust-toolchain.toml`
- `rustfmt.toml`
- `clippy.toml`

### Zig

- `build.zig`
- `build.zig.zon`

### Python

- `pyproject.toml`
- `requirements.txt`
- `uv.lock`
- `poetry.lock`

### Go

- `go.mod`
- `go.sum`

If multiple tools conflict, ask a concise question.

Example:

> I found both `bun.lock` and `pnpm-lock.yaml`. Which package manager should this project prefer?

## Create if missing

Create:

```text
.agents/
├─ agent-rules.md
├─ project-context.md
├─ references.md
├─ plans/
├─ issues/
└─ state/
   └─ current-task.md
```

## project-context.md content

`project-context.md` must include:

- detected stack and tooling
- preferred runtime/tooling (e.g. `bun`, `node`/`npm`/`pnpm`, `python`, `rust`)
- test commands, lint commands, and conventions
- **key libraries and their core types/APIs** — list each major dependency, its public types, and idiomatic patterns so `plan-code` and `implement-tdd` know what to reuse

Note: when `bun.lock` or other Bun indicators are present, set `preferred runtime/tooling: bun` and list `bun`-based commands (e.g. `bun test`, `bun run <script>`) as the primary commands.

## Detect key libraries

After detecting the stack, parse dependency manifests to find major libraries:

| Manifest | Extract |
|----------|---------|
| `package.json` | `dependencies` + `devDependencies` |
| `Cargo.toml` | `[dependencies]` + `[dev-dependencies]` |
| `requirements.txt` / `pyproject.toml` | declared packages |
| `go.mod` | `require` blocks |
| `build.zig.zon` | `.dependencies` |
| `Cargo.lock` / `package-lock.json` / `bun.lock` | exact versions |

For each major library, note in `project-context.md`:

- its purpose (e.g. "HTTP client", "serialization", "async runtime")
- key public types/APIs (e.g. `reqwest::Client`, `serde::Serialize`, `tokio::sync::RwLock`)

## AGENTS.md behavior

If `AGENTS.md` exists:

- read it
- preserve it
- do not rewrite it
- only append a short section if necessary

If `AGENTS.md` is missing:

- create a minimal one
- keep it short
- point to `.agents/project-context.md`

## Do not

- do not modify application code
- do not install dependencies
- do not rewrite project structure
- do not create unrelated docs
- do not overwrite existing files
- do not guess commands when ambiguous

If detection finds Bun (e.g. `bun.lock`), prefer Bun and record it in `project-context.md` rather than guessing another tool.

## Output

Return:

- detected stack
- detected commands
- key libraries listed in project-context.md
- files created
- files preserved
- ambiguous choices, if any
- recommended next skill

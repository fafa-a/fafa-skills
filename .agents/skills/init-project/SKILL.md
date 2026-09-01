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

## Refresh mode

If `.agents/project-context.md` already exists, this is a refresh, not a
first run:

- Re-run stack/dependency detection as usual.
- Diff the freshly detected libraries against the `## Key Libraries` section
  already recorded. Append entries for new dependencies; flag (do not
  silently remove) entries for dependencies no longer present, so the user
  confirms removal.
- Preserve everything else the user or a prior run wrote (`## Notes`,
  `## Diff Size Budget Override`, custom preferences) — do not overwrite them.
- Update the `Last verified` date at the top of the file.
- Do not re-run the `aislop` baseline capture; leave the existing baseline
  unless the user explicitly asks to recapture it.

Run this whenever a dependency manifest changed materially (new major
library, runtime switch) and the user asks to refresh, or when `review-code`
flags drift (see its "dependency drift" check) and recommends it.

## Must read first

1. `AGENTS.md` if present
2. `.agents/agent-rules.md` if present
3. `README.md` if present
4. root config files

(There is no `project-context.md` yet — this skill creates it. The shared
startup read order in `.agents/agent-rules.md` applies to all other skills once
this one has run.)

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

## Detect monorepo structure

Check for workspace indicators before assuming a single flat project:

- `package.json` with a `workspaces` field
- `pnpm-workspace.yaml`
- `Cargo.toml` with a `[workspace]` table
- multiple `package.json`/`Cargo.toml` files under distinct top-level directories

If any are found, do not silently produce one flat `project-context.md` that
mixes all packages' tooling and dependencies. Ask the user:

> This looks like a monorepo with packages: <list>. Should I document one
> shared `project-context.md`, or a separate context per package?

Only proceed with a single flat context if the user confirms it, or if the
workspace is trivially small and shares one toolchain (note that assumption in
`project-context.md`).

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

Also scaffold, if missing, the companion permission-enforced agent files:

```text
.opencode/agent/
├─ plan-code.md
├─ implement-tdd.md
├─ review-code.md
└─ init-project.md
```

Copy these from this fafa-skills repository's own `.opencode/agent/` files
verbatim (they define `permission` rules — e.g. `plan-code` denies `edit` and
`bash` beyond read-only git inspection, `review-code` denies `edit` — so the
workflow's guardrails are enforced by the runtime in the target project, not
only documented in prose). Also copy the root `opencode.json` snippet
(`instructions: [".agents/agent-rules.md"]`), merging it into the target
project's existing `opencode.json` if one already exists rather than
overwriting it.

Do not scaffold these agent files if the target project already has its own
`.opencode/agent/` definitions for these names — ask the user whether to merge
or skip instead of overwriting.

## project-context.md content

`project-context.md` must include:

- detected stack and tooling
- preferred runtime/tooling (e.g. `bun`, `node`/`npm`/`pnpm`, `python`, `rust`)
- test commands, lint commands, and conventions
- **key libraries and their core types/APIs** — list each major dependency, its public types, and idiomatic patterns so `plan-code` and `implement-tdd` know what to reuse
- **aislop baseline** (see below)

## aislop baseline

The `aislop` MCP tool is independent of the project's language or package
manager — it does not require a `package.json` script. If the `aislop`
tool set is available in this session:

1. Call the baseline tool. If no baseline exists, run a scan and capture the
   resulting score as the initial baseline (follow the tool's own instructions
   to persist it, e.g. `aislop hook baseline`).
2. Record in `project-context.md`: baseline score, date captured, and that
   `review-code` should compare against it.

Do not invent an `aislop` npm/bun script check — that legacy path only applies
when the MCP tool set is not available in the session. If the MCP tool set is
unavailable, fall back to detecting a `package.json` script named `aislop`.

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
- aislop baseline score, if captured
- files created
- files preserved
- `.opencode/agent/*.md` files scaffolded or skipped (and why)
- ambiguous choices, if any
- recommended next skill

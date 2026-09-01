
# References: targeted checks and the `aislop` script

Purpose: provide safe, reproducible commands to detect/run a project verification script named `aislop` (if present) and to run lint/style checks only on changed or newly added files — not on the whole repository.

1) Detecting the presence of `aislop`

- Check package.json for a script named `aislop`:

  grep -q '"aislop"' package.json && echo "aislop found"

- Or check `.agents/project-context.md` if `init-project` populated it: look for `aislop` or `verification script` entries.

2) Running `aislop` (if present)

- Preferred command by runner:

  - Bun: bun run aislop
  - npm/pnpm/yarn: npm run aislop  # or pnpm run aislop / yarn run aislop

- Only run `aislop` if you have explicitly detected it (package.json scripts or project-context.md).

3) Running lint / checks only on changed/new files

Rule: consider staged files + unstaged changes + untracked files. Filter by relevant extensions (e.g. .js .ts .tsx .jsx .mjs .cjs) and pass the list to the linter or lint script.

Example portable sequence (bash):

  CHANGED_STAGED=$(git diff --name-only --staged || true)
  CHANGED_UNSTAGED=$(git diff --name-only || true)
  UNTRACKED=$(git ls-files --others --exclude-standard || true)
  FILES=$(printf "%s\n%s\n%s" "$CHANGED_STAGED" "$CHANGED_UNSTAGED" "$UNTRACKED" | sort -u | grep -E '\\.(js|ts|tsx|jsx)$' || true)
  if [ -n "$FILES" ]; then
    # Use the project's lint script via the preferred runner
    # Bun: bun run lint -- $FILES
    # npm/pnpm/yarn: npm run lint -- $FILES
    echo "$FILES" | xargs -r bun run lint --
  else
    echo "No modified or new JS/TS files to lint."
  fi

Notes:
- Replace `bun run lint` with `npm run lint` or `pnpm run lint` if the project prefers those tools.
- The `--` flag passes file paths to the npm/bun script (if your lint script is based on eslint or similar). If the script does not accept file arguments, adapt accordingly (e.g. configure a `lint:staged` script or call `eslint --fix $FILES`).

4) Targeted tests (optional)

- For Jest, you can run only tests related to changed files:

  npx jest --findRelatedTests $(git diff --name-only --staged)

- For other runners (Vitest, etc.), check if they offer an equivalent option (e.g. `--changed` or pattern-based). If not, running only affected unit tests may require running the full test suite.

5) Operational rules for agents/skills

- Only run `aislop` when it is explicitly present.
- Do not lint the whole repository by default: target only changed/new files as shown above.
- Always use the preferred runner indicated in `.agents/project-context.md` (pref: `bun` if detected).
- `.agents/scripts/run_checks_changed.sh` implements steps 1-4 above and is the
  preferred entry point when present — prefer it over reimplementing this
  logic inline.

## Scope: JS/TS only

`run_checks_changed.sh` only detects and lints JS/TS files (`.js`, `.ts`,
`.tsx`, `.jsx`, `.mjs`, `.cjs`) via npm/bun/pnpm/yarn. On a non-JS/TS project
(Rust, Python, Go, Zig), it will report "no files to check" even when the
actual changed files need linting — it is not a signal that the project is
clean. In that case, run the project's own lint/format/test commands from
`.agents/project-context.md` directly (e.g. `cargo clippy`, `ruff check`,
`go vet`) instead of relying on this script.

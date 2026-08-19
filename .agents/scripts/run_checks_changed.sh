#!/usr/bin/env bash
set -euo pipefail

# Run lint and verification (aislop) only on changed or new files.
# Uses the preferred runner when possible. Defaults to bun if detected.

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$PROJECT_ROOT"

# Detect runner preference from .agents/project-context.md if present
PREFERRED_RUNNER=""
if [ -f .agents/project-context.md ]; then
  PREFERRED_RUNNER=$(grep -i "preferred runtime/tooling" .agents/project-context.md | head -n1 | sed -E 's/.*:\s*//I' || true)
fi

# Fallback: prefer bun if bun.lock exists
if [ -z "$PREFERRED_RUNNER" ] && [ -f bun.lock ]; then
  PREFERRED_RUNNER="bun"
fi

echo "Preferred runner: ${PREFERRED_RUNNER:-<none>}"

# Gather files: staged + unstaged + untracked
CHANGED_STAGED=$(git diff --name-only --staged || true)
CHANGED_UNSTAGED=$(git diff --name-only || true)
UNTRACKED=$(git ls-files --others --exclude-standard || true)
FILES=$(printf "%s\n%s\n%s" "$CHANGED_STAGED" "$CHANGED_UNSTAGED" "$UNTRACKED" | sort -u | grep -E '\.(js|ts|tsx|jsx|mjs|cjs)$' || true)

if [ -z "$FILES" ]; then
  echo "No JS/TS changed or new files to check."
  exit 0
fi

echo "Files to check:"
echo "$FILES"

# Run lint on the files via the preferred runner
case "$PREFERRED_RUNNER" in
  bun)
    echo "$FILES" | xargs -r bun run lint --
    ;;
  npm)
    echo "$FILES" | xargs -r npm run lint --
    ;;
  pnpm)
    echo "$FILES" | xargs -r pnpm run lint --
    ;;
  yarn)
    echo "$FILES" | xargs -r yarn run lint --
    ;;
  *)
    # Default to bun if available, else npm
    if command -v bun >/dev/null 2>&1; then
      echo "$FILES" | xargs -r bun run lint --
    else
      echo "$FILES" | xargs -r npm run lint --
    fi
    ;;
esac

# If aislop is present in package.json, run it
if [ -f package.json ] && grep -q '"aislop"' package.json; then
  echo "aislop script found — running verification"
  case "$PREFERRED_RUNNER" in
    bun)
      bun run aislop
      ;;
    pnpm)
      pnpm run aislop
      ;;
    yarn)
      yarn run aislop
      ;;
    *)
      npm run aislop
      ;;
  esac
else
  echo "No aislop script detected."
fi

echo "Checks completed."

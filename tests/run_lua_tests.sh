#!/usr/bin/env bash
# tests/run_lua_tests.sh — plenary.nvim test runner for Lua specs
#
# Usage:
#   ./tests/run_lua_tests.sh                  # run all *_spec.lua under tests/lua/
#   ./tests/run_lua_tests.sh --file <path>    # run a single spec file
#
# Requires:
#   - nvim in PATH
#   - plenary.nvim installed (see tests/README.md for setup)
#
# Exit codes:
#   0 — all tests passed
#   1 — one or more tests failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ── Argument parsing ──────────────────────────────────────────────────────────

SINGLE_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) SINGLE_FILE="$2"; shift 2 ;;
    --help|-h)
      sed -n '2,10p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# ── Detect nvim ───────────────────────────────────────────────────────────────

if ! command -v nvim &>/dev/null; then
  echo "ERROR: nvim not found in PATH." >&2
  exit 1
fi

# ── Ensure mocks are on PATH ──────────────────────────────────────────────────

export PATH="${SCRIPT_DIR}/mocks:${PATH}"

# ── Run tests ─────────────────────────────────────────────────────────────────

cd "${REPO_ROOT}"

if [[ -n "${SINGLE_FILE}" ]]; then
  echo "Running single Lua spec: ${SINGLE_FILE}"
  nvim --headless \
    -u "${SCRIPT_DIR}/init.lua" \
    -c "lua require('plenary.busted').run('${SINGLE_FILE}')" \
    -c "qa!"
  exit $?
fi

# Check that there are spec files to run
SPEC_COUNT=$(find "${SCRIPT_DIR}/lua" -name '*_spec.lua' 2>/dev/null | wc -l)
if [[ "${SPEC_COUNT}" -eq 0 ]]; then
  echo "No *_spec.lua files found under tests/lua/ — nothing to run."
  exit 0
fi

echo "Running ${SPEC_COUNT} Lua spec file(s) under tests/lua/ ..."

EXIT_CODE=0
nvim --headless \
  -u "${SCRIPT_DIR}/init.lua" \
  -c "PlenaryBustedDirectory tests/lua/ { minimal_init = 'tests/init.lua' }" \
  -c "qa!" \
  || EXIT_CODE=$?

if [[ "${EXIT_CODE}" -eq 0 ]]; then
  echo "✓ All Lua tests passed."
else
  echo "✗ Lua tests failed (exit ${EXIT_CODE})."
fi

exit "${EXIT_CODE}"

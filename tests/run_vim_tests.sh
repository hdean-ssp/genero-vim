#!/usr/bin/env bash
# tests/run_vim_tests.sh — vader.vim test runner for VimScript tests
#
# Usage:
#   ./tests/run_vim_tests.sh                  # run all .vader files under tests/vader/
#   ./tests/run_vim_tests.sh --file <path>    # run a single .vader file
#
# Requires:
#   - nvim in PATH (Neovim only — plain Vim is not supported)
#   - vader.vim installed (see tests/README.md for setup)
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
  echo "ERROR: nvim not found in PATH. Neovim is required for VimScript tests." >&2
  exit 1
fi

# ── Ensure mocks are on PATH ──────────────────────────────────────────────────

export PATH="${SCRIPT_DIR}/mocks:${PATH}"

# ── Run tests ─────────────────────────────────────────────────────────────────

cd "${REPO_ROOT}"

if [[ -n "${SINGLE_FILE}" ]]; then
  echo "Running single vader file: ${SINGLE_FILE}"
  EXIT_CODE=0
  nvim --headless \
    -u "${SCRIPT_DIR}/vimrc" \
    -c "Vader! ${SINGLE_FILE}" \
    || EXIT_CODE=$?
  if [[ "${EXIT_CODE}" -eq 0 ]]; then
    echo "✓ Vader test passed: ${SINGLE_FILE}"
  else
    echo "✗ Vader test failed: ${SINGLE_FILE} (exit ${EXIT_CODE})"
  fi
  exit "${EXIT_CODE}"
fi

# Collect all .vader files
VADER_FILES=()
while IFS= read -r -d '' f; do
  VADER_FILES+=("$f")
done < <(find "${SCRIPT_DIR}/vader" -name '*.vader' -print0 2>/dev/null | sort -z)

if [[ "${#VADER_FILES[@]}" -eq 0 ]]; then
  echo "No .vader files found under tests/vader/ — nothing to run."
  exit 0
fi

echo "Running ${#VADER_FILES[@]} vader file(s) under tests/vader/ ..."

# Build a glob pattern for Vader! — pass all files as a comma-separated list
# vader.vim accepts a glob; we run each file individually to get per-file exit codes
OVERALL_EXIT=0
PASSED=0
FAILED=0

for vader_file in "${VADER_FILES[@]}"; do
  rel_path="${vader_file#${REPO_ROOT}/}"
  EXIT_CODE=0
  nvim --headless \
    -u "${SCRIPT_DIR}/vimrc" \
    -c "Vader! ${rel_path}" \
    2>&1 \
    || EXIT_CODE=$?

  if [[ "${EXIT_CODE}" -eq 0 ]]; then
    echo "  ✓ ${rel_path}"
    PASSED=$(( PASSED + 1 ))
  else
    echo "  ✗ ${rel_path} (exit ${EXIT_CODE})"
    FAILED=$(( FAILED + 1 ))
    OVERALL_EXIT=1
  fi
done

echo ""
echo "VimScript tests: ${PASSED} passed, ${FAILED} failed."

if [[ "${OVERALL_EXIT}" -eq 0 ]]; then
  echo "✓ All VimScript tests passed."
else
  echo "✗ VimScript tests failed."
fi

exit "${OVERALL_EXIT}"

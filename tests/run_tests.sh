#!/usr/bin/env bash
# tests/run_tests.sh — top-level test runner for genero-tools plugin
#
# Usage:
#   ./tests/run_tests.sh                  # run all tests (Lua + VimScript)
#   ./tests/run_tests.sh --lua-only       # run only Lua/plenary tests
#   ./tests/run_tests.sh --vim-only       # run only VimScript/vader tests
#   ./tests/run_tests.sh --file <path>    # run a single test file
#
# Exit codes:
#   0 — all tests passed
#   1 — one or more tests failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ── Argument parsing ──────────────────────────────────────────────────────────

RUN_LUA=1
RUN_VIM=1
SINGLE_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lua-only)  RUN_VIM=0; shift ;;
    --vim-only)  RUN_LUA=0; shift ;;
    --file)      SINGLE_FILE="$2"; shift 2 ;;
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

# ── Detect nvim binary ────────────────────────────────────────────────────────

if command -v nvim &>/dev/null; then
  NVIM_BIN="nvim"
else
  echo "ERROR: nvim not found in PATH. Neovim is required to run the test suite." >&2
  exit 1
fi

NVIM_VERSION="$("${NVIM_BIN}" --version | head -1)"
echo "Using: ${NVIM_BIN} (${NVIM_VERSION})"

# ── Prepend mocks/ to PATH so mock executables shadow real ones ───────────────

export PATH="${SCRIPT_DIR}/mocks:${PATH}"

# ── Ensure results directory exists ──────────────────────────────────────────

mkdir -p "${SCRIPT_DIR}/results"

# ── Run test suites ───────────────────────────────────────────────────────────

LUA_EXIT=0
VIM_EXIT=0

if [[ -n "${SINGLE_FILE}" ]]; then
  # Route single file to the appropriate runner based on extension
  case "${SINGLE_FILE}" in
    *.lua)
      "${SCRIPT_DIR}/run_lua_tests.sh" --file "${SINGLE_FILE}"
      exit $?
      ;;
    *.vader)
      "${SCRIPT_DIR}/run_vim_tests.sh" --file "${SINGLE_FILE}"
      exit $?
      ;;
    *)
      echo "ERROR: Cannot determine test runner for file: ${SINGLE_FILE}" >&2
      echo "  .lua files → run_lua_tests.sh" >&2
      echo "  .vader files → run_vim_tests.sh" >&2
      exit 1
      ;;
  esac
fi

if [[ "${RUN_LUA}" -eq 1 ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Lua / plenary.nvim tests"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  "${SCRIPT_DIR}/run_lua_tests.sh" || LUA_EXIT=$?
fi

if [[ "${RUN_VIM}" -eq 1 ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  VimScript / vader.vim tests"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  "${SCRIPT_DIR}/run_vim_tests.sh" || VIM_EXIT=$?
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Suite Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "${RUN_LUA}" -eq 1 ]]; then
  if [[ "${LUA_EXIT}" -eq 0 ]]; then
    echo "  ✓ Lua tests:       PASSED"
  else
    echo "  ✗ Lua tests:       FAILED (exit ${LUA_EXIT})"
  fi
fi

if [[ "${RUN_VIM}" -eq 1 ]]; then
  if [[ "${VIM_EXIT}" -eq 0 ]]; then
    echo "  ✓ VimScript tests: PASSED"
  else
    echo "  ✗ VimScript tests: FAILED (exit ${VIM_EXIT})"
  fi
fi

OVERALL_EXIT=$(( LUA_EXIT | VIM_EXIT ))

echo ""
if [[ "${OVERALL_EXIT}" -eq 0 ]]; then
  echo "  ✓ All tests passed."
else
  echo "  ✗ One or more test suites failed."
fi
echo ""

exit "${OVERALL_EXIT}"

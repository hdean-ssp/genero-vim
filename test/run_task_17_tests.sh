#!/bin/bash
# Task 17 Integration Test Runner

cd "$(dirname "$0")/.."

# Run integration tests
vim -u NONE -N -i NONE \
  -c "set runtimepath+=." \
  -c "source test/test_task_17_integration.vim" \
  -c "call Test_task_17_integration_all()" \
  -c "qa!" 2>&1

exit $?

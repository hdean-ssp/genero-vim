#!/usr/bin/env bash
# Mock query script for testing.
# Prints $MOCK_QUERY_OUTPUT (default: []) and exits with $MOCK_QUERY_EXIT (default: 0).
echo "${MOCK_QUERY_OUTPUT:-[]}"
exit "${MOCK_QUERY_EXIT:-0}"

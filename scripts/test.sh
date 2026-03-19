#!/bin/bash
# Test runner script for Vim Genero-Tools Plugin
# Runs all unit, integration, and property-based tests

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$PROJECT_ROOT/tests"
RESULTS_FILE="/tmp/genero_tools_test_results.txt"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Functions
print_header() {
  echo -e "${YELLOW}=== $1 ===${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ $1${NC}"
}

run_test_file() {
  local test_file=$1
  local test_name=$(basename "$test_file" .vim)
  
  print_info "Running: $test_name"
  
  # Run test with vim in non-interactive mode
  vim -N -u NONE -S "$test_file" -c "qa!" > "$RESULTS_FILE" 2>&1 || true
  
  # Check if test passed (vim exits with 0 on success)
  if [ $? -eq 0 ]; then
    print_success "$test_name"
    ((PASSED_TESTS++))
  else
    print_error "$test_name"
    cat "$RESULTS_FILE"
    ((FAILED_TESTS++))
  fi
  
  ((TOTAL_TESTS++))
}

run_all_tests() {
  print_header "Unit Tests"
  
  if [ -d "$TEST_DIR/unit" ]; then
    for test_file in "$TEST_DIR/unit"/test_*.vim; do
      if [ -f "$test_file" ]; then
        run_test_file "$test_file"
      fi
    done
  fi
  
  print_header "Integration Tests"
  
  if [ -d "$TEST_DIR/integration" ]; then
    for test_file in "$TEST_DIR/integration"/test_*.vim; do
      if [ -f "$test_file" ]; then
        run_test_file "$test_file"
      fi
    done
  fi
  
  print_header "Property-Based Tests"
  
  if [ -d "$TEST_DIR/properties" ]; then
    for test_file in "$TEST_DIR/properties"/test_*.vim; do
      if [ -f "$test_file" ]; then
        run_test_file "$test_file"
      fi
    done
  fi
}

print_summary() {
  echo ""
  print_header "Test Summary"
  echo "Total Tests:  $TOTAL_TESTS"
  echo "Passed:       $PASSED_TESTS"
  echo "Failed:       $FAILED_TESTS"
  
  if [ $FAILED_TESTS -eq 0 ]; then
    print_success "All tests passed!"
    return 0
  else
    print_error "$FAILED_TESTS test(s) failed"
    return 1
  fi
}

# Main execution
main() {
  print_header "Vim Genero-Tools Plugin Test Suite"
  print_info "Project root: $PROJECT_ROOT"
  print_info "Test directory: $TEST_DIR"
  echo ""
  
  if [ ! -d "$TEST_DIR" ]; then
    print_error "Test directory not found: $TEST_DIR"
    exit 1
  fi
  
  run_all_tests
  print_summary
  
  # Clean up
  rm -f "$RESULTS_FILE"
  
  exit $?
}

# Run main function
main "$@"

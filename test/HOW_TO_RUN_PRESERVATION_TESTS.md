# How to Run Preservation Property Tests

## Quick Start

### Run Full Test Suite
```bash
vim -u NONE -N -es -c "source test/test_preservation_properties.vim"
```

### Run Simplified Tests
```bash
vim -u NONE -N -es -c "source test/test_preservation_simple.vim"
```

### Using Test Runner Script
```bash
bash test/run_preservation_tests.sh
```

## Detailed Instructions

### Prerequisites

- Vim or Neovim installed
- Access to the workspace directory
- The test files in `test/` directory

### Step 1: Navigate to Workspace

```bash
cd /path/to/workspace
```

### Step 2: Run Tests

#### Option A: Full Test Suite (Recommended)

```bash
vim -u NONE -N -es -c "source test/test_preservation_properties.vim"
```

**What this does**:
- Runs the comprehensive test suite with detailed mocking
- Tracks all function calls
- Provides detailed output for each test
- Writes results to `/tmp/preservation_test_results.txt`

**Expected output**:
```
=== Preservation Property Tests ===
Property 2: Preservation - Non-Autocompile Behavior Unchanged
Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5

PASS: Test 1 - Manual GeneroCompile applies error/warning highlighting
  highlight#apply() was called with 1 error(s) and 1 warning(s)

PASS: Test 2 - Autocompile disabled prevents compilation
  compile_silent() was NOT called (correct behavior)

PASS: Test 3 - compiler_highlight_unused disabled skips unused variable highlighting
  highlight#unused_vars() was NOT called (correct behavior)

PASS: Test 4 - compiler_sign_column disabled skips sign placement
  signs#update() was NOT called (correct behavior)

PASS: Test 5 - compiler_autocompile disabled prevents compilation
  on_buffer_enter() returns early (correct behavior)

PASS: Test 6 - Quickfix population is preserved
  quickfix#populate() was called with 2 items

PASS: Test 7 - Quickfix cleared when no errors
  quickfix#clear() was called (correct behavior)

=== Summary ===
All tests PASSED - Baseline behavior preserved
```

#### Option B: Simplified Tests (Quick Validation)

```bash
vim -u NONE -N -es -c "source test/test_preservation_simple.vim"
```

**What this does**:
- Runs lightweight tests for quick validation
- Simpler test logic, easier to understand
- Provides quick pass/fail results
- Useful for quick validation during development

**Expected output**:
```
=== Preservation Property Tests ===
Property 2: Preservation - Non-Autocompile Behavior Unchanged
Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5

PASS: Test 1 - Manual GeneroCompile applies error/warning highlighting
PASS: Test 2 - Config controls highlighting independently
PASS: Test 3 - Sign placement is independent from highlighting
PASS: Test 4 - Autocompile config controls compilation
PASS: Test 5 - Quickfix population is preserved

=== Summary ===
Tests Passed: 5
Tests Failed: 0
All tests PASSED - Baseline behavior preserved
```

#### Option C: Using Test Runner Script

```bash
bash test/run_preservation_tests.sh
```

**What this does**:
- Runs the full test suite using the shell script
- Captures output to console
- Returns appropriate exit codes (0 for success, 1 for failure)

### Step 3: Check Results

#### Check Console Output

The test results are printed to the console. Look for:
- `PASS` - Test passed ✅
- `FAIL` - Test failed ❌
- `Summary` - Overall results

#### Check Results File

The full test suite also writes results to a file:

```bash
cat /tmp/preservation_test_results.txt
```

### Step 4: Interpret Results

#### All Tests Passed ✅

```
=== Summary ===
All tests PASSED - Baseline behavior preserved
```

**Meaning**: The baseline behavior is established. The fix should not break these behaviors.

#### Some Tests Failed ❌

```
=== Summary ===
Some tests FAILED - Baseline behavior may be affected
```

**Meaning**: There may be an issue with the test setup or the code. Investigate the failed tests.

## Understanding Test Output

### Test Output Format

Each test produces output in this format:

```
PASS: Test N - Test Description
  Additional details about what was verified
```

or

```
FAIL: Test N - Test Description
  Expected: What should have happened
  Actual: What actually happened
  Counterexample: Example that demonstrates the failure
```

### Mock Call Tracking

The tests track which functions are called:

```
highlight#apply() was called with 1 error(s) and 1 warning(s)
```

This means:
- The function was called
- It was called with 1 error and 1 warning
- This is the expected behavior

### Counterexamples

If a test fails, it provides a counterexample:

```
Counterexample: Autocompile on BufEnter with compilation error
Root Cause: Missing call to genero_tools#compiler#highlight#apply() in compile_silent()
```

This helps understand what went wrong and why.

## Troubleshooting

### Test Hangs or Times Out

**Problem**: The test command doesn't complete or times out.

**Solution**:
1. Press `Ctrl+C` to interrupt
2. Try the simplified tests instead: `vim -u NONE -N -es -c "source test/test_preservation_simple.vim"`
3. Check if Vim is installed: `which vim`

### Test Results File Not Created

**Problem**: The results file `/tmp/preservation_test_results.txt` is not created.

**Solution**:
1. Check if `/tmp` directory exists: `ls -la /tmp`
2. Check if you have write permissions: `touch /tmp/test.txt`
3. Try running the test again

### Tests Fail Unexpectedly

**Problem**: Tests fail when they should pass.

**Solution**:
1. Check the test output for details
2. Review the mock call tracking to see which functions were called
3. Check if the code has been modified
4. Try running the simplified tests for clearer output

## Running Tests at Different Stages

### Before Implementation (Phase 2)

**Expected**: All tests PASS ✅

This establishes the baseline behavior.

```bash
vim -u NONE -N -es -c "source test/test_preservation_properties.vim"
```

### After Implementation (Phase 3)

**Expected**: All tests PASS ✅

This confirms no regressions are introduced.

```bash
vim -u NONE -N -es -c "source test/test_preservation_properties.vim"
```

### Continuous Testing

Run tests after any changes to verify nothing breaks:

```bash
vim -u NONE -N -es -c "source test/test_preservation_simple.vim"
```

## Integration with Bug Condition Tests

Run both test suites together:

```bash
# Run bug condition tests
vim -u NONE -N -es -c "source test/test_autocompile_highlight_bug_exploration.vim"

# Run preservation tests
vim -u NONE -N -es -c "source test/test_preservation_properties.vim"
```

**Expected Results**:
- Bug condition tests: FAIL on unfixed code, PASS on fixed code
- Preservation tests: PASS on both unfixed and fixed code

## Advanced Usage

### Running Specific Tests

To run only specific tests, modify the test file:

1. Open `test/test_preservation_properties.vim`
2. Comment out the tests you don't want to run
3. Save and run the file

### Debugging Tests

To debug a specific test:

1. Add `echom` statements to the test function
2. Run the test file
3. Check the console output for debug messages

### Modifying Tests

To modify tests for your specific needs:

1. Open the test file
2. Modify the test function
3. Save and run the file
4. Check the results

## Summary

The preservation property tests can be run using:

```bash
# Full test suite (recommended)
vim -u NONE -N -es -c "source test/test_preservation_properties.vim"

# Simplified tests (quick validation)
vim -u NONE -N -es -c "source test/test_preservation_simple.vim"

# Using test runner script
bash test/run_preservation_tests.sh
```

All tests should PASS on both unfixed and fixed code, confirming that:
- The baseline behavior is established
- The fix doesn't introduce regressions
- The fix is minimal and focused

For more information, see:
- `test/PRESERVATION_TESTS_REPORT.md` - Detailed test documentation
- `test/PRESERVATION_TESTS_SUMMARY.md` - Quick reference guide
- `test/TASK_2_COMPLETION_REPORT.md` - Task completion report

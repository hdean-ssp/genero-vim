# Implementation Plan

## Phase 1: Exploration - Understand the Bug

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Autocompile Missing Error/Warning Highlighting
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: For deterministic bugs, scope the property to the concrete failing case(s) to ensure reproducibility
  - Test that when autocompile runs on a file with compilation errors/warnings, the `highlight#apply()` function is called with those errors and warnings
  - Simulate BufEnter and BufWritePost events that trigger autocompile
  - Mock the highlight functions to track which ones are called
  - Assert that `highlight#apply()` is called when errors or warnings exist (from Bug Condition in design)
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found to understand root cause (e.g., "highlight#apply() never called during autocompile events")
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2_

## Phase 2: Preservation - Verify Existing Behavior

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Autocompile Behavior Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-autocompile scenarios
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements
  - Test cases to cover:
    - Manual `:GeneroCompile` command continues to apply both error/warning and unused variable highlighting
    - When autocompile is disabled, no highlighting is applied on buffer enter or save
    - When `compiler_highlight_unused` config is disabled, unused variable highlighting is skipped but error/warning highlighting is still applied
    - When `compiler_sign_column` config is disabled, sign placement is skipped but highlighting still works
    - When `compiler_autocompile` config is disabled, no compilation occurs on buffer enter or save
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

## Phase 3: Implementation - Apply the Fix

- [x] 3. Fix autocompile highlighting consistency

  - [x] 3.1 Implement the fix
    - Add missing `genero_tools#compiler#highlight#apply()` call to `compile_silent()` function in `autoload/genero_tools/compiler/autocompile.vim`
    - Location: After the `highlight#unused_vars()` call (around line 108)
    - Pass `result.errors` and `result.warnings` to `highlight#apply()`
    - The call should be made when errors or warnings exist, similar to how it's done in the manual `:GeneroCompile` command (commands.vim line 56)
    - Maintain all existing logic for signs, quickfix, and error handling
    - _Bug_Condition: isBugCondition(event) where event is BufEnter or BufWritePost and compilation succeeds with errors/warnings_
    - _Expected_Behavior: highlight#apply() is called with result.errors and result.warnings_
    - _Preservation: Manual GeneroCompile, disabled autocompile, and config-controlled highlighting remain unchanged_
    - _Requirements: 2.1, 2.2_

  - [x] 3.2 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Autocompile Applies Error/Warning Highlighting
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - _Requirements: 2.1, 2.2_

  - [x] 3.3 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Autocompile Behavior Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm all tests still pass after fix (no regressions)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

## Phase 4: Validation

- [x] 4. Checkpoint - Ensure all tests pass
  - Verify that all exploration tests pass (bug is fixed)
  - Verify that all preservation tests pass (no regressions)
  - Ensure the fix is minimal and focused on the root cause
  - Confirm that error/warning highlighting is now applied during autocompile events
  - Ask the user if questions arise

# Autocompile Highlighting Consistency Bugfix Design

## Overview

The autocompile feature (triggered on buffer enter and file save) currently applies only unused variable highlighting but is missing error and warning highlighting. The `:GeneroCompile` command correctly applies both types of highlighting. This inconsistency means users don't see error/warning highlights during autocompile, only when manually running `:GeneroCompile`. The fix ensures autocompile applies the exact same highlighting as the manual command by adding a single missing function call to `genero_tools#compiler#highlight#apply()` in the `compile_silent()` function.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug - when autocompile runs (on buffer enter or file save) and compilation succeeds
- **Property (P)**: The desired behavior when autocompile runs - both error/warning highlighting and unused variable highlighting should be applied
- **Preservation**: Existing behavior for manual `:GeneroCompile` command, disabled autocompile, and config-controlled highlighting that must remain unchanged
- **compile_silent()**: The function in `autoload/genero_tools/compiler/autocompile.vim` that performs silent compilation during autocompile events
- **highlight#apply()**: The function in `autoload/genero_tools/compiler/highlight.vim` that applies error and warning highlighting to the buffer
- **highlight#unused_vars()**: The function in `autoload/genero_tools/compiler/highlight.vim` that applies unused variable highlighting to the buffer
- **genero_tools#compiler#execute()**: The function that runs the compiler and returns errors, warnings, and info messages

## Bug Details

### Bug Condition

The bug manifests when a file is compiled via autocompile (on buffer enter or file save) and the compilation succeeds. The `compile_silent()` function calls `genero_tools#compiler#highlight#unused_vars()` to apply unused variable highlighting but fails to call `genero_tools#compiler#highlight#apply()` to apply error and warning highlighting.

**Formal Specification:**
```
FUNCTION isBugCondition(event)
  INPUT: event of type AutocompileEvent (BufEnter or BufWritePost)
  OUTPUT: boolean
  
  RETURN event.type IN ['BufEnter', 'BufWritePost']
         AND compiler_enabled = true
         AND compiler_autocompile = true
         AND compilation_succeeded = true
         AND (len(errors) > 0 OR len(warnings) > 0)
         AND highlight#apply NOT called
END FUNCTION
```

### Examples

- **Example 1 - Buffer Enter with Errors**: User opens a file with compilation errors. Autocompile runs on BufEnter, compilation succeeds, unused variable highlighting is applied, but error highlighting is missing. User sees no red underlines for errors.

- **Example 2 - File Save with Warnings**: User saves a file with compilation warnings. Autocompile runs on BufWritePost, compilation succeeds, unused variable highlighting is applied, but warning highlighting is missing. User sees no yellow underlines for warnings.

- **Example 3 - Mixed Errors and Warnings**: User has a file with both errors and warnings. Autocompile applies unused variable highlighting but not error/warning highlighting. Only unused variables are highlighted, errors and warnings are invisible.

- **Edge Case - No Errors or Warnings**: User has a file with only unused variables. Autocompile correctly applies unused variable highlighting. This case works correctly and should remain unchanged.

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- The `:GeneroCompile` command must continue to apply both error/warning highlighting and unused variable highlighting
- When autocompile is disabled via config, no highlighting should be applied on buffer enter or save
- When `compiler_highlight_unused` config is disabled, unused variable highlighting should be skipped during autocompile
- When `compiler_sign_column` config is disabled, sign placement should be skipped during autocompile
- When `compiler_autocompile` config is disabled, no compilation should occur on buffer enter or save
- Quickfix population must continue to work as before
- Sign placement must continue to work as before

**Scope:**
All inputs that do NOT involve autocompile events (BufEnter or BufWritePost) should be completely unaffected by this fix. This includes:
- Manual `:GeneroCompile` command execution
- Manual `:GeneroClearErrors` command execution
- Manual `:GeneroNextError` and `:GeneroPrevError` navigation
- All other Vim commands and user interactions

## Hypothesized Root Cause

Based on the bug description and code analysis, the root cause is:

1. **Missing Function Call**: The `compile_silent()` function in `autoload/genero_tools/compiler/autocompile.vim` calls `genero_tools#compiler#highlight#unused_vars()` but does not call `genero_tools#compiler#highlight#apply()`. The `:GeneroCompile` command in `autoload/genero_tools/compiler/commands.vim` correctly calls both functions.

2. **Incomplete Implementation**: The autocompile feature was implemented with only partial highlighting support, missing the error/warning highlighting that the manual compile command provides.

3. **Code Duplication Opportunity**: The `compile_silent()` function should mirror the highlighting logic from the `:GeneroCompile` command implementation.

## Correctness Properties

Property 1: Bug Condition - Autocompile Applies Error/Warning Highlighting

_For any_ autocompile event (BufEnter or BufWritePost) where compilation succeeds and errors or warnings are present, the fixed `compile_silent()` function SHALL call `genero_tools#compiler#highlight#apply()` with the errors and warnings from the compilation result, causing error and warning highlighting to be applied to the buffer.

**Validates: Requirements 2.1, 2.2**

Property 2: Preservation - Non-Autocompile Behavior Unchanged

_For any_ compilation event that is NOT an autocompile event (e.g., manual `:GeneroCompile` command), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing highlighting functionality for manual compilation.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File**: `autoload/genero_tools/compiler/autocompile.vim`

**Function**: `genero_tools#compiler#autocompile#compile_silent()`

**Specific Changes**:

1. **Add Missing highlight#apply Call**: After the `highlight#unused_vars()` call, add a call to `genero_tools#compiler#highlight#apply()` passing the errors and warnings from the compilation result.

   - Location: In the `compile_silent()` function, after line 108 where `highlight#unused_vars()` is called
   - Parameters: Pass `result.errors` and `result.warnings` to `highlight#apply()`
   - Condition: Call should be made regardless of the `compiler_highlight_unused` config, as error/warning highlighting is separate from unused variable highlighting

2. **Maintain Existing Logic**: Keep all existing calls to `signs#update()`, `highlight#unused_vars()`, and `quickfix#populate()` unchanged.

3. **Preserve Error Handling**: Keep the try-catch block that silently ignores compilation errors during autocompile.

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write tests that simulate autocompile events (BufEnter and BufWritePost) with files containing compilation errors and warnings. Mock the highlight functions to track which ones are called. Run these tests on the UNFIXED code to observe that `highlight#apply()` is never called while `highlight#unused_vars()` is called.

**Test Cases**:
1. **Autocompile on BufEnter with Errors**: Simulate BufEnter event on a file with compilation errors. Verify that `highlight#unused_vars()` is called but `highlight#apply()` is NOT called (will fail on unfixed code).
2. **Autocompile on BufWritePost with Warnings**: Simulate BufWritePost event on a file with compilation warnings. Verify that `highlight#unused_vars()` is called but `highlight#apply()` is NOT called (will fail on unfixed code).
3. **Autocompile with Mixed Errors and Warnings**: Simulate autocompile on a file with both errors and warnings. Verify that `highlight#apply()` is not called (will fail on unfixed code).
4. **Autocompile with No Errors or Warnings**: Simulate autocompile on a file with only unused variables. Verify that `highlight#unused_vars()` is called (should pass on unfixed code).

**Expected Counterexamples**:
- `highlight#apply()` is never called during autocompile events on unfixed code
- Error and warning highlighting is not applied to the buffer during autocompile
- Possible causes: missing function call, incomplete implementation

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL event WHERE isBugCondition(event) DO
  result := compile_silent_fixed(event.file)
  ASSERT highlight#apply called with result.errors and result.warnings
  ASSERT error_and_warning_highlighting_applied_to_buffer
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL event WHERE NOT isBugCondition(event) DO
  ASSERT compile_silent_original(event.file) = compile_silent_fixed(event.file)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs

**Test Plan**: Observe behavior on UNFIXED code first for manual `:GeneroCompile` command, disabled autocompile, and config-controlled highlighting. Then write property-based tests capturing that behavior to verify it remains unchanged after the fix.

**Test Cases**:
1. **Manual GeneroCompile Preservation**: Verify that `:GeneroCompile` command continues to apply both error/warning and unused variable highlighting after the fix.
2. **Disabled Autocompile Preservation**: Verify that when autocompile is disabled, no highlighting is applied on buffer enter or save after the fix.
3. **Config-Controlled Highlighting Preservation**: Verify that when `compiler_highlight_unused` is disabled, unused variable highlighting is skipped but error/warning highlighting is still applied (if errors/warnings exist).
4. **Sign Placement Preservation**: Verify that sign placement continues to work correctly when `compiler_sign_column` is enabled.
5. **Quickfix Population Preservation**: Verify that quickfix list is populated correctly with errors and warnings.

### Unit Tests

- Test that `compile_silent()` calls `highlight#apply()` with correct parameters when errors/warnings exist
- Test that `compile_silent()` calls `highlight#unused_vars()` when `compiler_highlight_unused` is enabled
- Test that `compile_silent()` calls `signs#update()` when `compiler_sign_column` is enabled
- Test that `compile_silent()` populates quickfix when errors/warnings exist
- Test that `compile_silent()` clears quickfix when no errors/warnings exist
- Test that error handling silently ignores compilation errors

### Property-Based Tests

- Generate random files with various combinations of errors, warnings, and unused variables. Verify that `highlight#apply()` is called when errors/warnings exist.
- Generate random config states (autocompile enabled/disabled, highlighting enabled/disabled) and verify correct highlighting behavior.
- Generate random autocompile events and verify that the same highlighting is applied as the manual `:GeneroCompile` command.

### Integration Tests

- Tes
t full autocompile workflow with a file containing errors and warnings. Verify that error/warning highlighting is applied on buffer enter and file save.
- Test switching between files with different error/warning states. Verify that highlighting is correctly updated for each file.
- Test that the visual feedback (highlighting) appears immediately after autocompile runs.

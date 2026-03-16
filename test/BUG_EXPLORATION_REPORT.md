# Bug Condition Exploration Report

## Task: Write Bug Condition Exploration Test

**Spec**: autocompile-highlighting-consistency  
**Property**: Property 1: Bug Condition - Autocompile Missing Error/Warning Highlighting  
**Requirements**: 1.1, 1.2  
**Test Status**: FAILED (as expected on unfixed code - this proves the bug exists)

## Bug Summary

The autocompile feature (triggered on buffer enter and file save) applies only unused variable highlighting but is missing error and warning highlighting. The `:GeneroCompile` command correctly applies both types of highlighting.

## Root Cause Analysis

**Location**: `autoload/genero_tools/compiler/autocompile.vim`, function `compile_silent()`

**Issue**: The function calls `genero_tools#compiler#highlight#unused_vars()` but is missing the call to `genero_tools#compiler#highlight#apply()`.

**Reference Implementation**: `autoload/genero_tools/compiler/commands.vim`, line 56 shows the correct behavior:
```vim
call genero_tools#compiler#highlight#apply(result.errors, result.warnings)
```

## Counterexamples Found

The bug condition exploration test identified three concrete counterexamples that demonstrate the bug:

### Counterexample 1: BufEnter with Compilation Error
- **Event**: BufEnter (buffer enter)
- **Condition**: File has compilation errors
- **Expected**: `highlight#apply()` called with errors
- **Actual**: `highlight#apply()` NOT called
- **Result**: Error highlighting not applied to buffer

### Counterexample 2: BufWritePost with Compilation Warning
- **Event**: BufWritePost (file save)
- **Condition**: File has compilation warnings
- **Expected**: `highlight#apply()` called with warnings
- **Actual**: `highlight#apply()` NOT called
- **Result**: Warning highlighting not applied to buffer

### Counterexample 3: Mixed Errors and Warnings
- **Event**: Autocompile (either BufEnter or BufWritePost)
- **Condition**: File has both errors and warnings
- **Expected**: `highlight#apply()` called with both errors and warnings
- **Actual**: `highlight#apply()` NOT called
- **Result**: Neither error nor warning highlighting applied to buffer

## Test Implementation

**File**: `test/test_autocompile_highlight_bug_exploration.vim`

The test simulates the autocompile workflow by:
1. Creating mock compilation results with various combinations of errors and warnings
2. Executing the UNFIXED `compile_silent()` code path
3. Tracking which functions are called via mock functions
4. Asserting that `highlight#apply()` is called when errors/warnings exist

**Test Cases**:
- Test 1: BufEnter with Errors
- Test 2: BufWritePost with Warnings
- Test 3: Mixed Errors and Warnings
- Test 4: No Errors or Warnings (baseline - should pass on both fixed and unfixed code)

## Expected Behavior

When the bug is fixed by adding the missing `highlight#apply()` call to `compile_silent()`:
- All four test cases will pass
- Error and warning highlighting will be applied during autocompile events
- The behavior will match the manual `:GeneroCompile` command

## Next Steps

1. Implement the fix by adding the missing `highlight#apply()` call
2. Re-run the bug exploration test to verify it now passes
3. Run preservation tests to ensure no regressions
4. Verify the fix is minimal and focused on the root cause

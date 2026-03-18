# Unused Variable Highlighting Bug Fix

## Problem
When the compiler detected unused variables in a file, the highlighting system was highlighting **all occurrences** of the variable name throughout the entire document, rather than only highlighting the specific location where the compiler detected the unused variable.

This caused issues when the same variable name appeared in multiple functions - all instances would be highlighted, not just the one marked as unused by the compiler.

## Root Cause
The `genero_tools#compiler#highlight#unused_vars()` function in `autoload/genero_tools/compiler/highlight.vim` was:
1. Extracting the variable name from the warning message
2. Using `matchadd()` with a regex pattern (`\<varname\>`) that matched all occurrences globally
3. Ignoring the specific `line` and `col` information provided by the compiler

## Solution
Changed the `unused_vars()` function to use location-based highlighting instead of pattern-based highlighting:

### Before (Buggy)
```vim
" Extract variable name from message and highlight ALL occurrences
let var_match = matchstr(warning.message, "symbol '\\zs[^']*\\ze'")
if !empty(var_match)
  let pattern = '\<' . var_match . '\>'
  call matchadd(s:unused_var_group, pattern, 11)  " Highlights everywhere!
endif
```

### After (Fixed)
```vim
" Use specific line/column info from compiler output
for warning in unused_warnings
  if has_key(warning, 'line')
    if has('nvim')
      " Neovim: highlight text range (0-indexed)
      let col_start = get(warning, 'col', 1) - 1
      let col_end = get(warning, 'end_col', col_start + 1)
      call nvim_buf_add_highlight(bufnr, s:highlight_namespace, s:unused_var_group, warning.line - 1, col_start, col_end)
    else
      " Vim: use matchaddpos for column range highlighting
      let col_start = get(warning, 'col', 1)
      let col_end = get(warning, 'end_col', col_start + 1)
      let col_count = col_end - col_start
      call matchaddpos(s:unused_var_group, [[warning.line, col_start, col_count]], 11)
    endif
  endif
endfor
```

## Key Changes
1. **Location-based highlighting**: Now uses the exact `line` and `col` information from the compiler output
2. **Consistent with other warnings**: Uses the same approach as the `apply()` function for errors and warnings
3. **Vim and Neovim support**: Properly handles both `matchaddpos()` (Vim) and `nvim_buf_add_highlight()` (Neovim)
4. **Respects column ranges**: Highlights only the specific text range, not the entire variable name globally

## Test Results
All existing highlighting tests pass:

✓ Error Highlighting Tests (5/5 PASS)
- Highlight groups defined
- Line highlighting for errors
- Text highlighting for warnings
- Clearing highlights
- Apply returns success

✓ Highlighting Integration Tests (5/5 PASS)
- Highlighting with compiler result
- Clearing after compilation
- Multiple compilations
- Unused variable highlighting
- Highlight colors

✓ Highlighting with Signs Tests (2/2 PASS)
- Highlighting and signs work together
- Clearing signs and highlights

## Impact
- Fixes the bug where variable names were highlighted globally
- Maintains backward compatibility with existing highlighting functionality
- Improves accuracy of unused variable highlighting
- No breaking changes to the API

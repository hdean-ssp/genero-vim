# Task 22 Implementation Guide

## Quick Summary

**Task:** E2.1 - Add Line/Text Error Highlighting
**Priority:** MEDIUM
**Status:** Ready to implement
**Estimated Time:** 3-4 hours

## What This Task Does

Enhances error visualization by adding line and text highlighting to complement existing sign column indicators. Currently, only signs are placed in the sign column. This task adds visual highlighting to make errors more obvious.

## Before You Start

1. Read this file completely
2. Read `NEXT_TASK_CONTEXT.md` in this directory
3. Review `test/ENHANCEMENT_TASKS_SUMMARY.md` (E2.1 section)
4. Review `autoload/genero_tools/compiler/highlight.vim`

## Implementation Overview

### Current State
```
✓ Signs placed in sign column
✗ No line highlighting
✗ No text highlighting
```

### Target State
```
✓ Signs placed in sign column
✓ Line highlighting for error lines
✓ Text highlighting for specific error locations
✓ Different colors for errors vs warnings
```

## Files to Modify

### Primary File
- `autoload/genero_tools/compiler/highlight.vim` - Main implementation

### Reference Files (Don't modify)
- `autoload/genero_tools/compiler/signs.vim` - Sign placement
- `autoload/genero_tools/compiler/quickfix.vim` - Error management
- `autoload/genero_tools/config.vim` - Configuration

## Implementation Steps

### Step 1: Review Current Code
```bash
cat autoload/genero_tools/compiler/highlight.vim
```

Understand:
- Current highlighting implementation
- How errors are passed to the function
- How highlights are cleared

### Step 2: Add Highlight Groups
Define three highlight groups in config or plugin initialization:
- `GeneroError` - Red/orange for errors
- `GeneroWarning` - Yellow for warnings
- `GeneroInfo` - Blue for info

### Step 3: Implement Line Highlighting
Add line-level highlighting for entire error line:
- Use `matchadd()` for Vim
- Use `nvim_buf_add_highlight()` for Neovim
- Apply to entire line

### Step 4: Implement Text Highlighting
Add text-level highlighting for specific error locations:
- Use column ranges from error data
- Highlight only the problematic text
- Support both Vim and Neovim

### Step 5: Implement Clearing
Ensure highlights are properly cleared:
- When errors are resolved
- When compilation completes with no errors
- When user clears errors

### Step 6: Test
Create comprehensive tests:
- Test line highlighting
- Test text highlighting
- Test clearing highlights
- Test with various error types

## Code Patterns

### Vim Line Highlighting
```vim
" Highlight entire line
call matchadd('GeneroError', '\%' . line_num . 'l')
```

### Vim Text Highlighting
```vim
" Highlight specific text range
call matchadd('GeneroError', '\%' . line_num . 'l\%>' . col_start . 'c\%<' . col_end . 'c')
```

### Neovim Line Highlighting
```vim
" Highlight entire line (0-indexed)
call nvim_buf_add_highlight(bufnr, -1, 'GeneroError', line_num - 1, 0, -1)
```

### Neovim Text Highlighting
```vim
" Highlight specific text range (0-indexed)
call nvim_buf_add_highlight(bufnr, -1, 'GeneroError', line_num - 1, col_start, col_end)
```

## Testing

### Create Test File
Create `test/test_error_highlighting.vim` with tests for:
1. Line highlighting with various line numbers
2. Text highlighting with column ranges
3. Highlight group creation
4. Clearing highlights
5. Multiple errors
6. Mixed errors and warnings

### Run Tests
```bash
vim -u NONE -N -S test/test_error_highlighting.vim
```

### Manual Testing
1. Create a Genero file with errors
2. Run `:GeneroCompile`
3. Verify error lines are highlighted
4. Verify text highlighting works
5. Verify colors are appropriate
6. Verify highlights clear when errors clear

## Success Criteria

- [ ] Error lines are highlighted with background color
- [ ] Text highlighting works for specific error locations
- [ ] Different colors for errors vs warnings
- [ ] Highlights don't interfere with syntax highlighting
- [ ] Highlights clear when errors are resolved
- [ ] Works in both Vim and Neovim
- [ ] All tests pass
- [ ] No regressions in existing functionality

## Key Considerations

### Vim vs Neovim Compatibility
- Use `has('nvim')` to detect Neovim
- Implement both `matchadd()` and `nvim_buf_add_highlight()`
- Test in both editors

### Performance
- Be mindful of performance with many errors
- Use efficient highlighting methods
- Avoid unnecessary redraws

### Highlight Groups
- Define groups with sensible defaults
- Allow customization via config
- Use standard Vim highlight group names

### Clearing Highlights
- Ensure highlights are properly cleared
- Handle edge cases (file deleted, buffer closed, etc.)
- Test clearing with various scenarios

## Related Tasks

### Completed
- Task 21 (E1.2) - Reduce startup noise
- Task 24 (E2.3) - Fix statusline bug

### Next
- Task 23 (E2.2) - Fix sign column popping
- Task 20 (E1.1) - Modernize config

## Documentation References

- `NEXT_TASK_CONTEXT.md` - Detailed context
- `TASK_PROGRESSION.md` - Task timeline
- `test/ENHANCEMENT_TASKS_SUMMARY.md` - Implementation guide
- `tasks.md` - Full task specification

## Quick Commands

### View Task Specification
```bash
grep -A 20 "^- \[ \] 22\. E2\.1" .kiro/specs/vim-genero-tools-plugin/tasks.md
```

### View Current Highlight File
```bash
cat autoload/genero_tools/compiler/highlight.vim
```

### View Implementation Guide
```bash
grep -A 50 "### E2\.1: Enhance Error Highlighting" test/ENHANCEMENT_TASKS_SUMMARY.md
```

## Checklist

Before starting implementation:
- [ ] Read this file
- [ ] Read NEXT_TASK_CONTEXT.md
- [ ] Review ENHANCEMENT_TASKS_SUMMARY.md (E2.1 section)
- [ ] Review highlight.vim
- [ ] Understand current implementation
- [ ] Plan implementation approach
- [ ] Create test file
- [ ] Implement line highlighting
- [ ] Implement text highlighting
- [ ] Implement clearing
- [ ] Run all tests
- [ ] Verify no regressions
- [ ] Update task status to complete

## Support

If you have questions:
1. Check NEXT_TASK_CONTEXT.md for detailed context
2. Review ENHANCEMENT_TASKS_SUMMARY.md for implementation details
3. Look at completed tasks (21, 24) for patterns
4. Check test files for expected behavior

---

**Status:** Ready for implementation
**Date:** March 17, 2026
**Priority:** MEDIUM
**Complexity:** MEDIUM
**Estimated Effort:** 3-4 hours

**Next Step:** Read NEXT_TASK_CONTEXT.md

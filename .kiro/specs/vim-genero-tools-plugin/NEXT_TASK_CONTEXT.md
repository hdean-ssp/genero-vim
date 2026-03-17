# Next Task Context: Task 22 (E2.1 - Add Line/Text Error Highlighting)

## Quick Start for New Agent

**Current Task:** Task 22 - E2.1: Add Line/Text Error Highlighting
**Priority:** MEDIUM
**Status:** Ready to implement
**Estimated Effort:** 3-4 hours

## What You Need to Know

### Task Overview
Enhance error visualization by adding line and text highlighting in addition to signs. Currently, only signs are placed in the sign column. This task adds visual highlighting to make errors more obvious.

### Current State
- Signs are placed in sign column (✓ working)
- No line highlighting
- No text highlighting
- Errors are hard to spot visually

### Target State
- Line highlighting for error lines (background color)
- Text highlighting for specific error locations (column ranges)
- Different colors for errors vs warnings
- Proper highlight groups for customization

### Files to Modify
- `autoload/genero_tools/compiler/highlight.vim` - Main file to modify

### Related Files (Reference Only)
- `autoload/genero_tools/compiler/signs.vim` - Sign placement (already working)
- `autoload/genero_tools/compiler/quickfix.vim` - Error management
- `autoload/genero_tools/config.vim` - Configuration

## Implementation Steps

### Step 1: Review Current Implementation
- Read `autoload/genero_tools/compiler/highlight.vim`
- Understand current highlighting implementation
- Identify where highlights are applied

### Step 2: Implement Line Highlighting
- Use `nvim_buf_add_highlight()` for Neovim
- Use `matchadd()` for Vim compatibility
- Apply to entire error line
- Support both Vim and Neovim

### Step 3: Create Highlight Groups
- `GeneroError` - Error line highlighting (red/orange)
- `GeneroWarning` - Warning line highlighting (yellow)
- `GeneroInfo` - Info line highlighting (blue)

### Step 4: Apply Highlights
- When errors are placed (in `signs.vim`)
- When errors are cleared (in `highlight.vim`)
- Support both line and text highlighting

### Step 5: Test
- Verify error lines are highlighted
- Verify text highlighting works
- Test with various error types
- Test clearing highlights

## Key Code Patterns

### Vim Highlighting (matchadd)
```vim
" Add line highlighting
call matchadd('GeneroError', '\%' . line_num . 'l')

" Add text highlighting (column range)
call matchadd('GeneroError', '\%' . line_num . 'l\%>' . col_start . 'c\%<' . col_end . 'c')
```

### Neovim Highlighting (nvim_buf_add_highlight)
```vim
" Add line highlighting
call nvim_buf_add_highlight(bufnr, -1, 'GeneroError', line_num - 1, 0, -1)

" Add text highlighting (column range)
call nvim_buf_add_highlight(bufnr, line_num - 1, 'GeneroError', col_start, col_end)
```

## Configuration Options (Already Exist)
- `compiler_enabled` - Enable compiler integration
- `compiler_show_errors` - Show error highlights
- `compiler_show_warnings` - Show warning highlights

## Testing Strategy

### Unit Tests
- Test line highlighting with various line numbers
- Test text highlighting with column ranges
- Test highlight group creation
- Test clearing highlights

### Integration Tests
- Test with actual compiler output
- Test with multiple errors
- Test with errors and warnings mixed
- Test clearing all highlights

### Manual Testing
- Compile a file with errors
- Verify error lines are highlighted
- Verify text is highlighted
- Verify colors are appropriate
- Verify highlights clear when errors clear

## Success Criteria

- ✓ Error lines are highlighted with background color
- ✓ Text highlighting works for specific error locations
- ✓ Different colors for errors vs warnings
- ✓ Highlights don't interfere with syntax highlighting
- ✓ Highlights clear when errors are resolved
- ✓ Works in both Vim and Neovim
- ✓ All tests pass

## Previous Tasks Completed

1. ✓ Task 21 (E1.2) - Reduce startup noise
2. ✓ Task 24 (E2.3) - Fix statusline bug

## Remaining Enhancement Tasks (After Task 22)

1. Task 23 (E2.2) - Fix sign column popping in/out
2. Task 20 (E1.1) - Modernize default configuration
3. Task 25 (E3.1) - Add which-key integration
4. Task 26 (E3.2) - Document which-key integration
5. Task 27 (NEW) - Debug file streaming
6. Task 28 (NEW) - Keybinding help popup

## Documentation References

### Spec Files
- `.kiro/specs/vim-genero-tools-plugin/tasks.md` - Full task list
- `.kiro/specs/vim-genero-tools-plugin/requirements.md` - Requirements
- `.kiro/specs/vim-genero-tools-plugin/design.md` - Design document

### Implementation Guides
- `test/ENHANCEMENT_TASKS_SUMMARY.md` - Detailed implementation guide
- `test/ENHANCEMENT_TASKS_QUICK_REFERENCE.md` - Quick reference

### Related Task Documentation
- `test/TASK_21_IMPLEMENTATION_SUMMARY.md` - Task 21 (startup noise)
- `test/TASK_24_IMPLEMENTATION_SUMMARY.md` - Task 24 (statusline bug)

## Quick Command Reference

### View Current Task
```bash
grep -A 30 "^- \[ \] 22\. E2\.1" .kiro/specs/vim-genero-tools-plugin/tasks.md
```

### View Highlight File
```bash
cat autoload/genero_tools/compiler/highlight.vim
```

### View Related Files
```bash
cat autoload/genero_tools/compiler/signs.vim
cat autoload/genero_tools/config.vim
```

## Notes for New Agent

1. **Vim vs Neovim:** This task requires supporting both Vim and Neovim. Use compatibility checks.
2. **Highlight Groups:** Define highlight groups in config or plugin initialization.
3. **Performance:** Be mindful of performance with many errors. Use efficient highlighting methods.
4. **Clearing:** Ensure highlights are properly cleared when errors are resolved.
5. **Testing:** Create comprehensive tests to verify highlighting works correctly.

## Next Steps

1. Read this document completely
2. Review `autoload/genero_tools/compiler/highlight.vim`
3. Review `test/ENHANCEMENT_TASKS_SUMMARY.md` section on E2.1
4. Implement line highlighting
5. Implement text highlighting
6. Create tests
7. Verify all tests pass

---

**Status:** Ready for implementation
**Date:** March 17, 2026
**Priority:** MEDIUM
**Complexity:** MEDIUM

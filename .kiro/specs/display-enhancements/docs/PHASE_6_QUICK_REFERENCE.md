# Phase 6: Debug Streaming - Quick Reference

## What Phase 6 Does

Improves debug streaming by updating the file selection UI to use standard display functions while keeping debug files always displayed in split windows (independent of global display_mode).

---

## Current State

✓ Debug stream module exists
✓ File streaming works
✓ Split window display (correct, keep as-is)
✓ Configuration options exist
✗ File selection UI uses custom functions (should use standard display functions)

---

## What Will Be Updated

### File Selection UI
- Replace custom floating window with standard display functions
- Use `display#result()` or `display#details()`
- Keep file selection functionality
- Maintain keybindings for selection

### Split Width Configuration
- Verify `debug_stream_width` is properly used
- Confirm default calculation (1/3 of screen)
- Document configuration usage

---

## Configuration

### Split Width
```vim
let g:genero_tools_config.debug_stream_width = 0      " 0 = auto-calculate (1/3 of screen)
let g:genero_tools_config.debug_stream_width = 60     " Custom width
```

### Other Options
```vim
let g:genero_tools_config.debug_stream_max_lines = 1000
let g:genero_tools_config.debug_stream_auto_scroll = 1
let g:genero_tools_config.debug_stream_directory = './debug'
```

---

## Key Design Principle

**Debug streaming display is independent of global `display_mode`:**
- Always opens in split window
- Like signs (always shown if enabled)
- Like virtual text (always shown if enabled)
- Not affected by user's display_mode preference

---

## Files to Modify

1. **autoload/genero_tools/debug_stream.vim**
   - Update file selection UI to use standard display functions
   - Keep split window display as-is
   - Keep file streaming logic unchanged

---

## Success Criteria

✓ File selection UI uses standard display functions
✓ Debug files always open in split windows
✓ Split width configuration works correctly
✓ Backward compatible
✓ No syntax errors

---

## Estimated Effort

**1 day** (6-8 hours)

---

## Summary

Phase 6 improves debug streaming by updating the file selection UI to use standard display functions while keeping debug files always displayed in split windows (independent of global display_mode).


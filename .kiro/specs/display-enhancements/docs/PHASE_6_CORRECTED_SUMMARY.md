# Phase 6: Debug Streaming - Corrected Summary

## Status: READY FOR IMPLEMENTATION

Phase 6 has been clarified and corrected. Debug streaming display will remain independent of global display_mode (like signs, virtual text, and highlighting).

---

## Corrected Scope

### What Phase 6 Will Do

1. **Update File Selection UI**
   - Replace custom floating window with standard display functions
   - Use `display#result()` or `display#details()`
   - Keep file selection functionality intact

2. **Verify Split Width Configuration**
   - Ensure `debug_stream_width` is properly used
   - Confirm default calculation (1/3 of screen width)
   - Document configuration usage

3. **Keep Debug Display as Split**
   - Debug files always open in split windows
   - NOT affected by global `display_mode`
   - Independent display (like signs, virtual text, highlighting)

---

## What Phase 6 Will NOT Do

- ✗ Change debug display from split to other modes
- ✗ Make debug display respect global `display_mode`
- ✗ Add display mode override for debug streaming

**Reason:** Debug streaming should remain independent (like signs, virtual text, highlighting).

---

## Current Configuration (Already in Place)

```vim
debug_stream_enabled: 0
debug_stream_width: 0              " 0 = auto-calculate (1/3 of screen)
debug_stream_max_lines: 1000
debug_stream_auto_scroll: 1
debug_stream_directory: './debug'
```

**Status:** ✓ All configuration options are properly initialized in `autoload/genero_tools/config.vim`

---

## Current Implementation

### Debug Stream Display
```vim
" Split window display (KEEP AS-IS)
execute 'rightbelow ' . width . 'vsplit'
execute 'vertical resize ' . width
let buf = nvim_create_buf(0, 1)
call nvim_set_current_buf(buf)
```

**Status:** ✓ Correct (always split, independent of display_mode)

### File Selection UI
```vim
" Custom floating window (NEEDS UPDATE)
function! s:show_file_selector(file_names, file_paths)
  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)
  " ... custom keybindings ...
endfunction
```

**Status:** ✗ Uses custom functions (should use standard display functions)

---

## Design Principle

**Debug streaming display is independent of global `display_mode`:**

Like:
- ✓ Signs (always shown if enabled, not affected by display_mode)
- ✓ Virtual text (always shown if enabled, not affected by display_mode)
- ✓ Syntax highlighting (always shown if enabled, not affected by display_mode)

Debug streaming:
- ✓ Always opens in split window
- ✓ Not affected by user's display_mode preference
- ✓ Configurable split width
- ✓ Independent display

---

## Implementation Plan

### Step 1: Update File Selection UI
- Replace custom floating window with `display#result()` or `display#details()`
- Use standard display functions for consistency
- Keep file selection functionality
- Maintain keybindings for selection

### Step 2: Verify Split Width Configuration
- Confirm `debug_stream_width` is properly used in `start()` function
- Test default calculation (1/3 of screen width)
- Document configuration usage

### Step 3: Testing
- Test file selection with standard display functions
- Test split width configuration
- Test file streaming in split window
- Test backward compatibility

---

## Files to Modify

### 1. autoload/genero_tools/debug_stream.vim
- Update `s:show_file_selector()` to use standard display functions
- Keep split window display as-is
- Keep file streaming logic unchanged

### 2. autoload/genero_tools/config.vim
- ✓ Already has all required configuration options
- No changes needed

---

## Configuration Examples

### Default (Auto-calculate width)
```vim
let g:genero_tools_config = {
  \ 'debug_stream_width': 0,
  \ }
```
Result: Split width = 1/3 of screen (minimum 50 columns)

### Custom Width
```vim
let g:genero_tools_config = {
  \ 'debug_stream_width': 60,
  \ }
```
Result: Split width = 60 columns

### Max Lines
```vim
let g:genero_tools_config = {
  \ 'debug_stream_max_lines': 2000,
  \ }
```
Result: Keep last 2000 lines in debug stream

---

## Success Criteria

- ✓ File selection UI uses standard display functions
- ✓ Debug files always open in split windows
- ✓ Split width configuration works correctly
- ✓ Backward compatible
- ✓ No syntax errors
- ✓ All tests pass

---

## Estimated Effort

**1 day** (6-8 hours)
- Update file selection UI: 2-3 hours
- Verify split width configuration: 1-2 hours
- Testing: 2-3 hours

---

## What Stays the Same

- ✓ Debug files always open in split windows
- ✓ File streaming logic
- ✓ File watching (timer-based)
- ✓ Line limiting (max_lines)
- ✓ Auto-scroll functionality
- ✓ All existing configuration options

---

## Key Differences from Original Phase 6 Plan

### Original Plan (Incorrect)
- Add display mode support to debug streaming
- Make debug display respect global `display_mode`
- Support split, popup, echo modes

### Corrected Plan (Correct)
- Keep debug display as split (independent)
- Update file selection UI to use standard functions
- Verify split width configuration

**Reason:** Debug streaming should remain independent (like signs, virtual text, highlighting), not affected by global display_mode.

---

## Summary

Phase 6 will improve debug streaming by:
1. Updating the file selection UI to use standard display functions
2. Verifying split width configuration is properly supported
3. Keeping debug files always displayed in split windows (independent of global display_mode)

This approach maintains consistency with the design principle that in-editor display elements (signs, virtual text, highlighting, debug streaming) are independent of the global display_mode setting.


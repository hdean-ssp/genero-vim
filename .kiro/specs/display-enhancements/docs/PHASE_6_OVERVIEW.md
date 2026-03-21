# Phase 6: Debug Streaming - Overview

## Scope

Improve debug streaming by:
1. Using standard display functions for file selection UI
2. Ensuring debug files always open in split windows
3. Verifying split width configuration is properly supported

**Note:** Debug streaming display should remain as split windows (not affected by global display_mode).

---

## Current State

### What Exists
- ✓ Debug stream module (`autoload/genero_tools/debug_stream.vim`)
- ✓ File streaming functionality (reads debug files)
- ✓ Split window display (hardcoded)
- ✓ Configuration options (`debug_stream_*`)
- ✓ File selection UI (custom floating window)

### What Needs Improvement
- ✗ File selection UI uses custom floating window (not standard display functions)
- ✗ Split width configuration may not be fully utilized
- ✓ Debug files always open in split (correct, keep as-is)

---

## What Phase 6 Will Do

### 1. Update File Selection UI
- Replace custom floating window with `display#result()` or `display#details()`
- Use standard display functions for consistency
- Keep file selection functionality intact

### 2. Verify Split Width Configuration
- Ensure `debug_stream_width` is properly used
- Verify default calculation (1/3 of screen width)
- Confirm configuration is accessible to users

### 3. Keep Debug Display as Split
- Debug files always open in split windows
- NOT affected by global `display_mode`
- Independent display (like signs, virtual text, highlighting)

---

## Current Implementation

### Debug Stream Module
```vim
" Split window display (keep as-is)
execute 'rightbelow ' . width . 'vsplit'
execute 'vertical resize ' . width
let buf = nvim_create_buf(0, 1)
call nvim_set_current_buf(buf)

" File selection UI (needs update)
function! s:show_file_selector(file_names, file_paths)
  " Custom floating window implementation
  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)
  " ... custom keybindings ...
endfunction
```

**Status:** 
- ✓ Split display is correct (keep as-is)
- ✗ File selection UI uses custom functions (should use standard display functions)

### Configuration
```vim
debug_stream_enabled: 0
debug_stream_width: 0              " 0 = auto-calculate (1/3 of screen)
debug_stream_max_lines: 1000
debug_stream_auto_scroll: 1
debug_stream_directory: './debug'
```

**Status:** ✓ Configuration is in place

---

## What Phase 6 Will NOT Do

- ✗ Change debug display from split to other modes
- ✗ Make debug display respect global `display_mode`
- ✗ Add display mode override for debug streaming

**Reason:** Debug streaming should remain independent (like signs, virtual text, highlighting).

---

## Implementation Plan

### Step 1: Update File Selection UI
- Replace custom floating window with standard display functions
- Use `display#result()` to show file list
- Keep file selection functionality
- Maintain keybindings for selection

### Step 2: Verify Split Width Configuration
- Confirm `debug_stream_width` is properly used
- Test default calculation
- Document configuration usage

### Step 3: Testing
- Test file selection with standard display functions
- Test split width configuration
- Test file streaming in split window
- Test backward compatibility

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

## Files to Modify

### 1. autoload/genero_tools/debug_stream.vim
- Update `s:show_file_selector()` to use standard display functions
- Keep split window display as-is
- Keep file streaming logic unchanged

### 2. autoload/genero_tools/config.vim
- Verify `debug_stream_width` is properly initialized (already done)

---

## Current Usage

### Commands
```vim
:GeneroDebugStream <file>      " Start debug streaming (split window)
:GeneroDebugStreamStop         " Stop debug streaming
:GeneroDebugStreamToggle       " Toggle debug streaming
:GeneroDebugStreamSelect       " Select debug file (will use standard display)
:GeneroDebugStreamClear        " Clear debug stream
:GeneroDebugStreamStatus       " Show status
```

**Note:** Debug streaming is Neovim-only

---

## Configuration Examples

### Default (Auto-calculate width)
```vim
let g:genero_tools_config = {
  \ 'debug_stream_width': 0,
  \ }
```

### Custom Width
```vim
let g:genero_tools_config = {
  \ 'debug_stream_width': 60,
  \ }
```

### Max Lines
```vim
let g:genero_tools_config = {
  \ 'debug_stream_max_lines': 2000,
  \ }
```

---

## Key Design Principle

**Debug streaming display is independent of global `display_mode`:**
- Like signs (always shown if enabled)
- Like virtual text (always shown if enabled)
- Like syntax highlighting (always shown if enabled)
- Always opens in split window
- Not affected by user's display_mode preference

---

## Integration Points

### 1. Debug Stream Module
- `autoload/genero_tools/debug_stream.vim`
- Main implementation

### 2. Display Module
- `autoload/genero_tools/display.vim`
- Used for file selection UI only (not debug display)

### 3. Configuration
- `autoload/genero_tools/config.vim`
- Debug stream configuration

---

## Benefits

### For Users
- ✓ Consistent file selection UI
- ✓ Configurable split width
- ✓ Predictable debug display location

### For Developers
- ✓ Standard display functions for UI
- ✓ Consistent code patterns
- ✓ Easier to maintain

### For Code Quality
- ✓ Reduced code duplication
- ✓ Better separation of concerns
- ✓ Clearer code intent

---

## Next After Phase 6

Once Phase 6 is complete, Phase 7 (Error Display) can proceed with similar updates to the error display module.

---

## Summary

Phase 6 will improve debug streaming by updating the file selection UI to use standard display functions while keeping debug files always displayed in split windows (independent of global display_mode).


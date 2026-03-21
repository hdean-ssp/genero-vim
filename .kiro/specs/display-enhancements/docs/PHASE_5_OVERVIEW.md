# Phase 5: Progress & Status - Overview

## Scope

Update progress and status display to use the new display infrastructure, enabling progress messages to be displayed in different modes (popup, split, echo, inline) with auto-dismiss capabilities.

---

## Current State

### What Exists
- ✓ Progress module (`autoload/genero_tools/progress.vim`)
- ✓ Progress functions (show, hide, show_elapsed, get_elapsed)
- ✓ Direct `echom` calls for progress display
- ✓ Configuration option `progress_display_mode` (initialized in Phase 1)
- ✓ Notification system with auto-dismiss (from Phase 1)

### What's Missing
- ✗ Display mode support for progress messages
- ✗ Integration with display#notify()
- ✗ Auto-dismiss capabilities
- ✗ Support for all display modes

---

## What Phase 5 Will Do

### 1. Update Progress Module
- Replace direct `echom` calls with `display#notify()`
- Use `display#get_mode('progress')` to determine display mode
- Respect `progress_display_mode` override if set
- Fall back to global `display_mode` if override is empty
- Support auto-dismiss with configurable duration

### 2. Update Compiler Commands
- Replace direct `echom` calls with `display#notify()`
- Use progress display for compilation status
- Show elapsed time using notification system

### 3. Update Command Execution
- Replace direct `echom` calls with `display#notify()`
- Use progress display for async operations
- Show elapsed time using notification system

---

## Files to Modify

### 1. autoload/genero_tools/progress.vim
- Update `show()` function to use `display#notify()`
- Update `hide()` function (may not be needed with auto-dismiss)
- Update `show_elapsed()` function to use `display#notify()`
- Add `show_with_mode()` function for explicit mode control

### 2. autoload/genero_tools/compiler/commands.vim
- Replace `echom` calls with `display#notify()`
- Use progress display for compilation status

### 3. autoload/genero_tools/command.vim
- Replace `echom` calls with `display#notify()`
- Use progress display for async operations

---

## Display Modes Supported

| Mode | Description | Vim | Neovim |
|------|-------------|-----|--------|
| **echo** | Command line | ✓ | ✓ |
| **popup** | Floating window | Echo | ✓ |
| **inline** | Inline popup | Echo | ✓ |
| **split** | Split window | ✓ | ✓ |

**Note:** Progress messages typically use echo, popup, or inline modes. Quickfix is not suitable for progress.

---

## Configuration

### Feature-Specific Override
```vim
let g:genero_tools_config.progress_display_mode = 'popup'
```

### Notification Options
```vim
let g:genero_tools_config.notify_enabled = 1        " Enable notifications
let g:genero_tools_config.notify_duration = 3000    " Auto-dismiss timer (ms)
```

### Examples

**Default (Echo):**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'progress_display_mode': '',
  \ 'notify_enabled': 1,
  \ 'notify_duration': 3000,
  \ }
```

**Popup Display:**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'progress_display_mode': 'popup',
  \ 'notify_enabled': 1,
  \ 'notify_duration': 3000,
  \ }
```

**Inline Display:**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'progress_display_mode': 'inline',
  \ 'notify_enabled': 1,
  \ 'notify_duration': 3000,
  \ }
```

---

## Implementation Plan

### Step 1: Update Progress Module
- Update `show()` to use `display#notify()`
- Update `show_elapsed()` to use `display#notify()`
- Add `show_with_mode()` for explicit mode control
- Keep `hide()` for backward compatibility (may be no-op with auto-dismiss)

### Step 2: Update Compiler Commands
- Replace `echom` calls with `display#notify()`
- Use progress display for compilation status
- Show elapsed time using notification system

### Step 3: Update Command Execution
- Replace `echom` calls with `display#notify()`
- Use progress display for async operations
- Show elapsed time using notification system

### Step 4: Testing
- Test all display modes
- Test feature-specific overrides
- Test auto-dismiss functionality
- Test backward compatibility

---

## Success Criteria

- ✓ Progress messages respect `display_mode` config
- ✓ Progress messages respect `progress_display_mode` override
- ✓ All display modes work (echo, popup, inline, split)
- ✓ Auto-dismiss works with configurable duration
- ✓ Backward compatible
- ✓ No syntax errors
- ✓ All tests pass

---

## Estimated Effort

**1-2 days** (8-12 hours)
- Update progress module: 2-3 hours
- Update compiler commands: 1-2 hours
- Update command execution: 1-2 hours
- Testing: 2-3 hours

---

## What Stays the Same

- ✓ Progress tracking logic
- ✓ Elapsed time calculation
- ✓ All existing configuration options
- ✓ Async operation handling

---

## Current Usage Patterns

### Progress Display
```vim
" Current (Phase 4)
call genero_tools#progress#show('Compiling...')
" ... do work ...
call genero_tools#progress#hide()

" After Phase 5
call genero_tools#display#notify('Compiling...', 0)
" ... do work ...
" Auto-dismisses after notify_duration
```

### Elapsed Time Display
```vim
" Current (Phase 4)
call genero_tools#progress#show_elapsed('Command completed', start_time)

" After Phase 5
call genero_tools#display#notify('Command completed (5s elapsed)', 0)
```

---

## Integration Points

### 1. Compiler Commands
- `autoload/genero_tools/compiler/commands.vim`
- Uses progress for compilation status
- Shows elapsed time

### 2. Command Execution
- `autoload/genero_tools/command.vim`
- Uses progress for async operations
- Shows elapsed time

### 3. Autocompile
- `autoload/genero_tools/compiler/autocompile.vim`
- Already updated in Phase 2 to use `display#notify()`
- No changes needed

---

## Next After Phase 5

Once Phase 5 is complete, Phase 6 (Debug Streaming) can proceed with similar updates to the debug stream module.

---

## Summary

Phase 5 will update progress and status display to use the new display infrastructure, enabling progress messages to be displayed in different modes with auto-dismiss capabilities while maintaining backward compatibility.


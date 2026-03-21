# Phase 5: Progress & Status - Quick Reference

## What Phase 5 Does

Updates progress and status display to use the new display infrastructure, enabling progress messages to be displayed in different modes with auto-dismiss capabilities.

---

## Current State

✓ Progress module exists
✓ Configuration option exists
✗ Display mode support missing
✗ Integration with display#notify() missing
✗ Auto-dismiss capabilities missing

---

## What Will Be Updated

### Progress Module
- Replace `echom` calls with `display#notify()`
- Use `display#get_mode('progress')`
- Support auto-dismiss

### Compiler Commands
- Replace `echom` calls with `display#notify()`
- Use progress display for status

### Command Execution
- Replace `echom` calls with `display#notify()`
- Use progress display for async operations

---

## Configuration

### Feature-Specific Override
```vim
let g:genero_tools_config.progress_display_mode = 'popup'
```

### Notification Options
```vim
let g:genero_tools_config.notify_enabled = 1
let g:genero_tools_config.notify_duration = 3000
```

### Examples

**Default (Echo):**
```vim
let g:genero_tools_config.progress_display_mode = ''
```

**Popup:**
```vim
let g:genero_tools_config.progress_display_mode = 'popup'
```

**Inline:**
```vim
let g:genero_tools_config.progress_display_mode = 'inline'
```

---

## Display Modes

| Mode | Vim | Neovim |
|------|-----|--------|
| echo | ✓ | ✓ |
| popup | Echo | ✓ |
| inline | Echo | ✓ |
| split | ✓ | ✓ |

---

## Files to Modify

1. **autoload/genero_tools/progress.vim**
   - Update show(), hide(), show_elapsed()

2. **autoload/genero_tools/compiler/commands.vim**
   - Replace echom calls

3. **autoload/genero_tools/command.vim**
   - Replace echom calls

---

## Success Criteria

✓ Progress respects `display_mode`
✓ Progress respects `progress_display_mode` override
✓ All display modes work
✓ Auto-dismiss works
✓ Backward compatible
✓ No syntax errors

---

## Estimated Effort

**1-2 days** (8-12 hours)

---

## Summary

Phase 5 updates progress and status display to use the new display infrastructure, enabling flexible display options with auto-dismiss capabilities while maintaining backward compatibility.


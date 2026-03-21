# Phase 1: Core Infrastructure - Brief Summary

## What is Phase 1?

Phase 1 establishes the foundation for unified display architecture by adding new functions and configuration options to the display module.

## Key Principle

**In-editor signs/highlighting (errors, warnings, hints, SVN markers) remain independent of display_mode and are always shown if enabled.**

---

## What Gets Done

### 1. Add 5 New Functions to Display Module

**File:** `autoload/genero_tools/display.vim`

```vim
genero_tools#display#notify(message, duration)
  → Display status/progress messages with auto-dismiss

genero_tools#display#error(error_message, display_mode)
  → Display errors respecting display_mode

genero_tools#display#details(title, content, display_mode)
  → Display detailed information (hints, signatures, etc.)

genero_tools#display#safe_result(result, display_mode)
  → Safe display wrapper with error handling

genero_tools#display#get_mode(feature)
  → Resolve display mode with feature-specific overrides
```

### 2. Add 6 New Configuration Options

**File:** `autoload/genero_tools/config.vim`

```vim
compiler_display_mode: ''        " Feature-specific override
signatures_display_mode: ''      " Feature-specific override
progress_display_mode: ''        " Feature-specific override
debug_display_mode: ''           " Feature-specific override
error_display_mode: ''           " Feature-specific override
notify_enabled: 1                " Enable notifications
notify_duration: 3000            " Auto-dismiss timer (ms)
error_show_details: 1            " Show error details
```

**Important:** Empty string = inherit from global `display_mode`
**Note:** `hints_display` (signs/virtual_text/both) is independent and unchanged

### 3. Update Configuration Validation

Validate new config options and feature-specific display modes.

---

## What Does NOT Change

- ✓ In-editor signs remain independent (always shown if enabled)
- ✓ **Hints display (signs/virtual_text/both) remains independent** (controlled by `hints_display` config)
- ✓ Syntax highlighting remains independent
- ✓ Virtual text remains independent
- ✓ All existing functions remain unchanged
- ✓ All existing configs remain unchanged
- ✓ Default behavior unchanged
- ✓ 100% backward compatible

---

## Implementation Details

### New Functions (~150 lines)
- `notify()` - Status message display
- `error()` - Error display
- `details()` - Details popup
- `safe_result()` - Error-safe wrapper
- `get_mode()` - Mode resolution helper

### New Config (~50 lines)
- 5 feature-specific display mode overrides (compiler, signatures, progress, debug, error)
- 3 notification/error display options
- **Note:** `hints_display` is independent and unchanged

### Validation (~30 lines)
- Validate feature-specific display modes
- Validate notification options

**Total: ~230 lines of code**

---

## Configuration Examples

### Default (No Changes)
```vim
display_mode: 'quickfix'
compiler_display_mode: ''  " inherit from global
hints_display_mode: ''     " inherit from global
```

### Custom (Feature-Specific Overrides)
```vim
display_mode: 'quickfix'
compiler_display_mode: 'popup'    " override: use popup for compiler
hints_display_mode: 'split'       " override: use split for hints
signatures_display_mode: 'popup'  " override: use popup for signatures
```

---

## Testing

- Unit tests for all new functions
- Integration tests for mode resolution
- Configuration validation tests
- Backward compatibility tests
- Manual visual inspection

---

## Timeline

**1-2 days** (14-22 hours)

| Task | Duration |
|------|----------|
| Implement functions | 4-6 hours |
| Implement config | 2-3 hours |
| Implement validation | 1-2 hours |
| Testing | 6-9 hours |
| Documentation | 1-2 hours |

---

## Success Criteria

- ✓ All new functions work correctly
- ✓ Display mode resolution works
- ✓ Configuration validation works
- ✓ Backward compatibility maintained
- ✓ All tests pass

---

## After Phase 1

Phase 1 provides the foundation. Subsequent phases update individual features:

- **Phase 2:** Compiler uses new functions
- **Phase 3:** Hints use new functions
- **Phase 4:** Signatures use new functions
- **Phase 5:** Progress uses new functions
- **Phase 6:** Debug stream uses new functions
- **Phase 7:** Error handling uses new functions

Each phase is independent and can be done incrementally.

---

## Key Points

1. **In-editor signs are unaffected** - Always shown if enabled
2. **Backward compatible** - No breaking changes
3. **Optional overrides** - Users only set what they want
4. **Foundation only** - Phase 1 doesn't change feature behavior
5. **Incremental** - Each phase builds on previous

---

## Files Modified

1. `autoload/genero_tools/display.vim` - Add 5 functions
2. `autoload/genero_tools/config.vim` - Add 9 options + validation

---

## Ready to Start?

Phase 1 is ready to implement. It's low-risk, backward-compatible, and provides the foundation for all subsequent phases.

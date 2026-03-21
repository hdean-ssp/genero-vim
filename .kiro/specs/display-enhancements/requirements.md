# Display Enhancements - Requirements

## Overview

Implement a unified display architecture across the Genero-Tools plugin to ensure consistent display behavior across all features while maintaining backward compatibility and respecting user configuration preferences.

---

## Completed Phases

### Phase 1: Core Infrastructure ✓ COMPLETE
- Extended display module with new functions
- Added feature-specific display mode overrides
- Added notification/error display options
- All configuration options initialized
- 100% backward compatible

### Phase 2: Compiler Integration ✓ COMPLETE
- Compiler results now respect `display_mode` config
- Feature-specific `compiler_display_mode` override implemented
- Progress messages use `display#notify()`
- Signs remain independent (always shown if enabled)
- All display modes supported

### Phase 3: Hints Display Configuration ✓ COMPLETE
- Verified hints display configuration is separate
- `hints_display` controls in-editor display (independent)
- `hints_display_mode` controls results display (respects display_mode)
- Configuration properly initialized
- No implementation changes needed

### Phase 4: Signatures Integration ✓ COMPLETE
- Added `show()` function for single signature display
- Added `show_list()` function for multiple signatures
- Both functions use `display#get_mode('signatures')`
- All display modes supported
- 100% backward compatible

---

## Remaining Phases

### Phase 5: Progress & Status ✗ NOT REQUIRED
- Assessed and determined not required
- Progress module rarely used
- Compiler command echom calls are informational (not progress)
- Phase 2 already addressed main use case (autocompile)
- Minimal user-facing benefit from refactoring

### Phase 6: Debug Streaming ⏳ READY FOR IMPLEMENTATION
- Update file selection UI to use standard display functions
- Verify split width configuration is properly supported
- Keep debug files always displayed in split windows (independent)
- Debug streaming display NOT affected by global `display_mode`
- Estimated effort: 1 day (6-8 hours)

### Phase 7: Error Display ⏳ PLANNED
- Update error handling to use `display#error()`
- Support all display modes for error messages
- Estimated effort: 1-2 days

---

## Key Design Principles

### 1. Separation of Concerns
- **In-editor display** (signs, highlighting, virtual text) is independent of `display_mode`
- **Result display** (quickfix, popup, split, echo) respects `display_mode`
- Each has its own configuration

### 2. Backward Compatibility
- All existing configs still work
- Default behavior unchanged
- No breaking changes

### 3. Feature Independence
- Signs always shown if enabled (not affected by display_mode)
- Highlighting always shown if enabled (not affected by display_mode)
- Virtual text always shown if enabled (not affected by display_mode)
- Debug streaming always shown in split (not affected by display_mode)

### 4. Consistent Patterns
- All features use `display#get_mode(feature)` to resolve display mode
- All features can have feature-specific overrides
- All features fall back to global `display_mode` if not overridden

---

## Configuration Structure

### Global Display Configuration
```vim
display_mode: 'quickfix'                 " Default for all result displays
floating_window_position: 'center'       " Popup position
floating_window_width: 80                " Popup width
floating_window_height: 20               " Popup height
floating_window_border: 'rounded'        " Border style
popup_auto_close_delay: 5000             " Auto-close timer (ms)
```

### Feature-Specific Display Mode Overrides
```vim
compiler_display_mode: ''                " empty = inherit from global
hints_display_mode: ''                   " empty = inherit from global
signatures_display_mode: ''              " empty = inherit from global
progress_display_mode: ''                " empty = inherit from global
debug_display_mode: ''                   " empty = inherit from global
error_display_mode: ''                   " empty = inherit from global
```

### In-Editor Display (Independent)
```vim
compiler_sign_column: 1                  " Always shown if enabled
compiler_highlight_unused: 1             " Always shown if enabled
hints_display: 'signs'                   " signs, virtual_text, or both
svn_show_added: 1                        " Always shown if enabled
svn_show_modified: 1                     " Always shown if enabled
svn_show_deleted: 1                      " Always shown if enabled
debug_stream_width: 0                    " 0 = auto-calculate (1/3 of screen)
debug_stream_max_lines: 1000             " Line limiting
debug_stream_auto_scroll: 1              " Auto-scroll enabled
```

### Notification/Status Display
```vim
notify_enabled: 1                        " Enable notifications
notify_duration: 3000                    " Auto-dismiss timer (ms)
error_show_details: 1                    " Show error details
```

---

## Display Modes Supported

| Mode | Description | Vim | Neovim |
|------|-------------|-----|--------|
| **quickfix** | Quickfix list | ✓ | ✓ |
| **popup** | Floating window | Echo | ✓ |
| **split** | Split window | ✓ | ✓ |
| **echo** | Command line | ✓ | ✓ |
| **inline** | Inline popup | Echo | ✓ |

---

## Success Criteria

- ✓ All features respect `display_mode` config
- ✓ All features support feature-specific overrides
- ✓ All display modes work correctly
- ✓ In-editor display remains independent
- ✓ 100% backward compatible
- ✓ No syntax errors
- ✓ All tests pass

---

## Implementation Status

| Phase | Status | Effort | Notes |
|-------|--------|--------|-------|
| Phase 1 | ✓ Complete | 1-2 days | Core infrastructure |
| Phase 2 | ✓ Complete | 1 day | Compiler integration |
| Phase 3 | ✓ Complete | 30 min | Hints verification |
| Phase 4 | ✓ Complete | 1 hour | Signatures integration |
| Phase 5 | ✗ Not Required | - | Minimal impact |
| Phase 6 | ⏳ Ready | 1 day | Debug streaming UI |
| Phase 7 | ⏳ Planned | 1-2 days | Error display |

---

## Next Steps

1. **Phase 6 Implementation** - Update debug streaming file selection UI
2. **Phase 7 Implementation** - Add error display support
3. **Comprehensive Testing** - Test all display modes
4. **Documentation** - Update user documentation
5. **User Feedback** - Gather feedback and iterate


# Phase 1: Core Infrastructure - Implementation Summary

## Overview

Phase 1 establishes the foundation for unified display architecture. This phase adds new functions to the display module and extends configuration to support feature-specific display mode overrides.

**Estimated Duration:** 1-2 days
**Complexity:** Low to Medium
**Risk:** Low (no breaking changes)

---

## Key Principle

**In-editor signs/highlighting (errors, warnings, hints, SVN markers) remain independent of display_mode and are always shown if enabled.**

---

## What Gets Done in Phase 1

### 1. Extend Display Module

**File:** `autoload/genero_tools/display.vim`

Add four new functions to support unified display:

#### 1.1 `genero_tools#display#notify(message, duration)`
```vim
" Display notification/status message
" Used for: "Compilation complete", "Cache cleared", etc.
" Auto-dismisses after duration (0 = no auto-dismiss)
function! genero_tools#display#notify(message, duration) abort
  " Implementation for both Vim and Neovim
  " Neovim: Floating window with auto-close timer
  " Vim: Echo with optional timer
endfunction
```

**Purpose:** Unified status/progress message display
**Replaces:** Direct `echom` calls in progress.vim

#### 1.2 `genero_tools#display#error(error_message, display_mode)`
```vim
" Display error with display mode support
function! genero_tools#display#error(error_message, display_mode) abort
  " Format and display error respecting display_mode
  " Fallback to echo if mode unsupported
endfunction
```

**Purpose:** Unified error display
**Replaces:** Direct error handling in error.vim

#### 1.3 `genero_tools#display#details(title, content, display_mode)`
```vim
" Display detailed information in appropriate mode
" Used for: hint details, signature info, etc.
function! genero_tools#display#details(title, content, display_mode) abort
  " Display details popup/window based on mode
endfunction
```

**Purpose:** Unified details/info display
**Replaces:** Custom popup implementations

#### 1.4 `genero_tools#display#safe_result(result, display_mode)`
```vim
" Safe display with error handling
function! genero_tools#display#safe_result(result, display_mode) abort
  " Wrapper that handles errors gracefully
  " Logs errors if debug_mode enabled
  " Provides meaningful fallback
endfunction
```

**Purpose:** Error-safe display wrapper
**Replaces:** Try/catch blocks in individual features

#### 1.5 `genero_tools#display#get_mode(feature)`
```vim
" Get effective display mode for a feature
function! genero_tools#display#get_mode(feature) abort
  " Check for feature-specific override
  let override_key = a:feature . '_display_mode'
  let override = genero_tools#config#get(override_key)
  
  if !empty(override)
    return override
  endif
  
  " Fall back to global display_mode
  return genero_tools#config#get('display_mode')
endfunction
```

**Purpose:** Resolve display mode with feature-specific overrides
**Usage:** Called by all features to determine which display mode to use

---

### 2. Extend Configuration

**File:** `autoload/genero_tools/config.vim`

Add feature-specific display mode override options:

```vim
" Feature-specific display mode overrides (optional)
" Empty string means inherit from global display_mode
call genero_tools#config#init_key('compiler_display_mode', '')
call genero_tools#config#init_key('signatures_display_mode', '')
call genero_tools#config#init_key('progress_display_mode', '')
call genero_tools#config#init_key('debug_display_mode', '')
call genero_tools#config#init_key('error_display_mode', '')

" Notification display options
call genero_tools#config#init_key('notify_enabled', 1)
call genero_tools#config#init_key('notify_duration', 3000)

" Error display options
call genero_tools#config#init_key('error_show_details', 1)
```

**Important:** These are **optional overrides**. If not set, features inherit from global `display_mode`.
**Note:** `hints_display` (signs/virtual_text/both) is independent and remains unchanged.

---

### 3. Update Configuration Validation

**File:** `autoload/genero_tools/config.vim`

Add validation for new config options:

```vim
" In genero_tools#config#validate():

" Validate feature-specific display modes
for feature in ['compiler', 'signatures', 'progress', 'debug', 'error']
  let mode_key = feature . '_display_mode'
  let mode = genero_tools#config#get(mode_key)
  
  " Only validate if not empty (empty = inherit from global)
  if !empty(mode)
    let mode = genero_tools#compat#validate_display_mode(mode)
    let g:genero_tools_config[mode_key] = mode
  endif
endfor

" Validate notification options
let notify_duration = genero_tools#config#get('notify_duration')
if notify_duration < 0
  call genero_tools#error#warn('config', 'notify_duration must be non-negative, using default 3000')
  let g:genero_tools_config.notify_duration = 3000
endif
```

---

## What Does NOT Change in Phase 1

### In-Editor Display (Unaffected)
- ✓ Sign column indicators remain independent
- ✓ **Hints display (signs/virtual_text/both) remains independent** (controlled by `hints_display` config)
- ✓ Syntax highlighting remains independent
- ✓ Virtual text remains independent
- ✓ All controlled by feature-specific configs (compiler_sign_column, hints_display, etc.)
- ✓ Always shown if enabled, regardless of display_mode

### Existing Functions (Backward Compatible)
- ✓ All existing display functions remain unchanged
- ✓ All existing configuration options remain unchanged
- ✓ Default behavior unchanged
- ✓ No breaking changes

### Features (Not Yet Updated)
- ✓ Compiler still uses quickfix + signs
- ✓ Hints still use signs + virtual_text
- ✓ Progress still uses direct echo
- ✓ Debug stream still uses split window
- ✓ Errors still use direct echo

---

## Implementation Checklist

### Display Module Extensions
- [ ] Add `notify()` function
- [ ] Add `error()` function
- [ ] Add `details()` function
- [ ] Add `safe_result()` function
- [ ] Add `get_mode()` helper function
- [ ] Test all new functions

### Configuration Extensions
- [ ] Add 5 feature-specific display mode configs (compiler, signatures, progress, debug, error)
- [ ] Add notification config options
- [ ] Add error display config options
- [ ] **Note:** `hints_display` is independent and unchanged
- [ ] Update validation logic
- [ ] Test config initialization
- [ ] Test config validation

### Testing
- [ ] Test display mode resolution (global + override)
- [ ] Test fallback to global mode when override empty
- [ ] Test validation of invalid modes
- [ ] Test notification display
- [ ] Test error display
- [ ] Test details display
- [ ] Test safe result wrapper
- [ ] Test backward compatibility

---

## Configuration Examples

### Default Configuration (No Changes)
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'compiler_display_mode': '',  " inherit from global
  \ 'hints_display_mode': '',     " inherit from global
  \ 'signatures_display_mode': '',
  \ 'progress_display_mode': '',
  \ 'debug_display_mode': '',
  \ 'error_display_mode': '',
  \ 'notify_enabled': 1,
  \ 'notify_duration': 3000,
  \ 'error_show_details': 1,
  \ }
```

### Custom Configuration (Feature-Specific Overrides)
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'compiler_display_mode': 'popup',    " override: use popup for compiler
  \ 'hints_display_mode': 'split',       " override: use split for hints
  \ 'signatures_display_mode': 'popup',  " override: use popup for signatures
  \ 'progress_display_mode': 'echo',     " override: use echo for progress
  \ 'debug_display_mode': 'split',       " override: use split for debug
  \ 'error_display_mode': 'popup',       " override: use popup for errors
  \ }
```

---

## Code Changes Summary

### Files Modified
1. `autoload/genero_tools/display.vim` - Add 5 new functions
2. `autoload/genero_tools/config.vim` - Add 9 new config options + validation

### Lines of Code
- New functions: ~150 lines
- New config options: ~50 lines
- New validation: ~30 lines
- **Total: ~230 lines**

### Backward Compatibility
- ✓ 100% backward compatible
- ✓ No breaking changes
- ✓ All existing code continues to work
- ✓ New functions are additions only

---

## Testing Strategy

### Unit Tests
```vim
" Test display mode resolution
assert_equal('quickfix', genero_tools#display#get_mode('compiler'))
assert_equal('popup', genero_tools#display#get_mode('hints'))  " if override set

" Test notification display
call genero_tools#display#notify('Test message', 3000)

" Test error display
call genero_tools#display#error('Test error', 'echo')

" Test details display
call genero_tools#display#details('Title', ['line1', 'line2'], 'popup')

" Test safe result
call genero_tools#display#safe_result({'success': 1, 'data': []}, 'quickfix')
```

### Integration Tests
- Test with different display modes
- Test with feature-specific overrides
- Test fallback behavior
- Test configuration validation
- Test backward compatibility

### Manual Tests
- Visual inspection of notifications
- Visual inspection of error display
- Visual inspection of details display
- Test in Vim and Neovim
- Test with different terminal sizes

---

## Success Criteria

- ✓ All new functions work correctly
- ✓ Display mode resolution works (global + override)
- ✓ Configuration validation works
- ✓ Backward compatibility maintained
- ✓ No breaking changes
- ✓ All tests pass
- ✓ Code is well-documented

---

## Next Steps After Phase 1

Once Phase 1 is complete:

1. **Phase 2:** Update Compiler to use new functions
2. **Phase 3:** Update Hints to use new functions
3. **Phase 4:** Update Signatures to use new functions
4. **Phase 5:** Update Progress to use new functions
5. **Phase 6:** Update Debug Stream to use new functions
6. **Phase 7:** Update Error handling to use new functions

Each phase builds on Phase 1 foundation.

---

## Important Notes

### In-Editor Display Independence
- Signs in column are **NOT affected** by display_mode
- **Hints display (signs/virtual_text/both) is NOT affected** by display_mode (controlled by `hints_display` config)
- Highlighting is **NOT affected** by display_mode
- Virtual text is **NOT affected** by display_mode
- These are controlled by feature-specific configs
- They are always shown if enabled

### Configuration Inheritance
- Feature-specific overrides are **optional**
- Empty string means inherit from global
- Makes configuration simple and flexible
- Users only need to set what they want to override

### Backward Compatibility
- All existing code continues to work
- All existing configs continue to work
- New functions are additions only
- No deprecations in Phase 1

---

## Estimated Timeline

| Task | Duration |
|------|----------|
| Implement display functions | 4-6 hours |
| Implement config options | 2-3 hours |
| Implement validation | 1-2 hours |
| Unit testing | 2-3 hours |
| Integration testing | 2-3 hours |
| Manual testing | 2-3 hours |
| Documentation | 1-2 hours |
| **Total** | **14-22 hours (1-2 days)** |

---

## Deliverables

1. ✓ Extended display module with 5 new functions
2. ✓ Extended configuration with 9 new options
3. ✓ Updated validation logic
4. ✓ Comprehensive tests
5. ✓ Updated documentation
6. ✓ Code ready for Phase 2

---

## Questions?

Refer to:
- **DISPLAY_CONSISTENCY_AUDIT.md** - For understanding current issues
- **DISPLAY_CONSISTENCY_IMPLEMENTATION_PLAN.md** - For full implementation details
- **DISPLAY_ARCHITECTURE_COMPARISON.md** - For architectural overview

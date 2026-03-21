# Phase 4: Signatures Integration - Overview

## Scope

Add display mode support to function signatures, enabling them to be displayed in different modes (popup, split, echo, inline) instead of just in the completion menu.

---

## Current State

### What Exists
- ✓ Signature formatting module (`autoload/genero_tools/signature.vim`)
- ✓ Signature formatting functions (format, truncate, abbreviate)
- ✓ Signature info display functions
- ✓ Configuration option `signatures_display_mode` (initialized in Phase 1)

### What's Missing
- ✗ Display mode support for signature results
- ✗ Integration with display module
- ✗ Support for all display modes (popup, split, echo, inline)

---

## What Phase 4 Will Do

### 1. Add Display Mode Support
- Use `display#get_mode('signatures')` to determine display mode
- Respect `signatures_display_mode` override if set
- Fall back to global `display_mode` if override is empty

### 2. Create Display Functions
- `show_signature()` - Display single signature
- `show_signatures()` - Display list of signatures
- Route to appropriate display mode

### 3. Update Signature Display
- Replace direct echo/popup calls with display module
- Support all display modes
- Maintain backward compatibility

---

## Files to Modify

### 1. autoload/genero_tools/signature.vim
- Add `show_signature()` function
- Add `show_signatures()` function
- Update existing display functions to use display module

### 2. autoload/genero_tools/config.vim
- Verify `signatures_display_mode` is properly initialized (already done in Phase 1)

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

## Configuration

### Feature-Specific Override
```vim
let g:genero_tools_config.signatures_display_mode = 'popup'
```

### Inherit from Global
```vim
let g:genero_tools_config.signatures_display_mode = ''
```

### Examples

**Default (Quickfix):**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'signatures_display_mode': '',
  \ }
```

**Popup Display:**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'signatures_display_mode': 'popup',
  \ }
```

**Global Popup:**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'popup',
  \ 'signatures_display_mode': '',
  \ }
```

---

## Implementation Plan

### Step 1: Add Display Functions
- Create `show_signature()` function
- Create `show_signatures()` function
- Use `display#get_mode('signatures')`
- Route to appropriate display mode

### Step 2: Update Existing Functions
- Update signature display calls
- Replace direct echo/popup with display module
- Maintain backward compatibility

### Step 3: Testing
- Test all display modes
- Test feature-specific overrides
- Test backward compatibility

---

## Success Criteria

- ✓ Signatures respect `display_mode` config
- ✓ Signatures respect `signatures_display_mode` override
- ✓ All display modes work (quickfix, popup, inline, split, echo)
- ✓ Backward compatible
- ✓ No syntax errors
- ✓ All tests pass

---

## Estimated Effort

**1 day** (6-8 hours)
- Add display functions: 2-3 hours
- Update existing functions: 1-2 hours
- Testing: 2-3 hours

---

## What Stays the Same

- ✓ Signature formatting logic
- ✓ Type abbreviation
- ✓ Parameter/return formatting
- ✓ All existing configuration options

---

## Next After Phase 4

Once Phase 4 is complete, Phase 5 (Progress & Status) can proceed with similar updates to the progress/status display module.

---

## Summary

Phase 4 will add display mode support to function signatures, enabling them to be displayed in different modes while maintaining backward compatibility and respecting the global `display_mode` configuration.


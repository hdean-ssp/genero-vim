# Phase 4: Signatures Integration - Quick Reference

## What Phase 4 Does

Adds display mode support to function signatures, enabling them to be displayed in popup, split, echo, or inline modes instead of just in the completion menu.

---

## Current State

✓ Signature formatting module exists
✓ Configuration option exists
✗ Display mode support missing
✗ Integration with display module missing

---

## What Will Be Added

### New Functions
- `show_signature()` - Display single signature
- `show_signatures()` - Display list of signatures

### Display Mode Support
- Use `display#get_mode('signatures')`
- Support all display modes
- Respect feature-specific override

---

## Configuration

### Feature-Specific Override
```vim
let g:genero_tools_config.signatures_display_mode = 'popup'
```

### Examples

**Default:**
```vim
let g:genero_tools_config.signatures_display_mode = ''
```

**Popup:**
```vim
let g:genero_tools_config.signatures_display_mode = 'popup'
```

**Split:**
```vim
let g:genero_tools_config.signatures_display_mode = 'split'
```

---

## Display Modes

| Mode | Vim | Neovim |
|------|-----|--------|
| quickfix | ✓ | ✓ |
| popup | Echo | ✓ |
| split | ✓ | ✓ |
| echo | ✓ | ✓ |
| inline | Echo | ✓ |

---

## Files to Modify

1. **autoload/genero_tools/signature.vim**
   - Add display functions
   - Update existing functions

---

## Success Criteria

✓ Signatures respect `display_mode`
✓ Signatures respect `signatures_display_mode` override
✓ All display modes work
✓ Backward compatible
✓ No syntax errors

---

## Estimated Effort

**1 day** (6-8 hours)

---

## Summary

Phase 4 adds display mode support to signatures, enabling flexible display options while maintaining backward compatibility.


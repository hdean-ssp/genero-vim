# Display Architecture Clarification

## Current Status: ✓ CORRECT IMPLEMENTATION

Based on user feedback and review of the implementation, the display architecture is **correctly designed** with proper separation of concerns.

---

## Key Principle: Two Independent Display Systems

### 1. In-Editor Display (Independent of display_mode)
These are **always shown in the editor** if enabled, regardless of `display_mode` setting:

| Feature | Config | Display Method | Always Shown? | Affected by display_mode? |
|---------|--------|-----------------|---------------|--------------------------|
| **Compiler Errors/Warnings** | `compiler_sign_column` | Sign column | ✓ Yes (if enabled) | ✗ No |
| **Hints** | `hints_display` | Signs/Virtual Text | ✓ Yes (if enabled) | ✗ No |
| **SVN Markers** | `svn_show_added/modified/deleted` | Sign column | ✓ Yes (if enabled) | ✗ No |
| **Syntax Highlighting** | `compiler_highlight_unused` | Inline highlighting | ✓ Yes (if enabled) | ✗ No |

**Important:** These are controlled by **feature-specific configs**, not by `display_mode`.

### 2. Result/Detail Display (Respects display_mode)
These display detailed information and **respect the `display_mode` setting**:

| Feature | Config | Display Modes | Affected by display_mode? |
|---------|--------|---------------|--------------------------|
| **Compiler Results** | `compiler_display_mode` | quickfix, popup, split, echo, inline | ✓ Yes |
| **Search Results** | `display_mode` | quickfix, popup, split, echo, inline | ✓ Yes |
| **Signatures** | `signatures_display_mode` | quickfix, popup, split, echo, inline | ✓ Yes |
| **Progress/Status** | `progress_display_mode` | echo, popup, inline | ✓ Yes |
| **Errors** | `error_display_mode` | popup, split, echo, inline | ✓ Yes |

**Important:** These use `display_mode` or feature-specific overrides to determine how to display results.

---

## Hints Display: Detailed Explanation

### Current Implementation (Correct)

**Hints have TWO separate display aspects:**

#### 1. In-Editor Display (Independent)
```vim
hints_display: 'signs'        " or 'virtual_text' or 'both'
```
- **Always shown** in the editor if enabled
- **Not affected** by `display_mode`
- Controlled by `hints_display` config only
- Shows hints directly in the code editor

#### 2. Hints Results Display (Respects display_mode)
```vim
hints_display_mode: ''        " empty = inherit from global display_mode
```
- Used when displaying **list of hints** (e.g., from a search/query)
- **Respects** `display_mode` setting
- Can be overridden with feature-specific config
- Shows hints in quickfix, popup, split, or echo

### Example Configuration

```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',           " Global default for results
  \ 'hints_display': 'both',              " In-editor: signs + virtual text
  \ 'hints_display_mode': '',             " Results: inherit from global (quickfix)
  \ 'compiler_sign_column': 1,            " Always show compiler signs
  \ 'compiler_highlight_unused': 1,       " Always show highlighting
  \ }
```

**Result:**
- ✓ Hints shown as signs AND virtual text in the editor (always)
- ✓ Hints results displayed in quickfix (from global display_mode)
- ✓ Compiler signs shown in column (always)
- ✓ Unused variables highlighted (always)

---

## Display Mode Options

### Available Display Modes

1. **quickfix** - Vim quickfix list (default)
   - Best for: Lists of results, errors, warnings
   - Vim: ✓ Supported
   - Neovim: ✓ Supported

2. **popup** - Floating window (Neovim only)
   - Best for: Detailed information, signatures
   - Vim: Falls back to echo
   - Neovim: ✓ Supported with configurable position

3. **inline** - Small popup by cursor
   - Best for: Quick previews, hints
   - Vim: ✓ Supported (echo-based)
   - Neovim: ✓ Supported (floating window)

4. **split** - Split window
   - Best for: Detailed browsing, debug output
   - Vim: ✓ Supported
   - Neovim: ✓ Supported

5. **echo** - Command line echo
   - Best for: Status messages, progress
   - Vim: ✓ Supported
   - Neovim: ✓ Supported

---

## Configuration Structure

### Global Configuration
```vim
display_mode: 'quickfix'                 " Default for all result displays
floating_window_position: 'center'       " Popup position (center, top, bottom, cursor)
floating_window_width: 80                " Popup width
floating_window_height: 20               " Popup height
floating_window_border: 'rounded'        " Border style
popup_auto_close_delay: 5000             " Auto-close timer (ms)
```

### Feature-Specific Display Mode Overrides
```vim
compiler_display_mode: ''                " empty = inherit from global
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
```

### Notification/Status Display
```vim
notify_enabled: 1                        " Enable notifications
notify_duration: 3000                    " Auto-dismiss timer (ms)
error_show_details: 1                    " Show error details
```

---

## Implementation Details

### Phase 1: Core Infrastructure (✓ COMPLETE)

**Files Modified:**
- `autoload/genero_tools/display.vim` - Added 8 new functions
- `autoload/genero_tools/config.vim` - Added 8 new config options

**New Functions:**
- `display#get_mode(feature)` - Resolve display mode with overrides
- `display#notify(message, duration)` - Status messages
- `display#error(message, display_mode)` - Error display
- `display#details(title, content, display_mode)` - Detailed info
- `display#safe_result(result, display_mode)` - Safe display wrapper

**New Config Options:**
- Feature-specific display mode overrides (5 options)
- Notification display options (2 options)
- Error display options (1 option)

### Phase 2: Compiler Integration (NEXT)

**Files to Modify:**
- `autoload/genero_tools/compiler/quickfix.vim` - Use display module
- `autoload/genero_tools/compiler/autocompile.vim` - Use notify function
- `autoload/genero_tools/compiler/signs.vim` - Verify independence

**Changes:**
- Update `populate()` to use `display#get_mode('compiler')`
- Update progress to use `display#notify()`
- Verify signs remain independent

### Phase 3: Hints Integration (AFTER PHASE 2)

**Files to Modify:**
- `autoload/genero_tools/hints/display.vim` - Add display mode support
- `autoload/genero_tools/hints/config.vim` - Add display mode config

**Changes:**
- Keep `hints_display` for in-editor display (signs/virtual_text)
- Add `hints_display_mode` for results display
- Ensure signs/virtual text always shown if enabled

---

## User Configuration Examples

### Example 1: Default Configuration
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'hints_display': 'signs',
  \ }
```
**Result:**
- All results in quickfix
- Hints shown as signs in editor

### Example 2: Popup-Focused Configuration
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'popup',
  \ 'floating_window_position': 'top',
  \ 'hints_display': 'both',
  \ }
```
**Result:**
- All results in popup at top
- Hints shown as signs AND virtual text in editor

### Example 3: Feature-Specific Overrides
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'compiler_display_mode': 'popup',
  \ 'signatures_display_mode': 'popup',
  \ 'progress_display_mode': 'echo',
  \ 'hints_display': 'both',
  \ }
```
**Result:**
- Compiler results in popup
- Signatures in popup
- Progress in echo
- Hints shown as signs AND virtual text in editor
- Everything else in quickfix

### Example 4: Vim-Only Configuration
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'split',
  \ 'hints_display': 'signs',
  \ }
```
**Result:**
- All results in split window
- Hints shown as signs in editor
- No floating windows (Vim doesn't support them)

---

## Key Design Principles

### 1. Separation of Concerns
- **In-editor display** (signs, highlighting, virtual text) is independent
- **Result display** (quickfix, popup, split, echo) respects display_mode
- Each has its own configuration

### 2. Backward Compatibility
- All existing configs still work
- Default behavior unchanged
- New options are optional

### 3. Feature Independence
- Signs always shown if enabled (not affected by display_mode)
- Highlighting always shown if enabled (not affected by display_mode)
- Virtual text always shown if enabled (not affected by display_mode)

### 4. Consistent Patterns
- All features use `display#get_mode(feature)` to resolve display mode
- All features can have feature-specific overrides
- All features fall back to global `display_mode` if not overridden

---

## What's NOT Affected by display_mode

These are **always shown** if their respective configs are enabled:

1. **Compiler signs** - Controlled by `compiler_sign_column`
2. **Compiler highlighting** - Controlled by `compiler_highlight_unused`
3. **Hints signs** - Controlled by `hints_display` (when set to 'signs' or 'both')
4. **Hints virtual text** - Controlled by `hints_display` (when set to 'virtual_text' or 'both')
5. **SVN markers** - Controlled by `svn_show_added/modified/deleted`
6. **Syntax highlighting** - Controlled by language-specific configs

---

## What IS Affected by display_mode

These **respect** the `display_mode` setting (or feature-specific override):

1. **Compiler results** - List of errors/warnings
2. **Search results** - List of matches
3. **Signature information** - Function signatures
4. **Progress messages** - Status updates
5. **Error messages** - Error details
6. **Hints results** - List of hints (when displayed as results)

---

## Summary

The current implementation is **correct and well-designed**:

✓ **In-editor display** (signs, virtual text, highlighting) is independent of `display_mode`
✓ **Result display** (quickfix, popup, split, echo) respects `display_mode`
✓ **Hints display** has two aspects: in-editor (independent) and results (respects display_mode)
✓ **Signs remain independent** and always shown if enabled
✓ **Configuration is clear** and follows consistent patterns
✓ **Backward compatible** with existing configurations

---

## Next Steps

1. **Phase 2:** Implement compiler integration
2. **Phase 3:** Implement hints integration
3. **Phase 4:** Implement signatures integration
4. **Phase 5:** Implement progress integration
5. **Phase 6:** Implement error display integration
6. **Phase 7:** Comprehensive testing and documentation

---

## Files Reference

### Core Infrastructure (Phase 1 - Complete)
- `autoload/genero_tools/display.vim` - Main display module
- `autoload/genero_tools/config.vim` - Configuration management

### Feature Modules (To be updated)
- `autoload/genero_tools/compiler/quickfix.vim` - Compiler results
- `autoload/genero_tools/compiler/autocompile.vim` - Progress display
- `autoload/genero_tools/hints/display.vim` - Hints display
- `autoload/genero_tools/hints/config.vim` - Hints configuration

---

## Questions & Clarifications

**Q: Why are hints_display and hints_display_mode separate?**
A: Because hints have two independent display aspects:
- `hints_display` controls in-editor display (signs/virtual_text) - always shown if enabled
- `hints_display_mode` controls results display (quickfix/popup/etc) - respects display_mode

**Q: Why don't signs respect display_mode?**
A: Signs are in-editor indicators that should always be visible if enabled. They're not "results" that need to be displayed in different modes.

**Q: Can I disable signs but keep virtual text?**
A: Yes! Set `hints_display: 'virtual_text'` to show only virtual text, or `hints_display: 'signs'` to show only signs.

**Q: What if I want different display modes for different features?**
A: Use feature-specific overrides:
```vim
compiler_display_mode: 'popup'
signatures_display_mode: 'split'
progress_display_mode: 'echo'
```

---

## Conclusion

The display architecture is correctly implemented with proper separation between:
1. **In-editor display** (independent, always shown if enabled)
2. **Result display** (respects display_mode)

This design provides flexibility, consistency, and backward compatibility while maintaining clear separation of concerns.


# Display Implementation Consistency Audit

## Executive Summary

The plugin has **multiple display systems** across different features with **inconsistent implementation patterns**. Configuration options exist but are not uniformly applied across all features.

**Key Findings:**
- ✓ Core display modes are well-implemented (quickfix, popup, inline, split, echo)
- ✗ Features use different display patterns (some use display modes, others use custom implementations)
- ✗ Configuration options not consistently applied across all features
- ✗ Some features bypass the main display dispatcher
- ✗ Inconsistent error/status message display

---

## Display System Architecture

### Tier 1: Core Display Module
**File:** `autoload/genero_tools/display.vim`

**Main Dispatcher:** `genero_tools#display#result(result, display_mode)`
- Routes to appropriate display mode
- Validates display mode compatibility
- Handles result formatting

**Supported Modes:**
- `quickfix` - Vim quickfix list
- `popup` - Neovim floating window
- `inline` - Compact popup by cursor
- `split` - New split window
- `echo` - Command line output

**Configuration:**
- `display_mode` - Primary mode selection
- `floating_window_*` - Popup window options
- `popup_auto_close_delay` - Auto-close timer

### Tier 2: In-Editor Display (Independent of Display Mode)
**Files:** `autoload/genero_tools/compiler/signs.vim`, `autoload/genero_tools/hints/display.vim`, `autoload/genero_tools/svn/signs.vim`

**Display Methods:**
- Sign column indicators (errors, warnings, hints, SVN markers)
- Syntax highlighting (error/warning backgrounds)
- Virtual text (Neovim only, end-of-line annotations)

**Important:** These are **always shown if enabled**, regardless of `display_mode` setting. They are controlled by feature-specific configuration:
- `compiler_sign_column` - Show compiler signs
- `compiler_highlight_unused` - Highlight unused variables
- `hints_display` - Show hints as signs/virtual_text
- `svn_show_added/modified/deleted` - Show SVN markers

**Configuration:**
- Feature-specific enable/disable options
- Independent of `display_mode`
- Always active if enabled

---

## Feature-Specific Display Implementations

### 1. Compiler Integration ⚠️ INCONSISTENT

**Display Methods Used:**
- Quickfix list (via `genero_tools#compiler#quickfix#populate()`) - Result display
- Sign column (via `genero_tools#compiler#signs#place()`) - **Always shown if enabled**
- Syntax highlighting (via `genero_tools#compiler#highlight#apply()`) - **Always shown if enabled**
- Direct echo messages (progress, elapsed time)

**Configuration:**
- `compiler_show_errors` - Show/hide errors
- `compiler_show_warnings` - Show/hide warnings
- `compiler_highlight_unused` - Highlight unused variables
- `compiler_sign_column` - Enable sign column (independent of display_mode)
- `compiler_sign_column_always_visible` - Keep column visible (independent of display_mode)

**Important:** Signs and highlighting in the column are **independent of display_mode**. They are always shown if enabled, regardless of how results are displayed.

**Issues:**
- ✗ Does NOT use main `display_mode` config for result display
- ✗ Hardcoded to use quickfix + signs + highlighting
- ✗ No option to use popup or split mode for results
- ✗ Progress messages use direct `echom` instead of display module

**Expected Behavior:**
- Signs/highlighting in column: Always shown if enabled (independent of display_mode)
- Result display: Should respect `display_mode` config
- Should allow popup/split display of compilation results
- Should use display module for all output

---

### 2. Code Hints ✓ CORRECT

**Display Methods Used:**
- Sign column (via `genero_tools#hints#display#show_signs()`) - **Always shown if enabled**
- Virtual text (via `genero_tools#hints#display#show_virtual_text()`) - **Always shown if enabled**

**Configuration:**
- `hints_display` - Mode: 'signs', 'virtual_text', or 'both' (in-editor display, independent of display_mode)
- `hints_highlight_columns` - Highlight hint columns
- `hints_severity` - Minimum severity level

**Important:** Hints display (signs/virtual_text/both) is **independent of display_mode**. The `hints_display` config controls how hints are shown in the editor and is not affected by `display_mode` setting.

**Status:** ✓ Correct as-is
- Signs and virtual text are controlled by `hints_display` config
- Always shown if enabled, regardless of display_mode
- No changes needed
- `hints_severity` - Minimum severity level

**Important:** Hints display (signs/virtual_text/both) is **independent of display_mode**. The `hints_display` config controls how hints are shown in the editor and is not affected by `display_mode` setting.

**Status:** ✓ Correct as-is
- Signs and virtual text are controlled by `hints_display` config
- Always shown if enabled, regardless of display_mode
- No changes needed

---

### 3. Function Signatures ⚠️ INCONSISTENT

**Display Methods Used:**
- Completion menu (via omnifunc)
- Preview window (via `completeopt`)
- Direct formatting (via `genero_tools#signature#format()`)

**Configuration:**
- None specific to display mode

**Issues:**
- ✗ No display mode configuration
- ✗ Hardcoded to use completion menu + preview window
- ✗ No option to display signatures in popup/split/quickfix
- ✗ Doesn't use main display module

**Expected Behavior:**
- Should support display modes for signature lookup
- Should have configuration for signature display preferences

---

### 4. Autocomplete ⚓ CORRECT

**Display Methods Used:**
- Omnifunc completion menu (standard Vim behavior)
- Preview window (via `completeopt`)

**Configuration:**
- `autocomplete_on_pause` - Enable pause-based autocomplete
- `autocomplete_delay` - Delay before triggering

**Status:**
- ✓ Uses standard Vim completion mechanism
- ✓ Appropriate for autocomplete use case
- ✓ No changes needed

---

### 5. SVN Diff Markers ⚓ CORRECT

**Display Methods Used:**
- Sign column (via `genero_tools#svn#signs#place()`)

**Configuration:**
- `svn_show_added` - Show added markers
- `svn_show_modified` - Show modified markers
- `svn_show_deleted` - Show deleted markers

**Status:**
- ✓ Uses appropriate display method (signs)
- ✓ Has configuration options
- ✓ No changes needed

---

### 6. Progress Feedback ⚠️ INCONSISTENT

**Display Methods Used:**
- Direct `echom` messages
- Elapsed time display

**Configuration:**
- None

**Issues:**
- ✗ Uses direct echo instead of display module
- ✗ No configuration for progress display
- ✗ Hardcoded message format

**Expected Behavior:**
- Should use display module for consistency
- Should have configuration options

---

### 7. Debug Streaming ⚠️ INCONSISTENT

**Display Methods Used:**
- Split window (hardcoded)
- File selector UI (custom)

**Configuration:**
- `debug_stream_width` - Window width
- `debug_stream_max_lines` - Max lines to display
- `debug_stream_auto_scroll` - Auto-scroll behavior

**Issues:**
- ✗ Hardcoded to split window only
- ✗ No option to use popup or other modes
- ✗ Custom UI instead of using display module

**Expected Behavior:**
- Should support multiple display modes
- Should use display module for consistency

---

## Configuration Consistency Analysis

### Display Mode Configuration

**Current State:**
```vim
display_mode: 'quickfix'  (main config)
hints_display: 'signs'    (hints-specific override)
```

**Issues:**
- ✗ Compiler doesn't respect `display_mode`
- ✗ Hints use separate `hints_display` config
- ✗ Signatures have no display config
- ✗ Progress has no display config
- ✗ Debug stream hardcoded to split

**Recommended Approach:**
```vim
display_mode: 'quickfix'  (global default)

" Feature-specific overrides (optional)
compiler_display_mode: 'quickfix'  (or inherit from global)
hints_display_mode: 'signs'        (or inherit from global)
signatures_display_mode: 'popup'   (or inherit from global)
progress_display_mode: 'echo'      (or inherit from global)
debug_display_mode: 'split'        (or inherit from global)
```

---

## Floating Window Configuration

**Current Options:**
- `floating_window_border` - Border style
- `floating_window_width` - Width
- `floating_window_height` - Height
- `floating_window_position` - Position
- `floating_window_title` - Title
- `popup_auto_close_delay` - Auto-close timer

**Issues:**
- ✗ Only used by main display module
- ✗ Not available to hints, signatures, debug stream
- ✗ Position validation allows 'left'/'right' but not implemented

**Recommended:**
- Make floating window config global and reusable
- Implement missing position options or remove from validation

---

## Display Function Consistency

### Pattern 1: Using Main Display Dispatcher ✓
**Example:** Main display module
```vim
call genero_tools#display#result(result, display_mode)
```
**Status:** Correct pattern

### Pattern 2: Custom Display Implementation ⚠️
**Example:** Hints, Compiler, Debug Stream
```vim
call genero_tools#hints#display#show(bufnr, hints)
call genero_tools#compiler#signs#place(errors, warnings)
call genero_tools#debug_stream#start(file_path)
```
**Issues:**
- Bypasses main display dispatcher
- Doesn't respect global `display_mode` config
- Inconsistent with other features

### Pattern 3: Direct Echo ⚠️
**Example:** Progress, Error messages
```vim
echom 'message'
call genero_tools#error#warn('module', 'message')
```
**Issues:**
- Doesn't use display module
- No configuration options
- Inconsistent formatting

---

## Recommended Standardization

### Option A: Unified Display Dispatcher (Recommended)

All features should use the main display module for **result display**, while maintaining independent sign column display:

```vim
" For search results, function info, etc. (uses display_mode)
call genero_tools#display#result(result, display_mode)

" For status/progress messages (uses display_mode)
call genero_tools#display#notify(message, duration)

" For errors (uses display_mode)
call genero_tools#error#display(error_message, display_mode)

" For in-editor signs/highlighting (independent of display_mode)
call genero_tools#compiler#signs#place(errors, warnings)  " Always shown if enabled
call genero_tools#hints#display#show_signs(bufnr, hints)  " Always shown if enabled
```

**Benefits:**
- Consistent behavior for result display across all features
- Respects global `display_mode` config for results
- Signs/highlighting in column remain unaffected
- Easier to maintain and extend
- Better user experience

### Option B: Feature-Specific Display Modes

Keep custom implementations but standardize configuration:

```vim
" Global default
display_mode: 'quickfix'

" Feature-specific overrides (for result display only)
compiler_display_mode: 'quickfix'
hints_display_mode: 'signs'  " This controls in-editor display, not result display
signatures_display_mode: 'popup'
progress_display_mode: 'echo'
debug_display_mode: 'split'

" In-editor display (independent of display_mode)
compiler_sign_column: 1       " Always shown if enabled
hints_display: 'signs'        " Always shown if enabled
svn_show_added: 1             " Always shown if enabled
```

**Benefits:**
- Allows feature-specific optimization
- Still provides consistency
- Easier to implement incrementally

**Drawbacks:**
- More configuration options
- Potential for confusion

---

## Implementation Gaps

### 1. No Unified Error Display
**Issue:** Errors displayed via:
- `genero_tools#error#warn()` - Direct echo
- `genero_tools#error#log()` - Debug stream
- Direct `echom` - Progress messages

**Solution:** Create `genero_tools#error#display()` that respects display mode

### 2. No Unified Status/Progress Display
**Issue:** Progress shown via direct `echom`

**Solution:** Create `genero_tools#display#notify()` for status messages

### 3. No Unified Popup Details Display
**Issue:** Hints details use custom popup, signatures don't have details

**Solution:** Create `genero_tools#display#details()` for detailed information

### 4. Inconsistent Configuration Validation
**Issue:** Some features validate config, others don't

**Solution:** Centralize validation in config module

### 5. No Display Mode Fallback Strategy
**Issue:** Some features don't handle unsupported modes

**Solution:** Use `genero_tools#compat#validate_display_mode()` everywhere

---

## Audit Checklist

### Compiler Integration
- [ ] Respect global `display_mode` config
- [ ] Support all display modes (quickfix, popup, inline, split, echo)
- [ ] Use main display dispatcher for results
- [ ] Use display module for progress messages
- [ ] Validate display mode compatibility

### Code Hints
- [ ] Support all display modes (not just signs/virtual_text)
- [ ] Respect global `display_mode` config (with hints-specific override)
- [ ] Use main display dispatcher for hint details
- [ ] Consistent sign column behavior

### Function Signatures
- [ ] Add display mode configuration
- [ ] Support display modes for signature lookup
- [ ] Use main display dispatcher for results
- [ ] Consistent formatting across all display modes

### Progress Feedback
- [ ] Use display module instead of direct echo
- [ ] Add progress display configuration
- [ ] Support multiple display modes

### Debug Streaming
- [ ] Support multiple display modes (not just split)
- [ ] Use display module for consistency
- [ ] Respect display configuration

### Error Display
- [ ] Unified error display function
- [ ] Respect display mode configuration
- [ ] Consistent error formatting

---

## Priority Recommendations

### High Priority (Consistency)
1. Compiler: Respect `display_mode` config
2. Hints: Support all display modes
3. Create unified error display function
4. Create unified progress display function

### Medium Priority (Completeness)
5. Signatures: Add display mode support
6. Debug stream: Support multiple display modes
7. Standardize configuration validation

### Low Priority (Enhancement)
8. Add feature-specific display mode overrides
9. Improve floating window positioning
10. Add display mode documentation

---

## Files Requiring Changes

### Core Display Module
- `autoload/genero_tools/display.vim` - Add notify/error functions
- `autoload/genero_tools/config.vim` - Add feature-specific display configs

### Feature Modules
- `autoload/genero_tools/compiler/quickfix.vim` - Use display module
- `autoload/genero_tools/compiler/signs.vim` - Respect display config
- `autoload/genero_tools/hints/display.vim` - Support all modes
- `autoload/genero_tools/signature.vim` - Add display mode support
- `autoload/genero_tools/progress.vim` - Use display module
- `autoload/genero_tools/debug_stream.vim` - Support multiple modes
- `autoload/genero_tools/error.vim` - Unified error display

### Configuration
- `autoload/genero_tools/config.vim` - Add feature-specific configs
- `autoload/genero_tools/compat.vim` - Ensure validation everywhere

---

## Next Steps

1. **Review** this audit with team
2. **Decide** between Option A (unified) or Option B (feature-specific)
3. **Prioritize** which features to standardize first
4. **Implement** changes incrementally
5. **Test** display consistency across all features
6. **Document** display configuration and usage

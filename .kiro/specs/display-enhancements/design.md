# Display Enhancements - Design

## Architecture Overview

The display enhancements implement a unified display architecture across the Genero-Tools plugin with clear separation between in-editor display elements and result display modes.

---

## Core Design Principles

### 1. Separation of Concerns

**In-Editor Display (Independent)**
- Signs (compiler errors, hints, SVN markers)
- Virtual text (hints, inline diagnostics)
- Syntax highlighting
- Debug streaming (split window)

These are ALWAYS shown if enabled, NOT affected by global `display_mode`.

**Result Display (Mode-Dependent)**
- Quickfix list
- Floating windows (popup)
- Split windows (for results)
- Echo/command-line display
- Inline popups

These respect the global `display_mode` setting and feature-specific overrides.

### 2. Configuration Hierarchy

```
Global display_mode (default: 'quickfix')
    ↓
Feature-specific override (e.g., compiler_display_mode)
    ↓
Resolved display mode for feature
```

If feature-specific override is empty, use global display_mode.

### 3. Backward Compatibility

- All existing configurations continue to work
- Default behavior unchanged
- No breaking changes to APIs
- New functions are additive only

---

## Module Architecture

### display.vim - Core Display Functions

**Public Functions:**
- `display#get_mode(feature)` - Resolve display mode for feature
- `display#notify(message, duration)` - Show notification
- `display#error(message, details)` - Show error
- `display#details(content, title)` - Show detailed content
- `display#safe_result(content, mode)` - Display result safely

**Internal Functions:**
- `s:show_quickfix(items)` - Quickfix display
- `s:show_popup(content, opts)` - Floating window display
- `s:show_split(content, opts)` - Split window display
- `s:show_echo(content)` - Echo display
- `s:show_inline(content, opts)` - Inline popup display

### config.vim - Configuration Management

**Configuration Categories:**

1. **Global Display Settings**
   - `display_mode` - Default result display mode
   - `floating_window_*` - Popup window options
   - `popup_auto_close_delay` - Auto-close timer

2. **Feature-Specific Overrides**
   - `compiler_display_mode`
   - `hints_display_mode`
   - `signatures_display_mode`
   - `progress_display_mode`
   - `debug_display_mode`
   - `error_display_mode`

3. **In-Editor Display (Independent)**
   - `compiler_sign_column`
   - `compiler_highlight_unused`
   - `hints_display`
   - `svn_show_*`
   - `debug_stream_*`

4. **Notification Settings**
   - `notify_enabled`
   - `notify_duration`
   - `error_show_details`

### Feature Integration Points

**compiler/quickfix.vim**
- Uses `display#get_mode('compiler')` to resolve mode
- Routes to appropriate display function
- Signs remain independent

**compiler/autocompile.vim**
- Uses `display#notify()` for progress messages
- Respects `notify_enabled` config

**hints/display.vim**
- `hints_display` controls in-editor display (independent)
- `hints_display_mode` controls results display (mode-dependent)

**signature.vim**
- `show()` function for single signature
- `show_list()` function for multiple signatures
- Both use `display#get_mode('signatures')`

**debug_stream.vim**
- File selection UI uses standard display functions
- Debug files always open in split windows (independent)
- Split width configurable via `debug_stream_width`

---

## Display Mode Resolution

### Algorithm

```vim
function! display#get_mode(feature)
  " 1. Check feature-specific override
  let override_key = a:feature . '_display_mode'
  let override = config#get(override_key, '')
  
  if !empty(override)
    return override
  endif
  
  " 2. Fall back to global display_mode
  return config#get('display_mode', 'quickfix')
endfunction
```

### Example Flow

```
User calls: display#get_mode('compiler')

1. Check config: compiler_display_mode
   - If set (not empty) → return it
   - If empty → continue

2. Check config: display_mode
   - Return global setting (default: 'quickfix')

Result: Resolved display mode for compiler
```

---

## Display Mode Implementations

### Quickfix Mode
- Uses Vim's built-in quickfix list
- Works in Vim and Neovim
- Persistent until cleared
- Supports navigation with `:cnext`, `:cprev`

### Popup Mode
- Floating window (Neovim) / popup (Vim 8.2+)
- Configurable position, size, border
- Auto-close after delay
- Falls back to echo in unsupported environments

### Split Mode
- Vertical or horizontal split
- Configurable width/height
- Persistent until closed
- Good for detailed content

### Echo Mode
- Command-line display
- Works everywhere
- Temporary (cleared on next command)
- Good for simple messages

### Inline Mode
- Inline popup (Neovim only)
- Appears at cursor position
- Auto-close after delay
- Falls back to echo in unsupported environments

---

## Configuration Examples

### Basic Setup (Default)
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ }
```

### Popup-Preferred Setup
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'popup',
  \ 'floating_window_width': 100,
  \ 'floating_window_height': 30,
  \ 'popup_auto_close_delay': 5000,
  \ }
```

### Feature-Specific Overrides
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'compiler_display_mode': 'popup',
  \ 'hints_display_mode': 'split',
  \ 'signatures_display_mode': 'popup',
  \ }
```

### Debug Streaming Configuration
```vim
let g:genero_tools_config = {
  \ 'debug_stream_width': 60,
  \ 'debug_stream_max_lines': 2000,
  \ 'debug_stream_auto_scroll': 1,
  \ }
```

---

## Implementation Patterns

### Pattern 1: Simple Result Display
```vim
function! my_feature#show_result(content)
  let mode = display#get_mode('my_feature')
  call display#safe_result(a:content, mode)
endfunction
```

### Pattern 2: Error Display
```vim
function! my_feature#handle_error(error_msg, details)
  call display#error(a:error_msg, a:details)
endfunction
```

### Pattern 3: Notification
```vim
function! my_feature#notify_progress(message)
  call display#notify(a:message, 3000)
endfunction
```

### Pattern 4: Independent Display (Signs, Virtual Text)
```vim
function! my_feature#show_signs()
  " Always show if enabled, independent of display_mode
  if config#get('my_feature_signs', 1)
    " Show signs...
  endif
endfunction
```

---

## Phase 6 Implementation Details

### File Selection UI Update

**Current Implementation (Custom Floating Window)**
```vim
function! s:show_file_selector(file_names, file_paths)
  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)
  " Custom keybindings...
endfunction
```

**New Implementation (Standard Display Functions)**
```vim
function! s:show_file_selector(file_names, file_paths)
  " Format file list for display
  let content = s:format_file_list(a:file_names, a:file_paths)
  
  " Use standard display function
  call display#details(content, 'Debug Stream Files')
  
  " Handle selection via standard mechanisms
endfunction
```

### Split Width Configuration

**Configuration**
```vim
debug_stream_width: 0              " 0 = auto-calculate (1/3 of screen)
```

**Usage in start() Function**
```vim
let width = config#get('debug_stream_width', 0)
if width == 0
  let width = max([50, winwidth(0) / 3])
endif
execute 'rightbelow ' . width . 'vsplit'
```

### Debug Display (Unchanged)
```vim
" Always split, independent of display_mode
execute 'rightbelow ' . width . 'vsplit'
let buf = nvim_create_buf(0, 1)
call nvim_set_current_buf(buf)
" Stream content to buffer...
```

---

## Testing Strategy

### Unit Tests
- Display mode resolution
- Configuration hierarchy
- Feature-specific overrides

### Integration Tests
- Compiler with different display modes
- Hints with different display modes
- Signatures with different display modes
- Debug streaming file selection

### Compatibility Tests
- Vim vs Neovim
- Different display modes
- Fallback behavior

### Regression Tests
- Backward compatibility
- Existing configurations still work
- Default behavior unchanged

---

## Success Criteria

- ✓ All features respect `display_mode` config
- ✓ All features support feature-specific overrides
- ✓ All display modes work correctly
- ✓ In-editor display remains independent
- ✓ Debug streaming file selection uses standard functions
- ✓ Debug files always open in split windows
- ✓ Split width configuration works
- ✓ 100% backward compatible
- ✓ No syntax errors
- ✓ All tests pass

---

## Future Enhancements

### Phase 7: Error Display
- Update error handling to use `display#error()`
- Support all display modes for error messages
- Consistent error formatting

### Phase 8: Additional Features
- Progress display integration
- Status display integration
- Custom display modes


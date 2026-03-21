# Display Consistency Implementation Plan

## Overview

This plan standardizes display implementation across all features to ensure:
1. Consistent behavior for **result display** across the plugin
2. Configuration options are properly supported
3. All features respect user display preferences
4. **In-editor signs/highlighting remain independent and always shown if enabled**
5. Code is maintainable and extensible

## Important Distinction

### Result Display (Affected by display_mode)
- Quickfix list population
- Popup/split window display
- Echo output
- Notification messages
- Error messages

### In-Editor Display (Independent of display_mode)
- Sign column indicators (errors, warnings, hints, SVN markers)
- Syntax highlighting (error/warning backgrounds)
- Virtual text (Neovim only)

**These are ALWAYS shown if enabled, regardless of display_mode setting.**

---

## Recommended Approach: Option A (Unified Dispatcher)

All features should use the main display module for result display with feature-specific configuration overrides. In-editor signs/highlighting remain independent and unaffected.

---

## Phase 1: Core Infrastructure (Foundation)

### 1.1 Extend Display Module

**File:** `autoload/genero_tools/display.vim`

Add new functions for unified display:

```vim
" Display notification/status message
function! genero_tools#display#notify(message, duration) abort
  " Brief auto-dismissing message
  " Used for: "Compilation complete", "Cache cleared", etc.
endfunction

" Display error with display mode support
function! genero_tools#display#error(error_message, display_mode) abort
  " Format and display error respecting display_mode
  " Fallback to echo if mode unsupported
endfunction

" Display details/info popup
function! genero_tools#display#details(title, content, display_mode) abort
  " Display detailed information in appropriate mode
  " Used for: hint details, signature info, etc.
endfunction

" Safe display with error handling
function! genero_tools#display#safe_result(result, display_mode) abort
  " Wrapper that handles errors gracefully
  " Logs errors if debug_mode enabled
endfunction
```

### 1.2 Extend Configuration

**File:** `autoload/genero_tools/config.vim`

Add feature-specific display mode overrides:

```vim
" Feature-specific display mode overrides (optional)
call genero_tools#config#init_key('compiler_display_mode', '')  " empty = use global
call genero_tools#config#init_key('hints_display_mode', '')
call genero_tools#config#init_key('signatures_display_mode', '')
call genero_tools#config#init_key('progress_display_mode', '')
call genero_tools#config#init_key('debug_display_mode', '')

" Notification display options
call genero_tools#config#init_key('notify_enabled', 1)
call genero_tools#config#init_key('notify_duration', 3000)

" Error display options
call genero_tools#config#init_key('error_display_mode', '')  " empty = use global
call genero_tools#config#init_key('error_show_details', 1)
```

Add validation:

```vim
" In genero_tools#config#validate():
" Validate feature-specific display modes
for feature in ['compiler', 'hints', 'signatures', 'progress', 'debug', 'error']
  let mode_key = feature . '_display_mode'
  let mode = genero_tools#config#get(mode_key)
  if !empty(mode)
    let mode = genero_tools#compat#validate_display_mode(mode)
    let g:genero_tools_config[mode_key] = mode
  endif
endfor
```

### 1.3 Helper Function for Display Mode Resolution

**File:** `autoload/genero_tools/display.vim`

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

---

## Phase 2: Compiler Integration (High Priority)

### 2.1 Update Compiler Quickfix

**File:** `autoload/genero_tools/compiler/quickfix.vim`

```vim
" Populate quickfix list with compiler results
function! genero_tools#compiler#quickfix#populate(result, filter) abort
  " ... existing code ...
  
  " Get effective display mode for result display
  let display_mode = genero_tools#display#get_mode('compiler')
  
  " Use main display dispatcher for results
  call genero_tools#display#result(result, display_mode)
endfunction
```

### 2.2 Update Compiler Signs

**File:** `autoload/genero_tools/compiler/signs.vim`

```vim
" Place signs for compiler errors/warnings
" These are ALWAYS shown if enabled, independent of display_mode
function! genero_tools#compiler#signs#place(errors, warnings, info) abort
  " Check if signs are enabled (independent of display_mode)
  if !genero_tools#config#get('compiler_sign_column')
    return
  endif
  
  " ... existing code to place signs ...
  " Signs are shown regardless of display_mode setting
endfunction
```

### 2.3 Update Compiler Progress

**File:** `autoload/genero_tools/compiler/autocompile.vim`

```vim
" Show compilation progress
function! genero_tools#compiler#autocompile#show_progress(message) abort
  let display_mode = genero_tools#display#get_mode('compiler')
  
  if display_mode == 'echo'
    call genero_tools#display#notify(a:message, 3000)
  else
    call genero_tools#display#echo(a:message)
  endif
endfunction
```

### 2.4 Configuration

Add to `config.vim`:

```vim
call genero_tools#config#init_key('compiler_display_mode', '')  " inherit from global
call genero_tools#config#init_key('compiler_show_signs', 1)     " show signs in sign column (independent of display_mode)
call genero_tools#config#init_key('compiler_show_highlights', 1) " show error highlighting (independent of display_mode)
```

---

## Phase 3: Code Hints (High Priority)

### 3.1 Update Hints Display

**File:** `autoload/genero_tools/hints/display.vim`

```vim
" Display hints for a buffer
function! genero_tools#hints#display#show(bufnr, hints) abort
  let bufnr = a:bufnr > 0 ? a:bufnr : bufnr('%')
  
  if empty(a:hints)
    return
  endif
  
  " In-editor display (signs/virtual_text) - ALWAYS shown if enabled
  let hints_display = genero_tools#hints#config#get('hints_display')
  
  if hints_display == 'signs' || hints_display == 'both'
    call genero_tools#hints#display#show_signs(bufnr, a:hints)
  endif
  
  if hints_display == 'virtual_text' || hints_display == 'both'
    if has('nvim')
      call genero_tools#hints#display#show_virtual_text(bufnr, a:hints)
    endif
  endif
  
  " Result display (uses display_mode) - Optional, for listing all hints
  let display_mode = genero_tools#display#get_mode('hints')
  if display_mode != 'signs'  " Don't duplicate if already showing in column
    call genero_tools#hints#display#show_results(bufnr, a:hints, display_mode)
  endif
endfunction

" Display hints in quickfix list (for result display)
function! genero_tools#hints#display#show_quickfix(bufnr, hints) abort
  let qf_list = []
  for hint in a:hints
    call add(qf_list, {
      \ 'filename': bufname(a:bufnr),
      \ 'lnum': hint.line,
      \ 'col': hint.column,
      \ 'text': hint.message,
      \ 'type': hint.severity[0]  " I, W, E
      \ })
  endfor
  call setqflist(qf_list)
  silent! copen
endfunction

" Display hints in popup (for result display)
function! genero_tools#hints#display#show_popup(bufnr, hints) abort
  let formatted = []
  for hint in a:hints
    call add(formatted, hint.line . ':' . hint.column . ' [' . hint.severity . '] ' . hint.message)
  endfor
  call genero_tools#display#popup(formatted)
endfunction

" Display hints in split (for result display)
function! genero_tools#hints#display#show_split(bufnr, hints) abort
  let formatted = []
  for hint in a:hints
    call add(formatted, hint.line . ':' . hint.column . ' [' . hint.severity . '] ' . hint.message)
  endfor
  call genero_tools#display#split(formatted)
endfunction
```

### 3.2 Configuration

Update `autoload/genero_tools/hints/config.vim`:

```vim
call genero_tools#hints#config#init_key('hints_display_mode', '')  " inherit from global (for result display)
call genero_tools#hints#config#init_key('hints_display', 'signs')  " signs, virtual_text, both (in-editor display, independent of display_mode)
call genero_tools#hints#config#init_key('hints_show_in_quickfix', 0)
```

---

## Phase 4: Function Signatures (Medium Priority)

### 4.1 Add Signature Display

**File:** `autoload/genero_tools/signature.vim`

```vim
" Display function signature
function! genero_tools#signature#display(func_obj) abort
  let display_mode = genero_tools#display#get_mode('signatures')
  
  let formatted = genero_tools#signature#format(a:func_obj)
  let details = genero_tools#signature#format_complete_info(a:func_obj)
  
  call genero_tools#display#details(
    \ a:func_obj.name,
    \ [formatted, '', details],
    \ display_mode
    \ )
endfunction
```

### 4.2 Configuration

Add to `config.vim`:

```vim
call genero_tools#config#init_key('signatures_display_mode', '')  " inherit from global
call genero_tools#config#init_key('signatures_show_details', 1)
```

---

## Phase 5: Progress & Status (Medium Priority)

### 5.1 Unified Progress Display

**File:** `autoload/genero_tools/progress.vim`

```vim
" Show progress indicator
function! genero_tools#progress#show(message) abort
  let display_mode = genero_tools#display#get_mode('progress')
  
  if display_mode == 'echo'
    call genero_tools#display#notify(a:message, 0)  " no auto-close
  else
    call genero_tools#display#echo(a:message . ' ...')
  endif
endfunction

" Show progress with elapsed time
function! genero_tools#progress#show_elapsed(message, start_time) abort
  let elapsed = localtime() - a:start_time
  
  if elapsed > 2
    let msg = a:message . ' (' . elapsed . 's elapsed)'
    let display_mode = genero_tools#display#get_mode('progress')
    
    if display_mode == 'echo'
      call genero_tools#display#notify(msg, 5000)
    else
      call genero_tools#display#echo(msg)
    endif
  endif
endfunction
```

### 5.2 Configuration

Add to `config.vim`:

```vim
call genero_tools#config#init_key('progress_display_mode', '')  " inherit from global
call genero_tools#config#init_key('progress_show_elapsed', 1)
```

---

## Phase 6: Debug Streaming (Medium Priority)

### 6.1 Support Multiple Display Modes

**File:** `autoload/genero_tools/debug_stream.vim`

```vim
" Start debug streaming
function! genero_tools#debug_stream#start(file_path) abort
  let display_mode = genero_tools#display#get_mode('debug')
  
  if display_mode == 'popup'
    call genero_tools#debug_stream#start_popup(a:file_path)
  elseif display_mode == 'inline'
    call genero_tools#debug_stream#start_inline(a:file_path)
  else " split (default)
    call genero_tools#debug_stream#start_split(a:file_path)
  endif
endfunction
```

### 6.2 Configuration

Add to `config.vim`:

```vim
call genero_tools#config#init_key('debug_display_mode', 'split')  " default to split
```

---

## Phase 7: Error Display (Medium Priority)

### 7.1 Unified Error Display

**File:** `autoload/genero_tools/error.vim`

```vim
" Display error with display mode support
function! genero_tools#error#display(error_message, display_mode) abort
  let display_mode = genero_tools#compat#validate_display_mode(a:display_mode)
  
  let formatted = ['Error: ' . a:error_message]
  call genero_tools#display#result({'success': 0, 'data': formatted}, display_mode)
endfunction

" Log error to debug stream
function! genero_tools#error#log(module, message) abort
  if genero_tools#config#get('debug_mode')
    let timestamp = strftime('%H:%M:%S')
    let msg = '[' . timestamp . '] [' . a:module . '] ' . a:message
    " Log to debug stream or file
  endif
endfunction
```

### 7.2 Configuration

Add to `config.vim`:

```vim
call genero_tools#config#init_key('error_display_mode', '')  " inherit from global
call genero_tools#config#init_key('error_show_details', 1)
```

---

## Implementation Checklist

### Phase 1: Core Infrastructure
- [ ] Add `notify()`, `error()`, `details()`, `safe_result()` to display.vim
- [ ] Add `get_mode()` helper function
- [ ] Add feature-specific display mode configs
- [ ] Update config validation
- [ ] Test display mode resolution

### Phase 2: Compiler Integration
- [ ] Update quickfix population to use display module
- [ ] Update signs placement to respect display mode
- [ ] Update progress display to use display module
- [ ] Add compiler display configuration
- [ ] Test compiler display in all modes

### Phase 3: Code Hints
- [ ] Add quickfix/popup/split display functions
- [ ] Update hints display to use display module
- [ ] Add hints display configuration
- [ ] Test hints display in all modes

### Phase 4: Function Signatures
- [ ] Add signature display function
- [ ] Add signatures display configuration
- [ ] Test signature display in all modes

### Phase 5: Progress & Status
- [ ] Update progress display to use display module
- [ ] Add progress display configuration
- [ ] Test progress display in all modes

### Phase 6: Debug Streaming
- [ ] Add popup/inline display support
- [ ] Update debug stream to use display module
- [ ] Add debug display configuration
- [ ] Test debug display in all modes

### Phase 7: Error Display
- [ ] Create unified error display function
- [ ] Update error handling to use display module
- [ ] Add error display configuration
- [ ] Test error display in all modes

### Phase 8: Testing & Documentation
- [ ] Test all display modes with all features
- [ ] Test configuration validation
- [ ] Test fallback behavior
- [ ] Update user documentation
- [ ] Update developer documentation

---

## Configuration Examples

### Default Configuration (Backward Compatible)
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'compiler_display_mode': '',  " inherit from global
  \ 'hints_display_mode': '',     " inherit from global
  \ 'signatures_display_mode': '',
  \ 'progress_display_mode': '',
  \ 'debug_display_mode': 'split',
  \ 'error_display_mode': '',
  \ }
```

### Custom Configuration (All Popups)
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'popup',
  \ 'compiler_display_mode': 'popup',
  \ 'hints_display_mode': 'popup',
  \ 'signatures_display_mode': 'popup',
  \ 'progress_display_mode': 'echo',
  \ 'debug_display_mode': 'popup',
  \ }
```

### Mixed Configuration (Feature-Specific)
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'compiler_display_mode': 'quickfix',
  \ 'hints_display_mode': 'signs',
  \ 'signatures_display_mode': 'popup',
  \ 'progress_display_mode': 'echo',
  \ 'debug_display_mode': 'split',
  \ }
```

---

## Testing Strategy

### Unit Tests
- Test display mode resolution
- Test fallback behavior
- Test configuration validation
- Test each display function

### Integration Tests
- Test compiler with all display modes
- Test hints with all display modes
- Test signatures with all display modes
- Test progress with all display modes
- Test debug stream with all display modes

### Manual Tests
- Visual inspection of each mode
- Test in Vim and Neovim
- Test with different terminal sizes
- Test configuration changes
- Test error handling

---

## Rollout Plan

### Week 1: Core Infrastructure
- Implement Phase 1
- Test display mode resolution
- Update documentation

### Week 2: Compiler Integration
- Implement Phase 2
- Test compiler display
- Gather feedback

### Week 3: Hints & Signatures
- Implement Phase 3 & 4
- Test hints and signatures
- Gather feedback

### Week 4: Progress & Debug
- Implement Phase 5 & 6
- Test progress and debug
- Gather feedback

### Week 5: Error Display & Polish
- Implement Phase 7
- Final testing
- Documentation updates

---

## Backward Compatibility

All changes maintain backward compatibility:
- Default behavior unchanged (quickfix mode)
- Existing configuration still works
- Feature-specific overrides are optional
- Fallback to echo if mode unsupported

---

## Success Criteria

- ✓ All features respect `display_mode` configuration
- ✓ All features support all display modes (with appropriate fallbacks)
- ✓ Configuration is consistent across all features
- ✓ Code is maintainable and extensible
- ✓ User experience is consistent
- ✓ Backward compatibility maintained
- ✓ Documentation is complete

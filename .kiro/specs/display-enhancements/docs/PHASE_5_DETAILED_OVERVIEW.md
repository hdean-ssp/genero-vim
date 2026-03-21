# Phase 5: Progress & Status - Detailed Overview

## Scope

Update progress and status display to use the new display infrastructure, enabling progress messages to be displayed in different modes (popup, split, echo, inline) with auto-dismiss capabilities.

---

## Current Implementation

### Progress Module (`autoload/genero_tools/progress.vim`)

**Current Functions:**
- `show(message)` - Shows progress with direct `echom`
- `hide()` - Hides progress with direct `echom`
- `show_elapsed(message, start_time)` - Shows elapsed time with direct `echom`
- `get_elapsed()` - Gets elapsed time

**Current Behavior:**
- Uses direct `echom` calls
- No display mode support
- No auto-dismiss
- No notification settings

### Usage in Compiler Commands (`autoload/genero_tools/compiler/commands.vim`)

```vim
" Show progress
echom 'Compiling: ' . target
let start_time = localtime()

" ... execute compiler ...

let elapsed = localtime() - start_time
```

### Usage in Command Execution (`autoload/genero_tools/command.vim`)

```vim
" Show progress for async operations
if genero_tools#config#get('async_enabled')
  call genero_tools#progress#show('Executing genero-tools: ' . a:command)
endif

" ... execute command ...

" Hide progress
if genero_tools#config#get('async_enabled')
  call genero_tools#progress#hide()
endif

" Show elapsed time
if elapsed > 2
  call genero_tools#progress#show_elapsed('Command completed', start_time)
endif
```

---

## What Phase 5 Will Change

### 1. Progress Module Updates

#### Update `show()` Function
```vim
" Before
function! genero_tools#progress#show(message) abort
  echom a:message . ' ...'
  let s:progress_shown = 1
endfunction

" After
function! genero_tools#progress#show(message) abort
  let display_mode = genero_tools#display#get_mode('progress')
  call genero_tools#display#notify(a:message . ' ...', 0)
  let s:progress_shown = 1
endfunction
```

#### Update `show_elapsed()` Function
```vim
" Before
function! genero_tools#progress#show_elapsed(message, start_time) abort
  let elapsed = localtime() - a:start_time
  if elapsed > 2
    echom a:message . ' (' . elapsed . 's elapsed)'
  endif
endfunction

" After
function! genero_tools#progress#show_elapsed(message, start_time) abort
  let elapsed = localtime() - a:start_time
  if elapsed > 2
    let display_mode = genero_tools#display#get_mode('progress')
    call genero_tools#display#notify(a:message . ' (' . elapsed . 's elapsed)', 0)
  endif
endfunction
```

#### Update `hide()` Function
```vim
" Before
function! genero_tools#progress#hide() abort
  if s:progress_shown
    echom ''
    let s:progress_shown = 0
  endif
endfunction

" After
function! genero_tools#progress#hide() abort
  " With auto-dismiss, this may become a no-op
  " Or clear the notification if needed
  let s:progress_shown = 0
endfunction
```

### 2. Compiler Commands Updates

Replace direct `echom` calls:
```vim
" Before
echom 'Compiling: ' . target

" After
call genero_tools#display#notify('Compiling: ' . target, 0)
```

### 3. Command Execution Updates

Replace direct `echom` calls:
```vim
" Before
call genero_tools#progress#show('Executing genero-tools: ' . a:command)

" After (already uses progress module, will be updated)
call genero_tools#display#notify('Executing genero-tools: ' . a:command, 0)
```

---

## Configuration

### Feature-Specific Override
```vim
let g:genero_tools_config.progress_display_mode = 'popup'
```

### Notification Options
```vim
let g:genero_tools_config.notify_enabled = 1        " Enable notifications
let g:genero_tools_config.notify_duration = 3000    " Auto-dismiss timer (ms)
```

### Examples

**Default (Echo with auto-dismiss):**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'progress_display_mode': '',
  \ 'notify_enabled': 1,
  \ 'notify_duration': 3000,
  \ }
```

**Popup Display (auto-dismiss after 3 seconds):**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'progress_display_mode': 'popup',
  \ 'notify_enabled': 1,
  \ 'notify_duration': 3000,
  \ }
```

**Inline Display (auto-dismiss after 5 seconds):**
```vim
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'progress_display_mode': 'inline',
  \ 'notify_enabled': 1,
  \ 'notify_duration': 5000,
  \ }
```

**Disable Notifications:**
```vim
let g:genero_tools_config = {
  \ 'notify_enabled': 0,
  \ }
```

---

## Display Modes

### Echo (Default)
- Command line display
- Auto-dismisses after duration
- Works in Vim and Neovim
- Minimal visual impact

### Popup
- Floating window (Neovim) / Echo (Vim)
- Auto-dismisses after duration
- More prominent display
- Better for important messages

### Inline
- Small popup by cursor (Neovim) / Echo (Vim)
- Auto-dismisses after duration
- Contextual display
- Good for quick feedback

### Split
- Split window
- Auto-dismisses after duration
- Persistent display
- Good for long-running operations

---

## Files to Modify

### 1. autoload/genero_tools/progress.vim
- Update `show()` to use `display#notify()`
- Update `show_elapsed()` to use `display#notify()`
- Update `hide()` (may become no-op)
- Add `show_with_mode()` for explicit mode control (optional)

### 2. autoload/genero_tools/compiler/commands.vim
- Replace `echom 'Compiling: ' . target` with `display#notify()`
- Replace other `echom` calls with `display#notify()`

### 3. autoload/genero_tools/command.vim
- Replace `echom` calls with `display#notify()`
- Update progress display calls

---

## Implementation Steps

### Step 1: Update Progress Module
1. Update `show()` function
2. Update `show_elapsed()` function
3. Update `hide()` function
4. Test backward compatibility

### Step 2: Update Compiler Commands
1. Replace `echom` calls with `display#notify()`
2. Test compilation progress display
3. Test elapsed time display

### Step 3: Update Command Execution
1. Replace `echom` calls with `display#notify()`
2. Test async operation progress display
3. Test elapsed time display

### Step 4: Testing
1. Test all display modes
2. Test feature-specific overrides
3. Test auto-dismiss functionality
4. Test backward compatibility
5. Test with different notification durations

---

## Success Criteria

- ✓ Progress messages respect `display_mode` config
- ✓ Progress messages respect `progress_display_mode` override
- ✓ All display modes work (echo, popup, inline, split)
- ✓ Auto-dismiss works with configurable duration
- ✓ Backward compatible
- ✓ No syntax errors
- ✓ All tests pass

---

## Estimated Effort

**1-2 days** (8-12 hours)
- Update progress module: 2-3 hours
- Update compiler commands: 1-2 hours
- Update command execution: 1-2 hours
- Testing: 2-3 hours

---

## What Stays the Same

- ✓ Progress tracking logic
- ✓ Elapsed time calculation
- ✓ All existing configuration options
- ✓ Async operation handling
- ✓ Performance characteristics

---

## Integration with Phase 2

**Note:** Phase 2 already updated `autocompile.vim` to use `display#notify()`:

```vim
" From Phase 2
call genero_tools#display#notify('Autocompile enabled for current buffer', 0)
```

Phase 5 will extend this pattern to other progress/status displays.

---

## Benefits

### For Users
- ✓ Progress messages can be displayed in preferred mode
- ✓ Auto-dismiss reduces clutter
- ✓ Configurable notification duration
- ✓ Consistent with global display_mode

### For Developers
- ✓ Centralized progress display logic
- ✓ Consistent code patterns
- ✓ Easier to maintain
- ✓ Easier to extend

### For Code Quality
- ✓ Reduced code duplication
- ✓ Better separation of concerns
- ✓ Consistent error handling
- ✓ Clearer code intent

---

## Summary

Phase 5 will update progress and status display to use the new display infrastructure, enabling progress messages to be displayed in different modes with auto-dismiss capabilities while maintaining backward compatibility.

The implementation will:
1. Update the progress module to use `display#notify()`
2. Update compiler commands to use progress display
3. Update command execution to use progress display
4. Maintain full backward compatibility
5. Support all display modes with auto-dismiss


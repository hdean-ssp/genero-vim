# Fixed Bugs - March 23, 2026

## Summary
All 4 reported bugs have been fixed and are ready for testing.

---

## Issue #002: Snippets Cannot Be Selected from Autocomplete Menu

**Status**: ✅ FIXED - March 23, 2026
**Severity**: High

### Problem
Snippets could not be selected from the autocomplete menu using standard selection keys (Ctrl+N, Tab, Enter). When a snippet appeared in the autocomplete menu, users could not select it to insert the snippet body.

### Root Cause
- Snippet completion items were added to autocomplete menu but had no selection handler
- When user selected a snippet from autocomplete, Vim just inserted the trigger text without expanding it
- Missing `CompleteDone` autocommand to handle snippet expansion

### Solution
1. Added `user_data` field to snippet completion items with JSON metadata
2. Created `genero_tools#complete#setup_completion_callback()` function
3. Added `genero_tools#complete#handle_completion_done()` to handle snippet selection
4. Integrated callback setup into plugin initialization

### Files Modified
- `autoload/genero_tools/complete.vim` - Added completion callback system
- `plugin/genero_tools.vim` - Added callback initialization for Neovim

### How It Works
1. Snippet completion items now include `user_data` with type and trigger info
2. When user selects a snippet from autocomplete, `CompleteDone` event fires
3. Handler checks if selected item is a snippet
4. If snippet, deletes inserted trigger text and calls `genero_tools#snippets#expand()`
5. Snippet expands properly through luasnip with placeholder navigation

### Testing
- Trigger autocomplete menu (Ctrl+X Ctrl+O)
- Type snippet trigger (e.g., "func")
- Select snippet from menu with Ctrl+N or arrow keys
- Press Enter to select
- Snippet should expand with proper placeholders

---

## Issue #003: Debug Stream Selection Window Too Small and Not Navigable

**Status**: ✅ FIXED - March 23, 2026
**Severity**: High

### Problem
The debug stream selection window was too small, only showing 2 documents in the list and was not properly navigable. Previously this was a large floating window where users could navigate up/down the list.

### Root Cause
- File selector was using `input()` prompt which is not navigable
- Tried to call non-existent `genero_tools#display#details()` function
- No floating window implementation for file selection

### Solution
1. Replaced `input()` prompt with proper floating window
2. Implemented keyboard navigation (j/k, arrow keys)
3. Added mouse click support
4. Proper window sizing based on file list length
5. Enter key to select, Escape to cancel

### Files Modified
- `autoload/genero_tools/debug_stream.vim` - Complete rewrite of file selector

### New Functions
- `s:show_file_selector()` - Creates floating window with file list
- `s:setup_file_selector_keybindings()` - Sets up keyboard/mouse controls
- `s:select_file()` - Handles file selection
- `s:next_file()` / `s:prev_file()` - Navigation
- `s:mouse_select_file()` - Mouse support
- `s:highlight_selected_file()` - Visual feedback
- `s:close_file_selector()` - Cleanup

### How It Works
1. User runs `:GeneroDebugStreamSelect` command
2. Floating window appears showing debug files sorted by modification time
3. User navigates with j/k or arrow keys
4. Selected file is highlighted with CursorLine
5. Press Enter to select and start streaming
6. Press Escape to cancel

### Features
- Large floating window (up to 80 columns wide)
- Shows all available debug files
- Keyboard navigation (j/k, arrows)
- Mouse click support
- Visual highlighting of selected file
- Proper window sizing

### Testing
- Run `:GeneroDebugStreamSelect` command
- Verify floating window appears with file list
- Navigate with j/k keys
- Navigate with arrow keys
- Click on file with mouse
- Press Enter to select
- Press Escape to cancel
- Verify selected file starts streaming

---

## Issue #004: Empty Floating Window on Buffer Load Disappears After 5 Seconds

**Status**: ✅ FIXED - March 23, 2026
**Severity**: Medium

### Problem
An empty floating window appeared on buffer load and disappeared after approximately 5 seconds. This occurred with the default supplied configuration.

### Root Cause
- `genero_tools#display#inline()` function was creating floating windows even with empty content
- Inline display mode has auto-close timer (5 seconds) that closes windows automatically
- Empty results were triggering inline display unnecessarily

### Solution
- Added empty content check in `genero_tools#display#inline()`
- Function now returns early if formatted content is empty
- Prevents creation of empty floating windows

### Files Modified
- `autoload/genero_tools/display.vim` - Added empty content guard

### Code Change
```vim
function! genero_tools#display#inline(formatted) abort
  " Don't display if there's no content
  if empty(a:formatted)
    return
  endif
  " ... rest of function
endfunction
```

### Impact
- No more empty floating windows appearing on buffer load
- No more mysterious windows disappearing after 5 seconds
- Cleaner user experience

### Testing
- Load a buffer with default config
- Verify no empty floating window appears
- Verify no window disappears after 5 seconds
- Test with different display modes

---

## Issue #005: Messages Display in Floating Window

**Status**: ✅ FIXED - March 23, 2026
**Severity**: Medium

### Problem
Messages were displaying in the floating window (e.g., hint list) when they should display in other modes or be handled differently. This was causing display conflicts or unexpected behavior.

### Root Cause
- Notification system was using floating windows for messages
- Messages should always display in command line (echo), not floating windows
- Floating windows should be reserved for content display (hints, debug stream, etc.)

### Solution
- Simplified `genero_tools#display#notify()` to always use echo mode
- Removed floating window notification code
- Messages now consistently display in command line

### Files Modified
- `autoload/genero_tools/display.vim` - Simplified notification function

### Code Change
```vim
function! genero_tools#display#notify(message, duration) abort
  if !genero_tools#config#get('notify_enabled')
    return
  endif
  
  " Always use echo for notifications, not floating windows
  call genero_tools#display#echo(a:message)
endfunction
```

### Impact
- Messages always display in command line
- No interference with floating window content
- Consistent message display across all features
- Cleaner separation of concerns (messages vs content)

### Testing
- Trigger various commands that show messages
- Verify messages appear in command line
- Verify messages don't appear in floating windows
- Test with hints, debug stream, and other features

---

## Summary of Changes

### Files Modified
1. **autoload/genero_tools/complete.vim**
   - Added snippet completion callback system
   - Added `user_data` field to snippet items
   - Added `setup_completion_callback()` function
   - Added `handle_completion_done()` function

2. **autoload/genero_tools/debug_stream.vim**
   - Rewrote file selector with floating window
   - Added keyboard navigation
   - Added mouse support
   - Removed `input()` prompt

3. **autoload/genero_tools/display.vim**
   - Added empty content guard to `inline()` function
   - Simplified `notify()` function to use echo only
   - Removed floating window notification code

4. **plugin/genero_tools.vim**
   - Added completion callback initialization

### Backward Compatibility
All changes are backward compatible:
- Existing snippet functionality still works
- Debug stream still works (just with better UI)
- Display modes still work as before
- No breaking changes to public API

### Testing Checklist
- [ ] Snippet autocomplete selection works
- [ ] Debug stream file selection works with keyboard
- [ ] Debug stream file selection works with mouse
- [ ] No empty floating windows on buffer load
- [ ] Messages display in command line only
- [ ] All display modes still work
- [ ] No syntax errors in modified files


# Unified Testing Guide

**Last Updated**: April 1, 2026
**Purpose**: Consolidated testing guide for all features and bug fixes

---

## Quick Navigation

- **User Testing**: See [User Feature Testing](#user-feature-testing)
- **Bug Fix Testing**: See [Bug Fix Testing](#bug-fix-testing)
- **Developer Testing**: See [Developer Testing](#developer-testing)

---

## User Feature Testing

### Testing Snippets

**Prerequisites**:
- Neovim 0.5+ with LuaSnip installed
- genero-tools plugin installed
- Snippets enabled in config

**Test 1: Snippet List Display**
1. Open a `.4gl` file
2. Run `:GeneroSnippetList`
3. Verify snippet list displays with triggers and descriptions
4. Verify list is scrollable if many snippets

**Test 2: Snippet Expansion**
1. Open a `.4gl` file
2. Type a snippet trigger (e.g., "func")
3. Press Tab to expand
4. Verify snippet body expands with placeholders
5. Verify placeholders are navigable with Tab/Shift+Tab

**Test 3: Snippet Autocomplete**
1. Open a `.4gl` file
2. Press Ctrl+X Ctrl+O to trigger autocomplete
3. Type snippet trigger (e.g., "func")
4. Verify snippet appears in autocomplete menu
5. Select snippet with Ctrl+N or arrow keys
6. Press Enter to select
7. Verify snippet expands properly

**Test 4: Custom Snippets**
1. Create custom snippet in `~/.config/nvim/genero-snippets/`
2. Reload Neovim
3. Run `:GeneroSnippetList`
4. Verify custom snippet appears in list
5. Test expansion of custom snippet

### Testing Code Hints

**Prerequisites**:
- Hints enabled in config
- genero-tools plugin installed

**Test 5: Hint Detection**
1. Open a `.4gl` file
2. Add trailing whitespace at end of line
3. Verify hint appears in sign column
4. Verify hint message displays on hover

**Test 6: Hint Navigation**
1. Open a `.4gl` file with multiple hints
2. Run `:GeneroNextHint`
3. Verify cursor moves to next hint
4. Run `:GeneroPrevHint`
5. Verify cursor moves to previous hint

**Test 7: Hint Auto-Fix**
1. Open a `.4gl` file with fixable hint (e.g., trailing whitespace)
2. Position cursor on hint
3. Run `:GeneroHintAutofix`
4. Verify hint is fixed automatically

### Testing Compiler Integration

**Prerequisites**:
- Compiler enabled in config
- fglcomp installed and in PATH

**Test 8: Compilation**
1. Open a `.4gl` file
2. Press F5 to compile
3. Verify compilation runs
4. Verify errors/warnings appear in quickfix list
5. Verify error signs appear in sign column

**Test 9: Error Navigation**
1. Compile a file with errors
2. Press Ctrl+. to go to next error
3. Verify cursor moves to error location
4. Press Ctrl+, to go to previous error
5. Verify cursor moves to previous error

**Test 10: Autocompile**
1. Enable autocompile: `:GeneroAutocompileEnable`
2. Edit a `.4gl` file
3. Save file
4. Verify compilation runs automatically
5. Verify errors update in quickfix list

### Testing SVN Integration

**Prerequisites**:
- SVN enabled in config
- File is in SVN working copy

**Test 11: SVN Diff Markers**
1. Open a file in SVN working copy
2. Run `:GeneroSVNRefresh`
3. Verify diff markers appear in sign column
4. Verify added lines show + marker
5. Verify modified lines show ~ marker
6. Verify deleted lines show - marker

**Test 12: SVN Status**
1. Open a file in SVN working copy
2. Run `:GeneroSVNStatus`
3. Verify SVN status displays
4. Verify file modification status is correct

### Testing Debug Streaming

**Prerequisites**:
- Neovim only
- Debug streaming enabled in config

**Test 13: Debug Stream Toggle**
1. Run `:GeneroDebugStreamToggle`
2. Verify debug stream window opens
3. Run `:GeneroDebugStreamToggle` again
4. Verify debug stream window closes

**Test 14: Debug Stream File Selection**
1. Run `:GeneroDebugStreamSelect`
2. Verify file selector window opens
3. Verify file list is displayed
4. Navigate with arrow keys or j/k
5. Select file with Enter
6. Verify selected file streams to debug window

---

## Bug Fix Testing

### Bug #002: Snippets Cannot Be Selected from Autocomplete Menu

**Status**: ✅ FIXED

**Test Procedure**:
1. Open a `.4gl` file
2. Press Ctrl+X Ctrl+O to trigger autocomplete
3. Type snippet trigger (e.g., "func")
4. Verify snippet appears in autocomplete menu
5. Select snippet with Ctrl+N or arrow keys
6. Press Enter to select
7. **Expected**: Snippet expands with placeholders
8. **Verify**: Snippet body is inserted, not just trigger text

**Pass Criteria**:
- ✅ Snippet appears in autocomplete menu
- ✅ Snippet can be selected with keyboard
- ✅ Snippet expands properly when selected
- ✅ Placeholders are navigable

### Bug #003: Debug Stream Selection Window Too Small and Not Navigable

**Status**: ✅ FIXED

**Test Procedure**:
1. Create multiple debug files in debug directory
2. Run `:GeneroDebugStreamSelect`
3. **Expected**: Large, navigable file selector window opens
4. Verify window is large enough to see all files
5. Navigate with arrow keys (Up/Down)
6. Navigate with j/k keys
7. Select file with Enter
8. **Expected**: Selected file streams to debug window
9. Verify window closes after selection

**Pass Criteria**:
- ✅ File selector window is large and readable
- ✅ All files are visible (or scrollable)
- ✅ Keyboard navigation works (arrows, j/k)
- ✅ Mouse selection works
- ✅ Selected file streams properly
- ✅ Window closes after selection

### Bug #004: Empty Floating Window on Buffer Load Disappears After 5 Seconds

**Status**: ✅ FIXED

**Test Procedure**:
1. Open a `.4gl` file
2. Run a command that returns empty results (e.g., `:GeneroLookup nonexistent`)
3. **Expected**: No floating window appears
4. **Verify**: No empty window flashes on screen
5. **Verify**: Error message displays in command line instead

**Pass Criteria**:
- ✅ No empty floating window appears
- ✅ No window flashes and disappears
- ✅ Error message displays in command line
- ✅ User experience is clean

### Bug #005: Messages Display in Floating Window

**Status**: ✅ FIXED

**Test Procedure**:
1. Open a `.4gl` file
2. Run a command that displays a message (e.g., `:GeneroAutocompileEnable`)
3. **Expected**: Message displays in command line
4. **Verify**: Message does NOT appear in floating window
5. **Verify**: Message is visible and readable in command line

**Pass Criteria**:
- ✅ Messages display in command line
- ✅ Messages do NOT display in floating windows
- ✅ Messages are visible and readable
- ✅ User experience is consistent

---

## Developer Testing

### Unit Testing

**Test 1: Snippet Completion Callback**
- File: `autoload/genero_tools/complete.vim`
- Function: `genero_tools#complete#setup_completion_callback()`
- Verify: Callback is registered on plugin load
- Verify: Callback fires when snippet is selected from autocomplete

**Test 2: Debug Stream File Selector**
- File: `autoload/genero_tools/debug_stream.vim`
- Function: `s:show_file_selector()`
- Verify: Floating window is created with proper size
- Verify: File list is displayed correctly
- Verify: Keyboard navigation works
- Verify: Mouse selection works

**Test 3: Display Empty Content Guard**
- File: `autoload/genero_tools/display.vim`
- Function: `genero_tools#display#inline()`
- Verify: Empty content is detected
- Verify: No floating window is created for empty content
- Verify: Function returns early for empty content

**Test 4: Notification Display**
- File: `autoload/genero_tools/display.vim`
- Function: `genero_tools#display#notify()`
- Verify: Messages always use echo
- Verify: Messages display in command line
- Verify: Messages do NOT use floating windows

### Integration Testing

**Test 5: Snippet Expansion with Different Triggers**
- Test multiple snippet triggers
- Verify each expands correctly
- Verify placeholders work for each
- Verify Tab/Shift+Tab navigation works

**Test 6: Debug Stream with Many Files**
- Create 50+ debug files
- Run `:GeneroDebugStreamSelect`
- Verify file selector handles large lists
- Verify scrolling works
- Verify selection works

**Test 7: Display Mode Compatibility**
- Test each display mode (quickfix, popup, split, echo, inline)
- Verify each mode displays results correctly
- Verify mode switching works
- Verify fallback works for unsupported modes

**Test 8: Vim vs Neovim Compatibility**
- Test in Vim 8+
- Test in Neovim 0.5+
- Verify core features work in both
- Verify Neovim-only features gracefully degrade in Vim

### Regression Testing

**Test 9: Existing Functionality**
- Test all existing features still work
- Test all keybindings still work
- Test all commands still work
- Test configuration still works
- Verify no breaking changes

---

## Test Execution Checklist

### Phase 1: Unit Testing
- [ ] Test 1: Snippet Autocomplete Selection
- [ ] Test 2: Debug Stream File Selection
- [ ] Test 3: Empty Floating Window
- [ ] Test 4: Message Display

### Phase 2: Integration Testing
- [ ] Test 5: Snippet Expansion with Different Triggers
- [ ] Test 6: Debug Stream File Selection with Many Files
- [ ] Test 7: Display Mode Compatibility
- [ ] Test 8: Vim vs Neovim Compatibility

### Phase 3: Regression Testing
- [ ] Test 9: Existing Functionality

### Phase 4: User Testing
- [ ] Test 1-14: All user feature tests

---

## Test Result Documentation

### Test Result Template

```
Test: [Test Name]
Date: [Date]
Tester: [Name]
Environment: [Vim/Neovim version, OS]

Expected Result:
[What should happen]

Actual Result:
[What actually happened]

Pass/Fail: [PASS/FAIL]

Notes:
[Any additional notes]
```

---

## Troubleshooting

### Snippet Not Expanding
- Verify LuaSnip is installed
- Verify snippets_enabled is true in config
- Verify snippet trigger is correct
- Check debug stream for errors

### Debug Stream Not Working
- Verify debug_stream_directory exists
- Verify debug files exist in directory
- Verify Neovim 0.5+ is being used
- Check debug stream for errors

### Hints Not Displaying
- Verify hints_enabled is true in config
- Verify hints_display is set correctly
- Verify file is a `.4gl` file
- Check for syntax errors in file

### Compiler Not Working
- Verify compiler_enabled is true in config
- Verify fglcomp is installed and in PATH
- Verify file is a `.4gl` or `.per` file
- Check compiler output for errors

---

## Performance Benchmarks

### Expected Performance
- Snippet expansion: <100ms
- Debug stream file selection: <200ms
- Hint detection: <500ms
- Compilation: Depends on file size

### Performance Testing
1. Measure time for each operation
2. Compare with expected performance
3. Document any performance issues
4. Optimize if needed

---

## Success Criteria

### All Tests Pass When:
- ✅ All unit tests pass
- ✅ All integration tests pass
- ✅ All regression tests pass
- ✅ All user feature tests pass
- ✅ No performance regressions
- ✅ No breaking changes
- ✅ All documentation is accurate

---

## Related Documentation

- **BUG_TRACKING.md** - Bug fix details
- **PROJECT_STATUS.md** - Project status
- **TESTING_GUIDE_BUGS.md** - Bug-specific testing (deprecated, see this file)
- **TESTING_GUIDE.md** - General testing guide (deprecated, see this file)
- **SNIPPET_TESTING_GUIDE.md** - Snippet testing (deprecated, see this file)

---

**Last Updated**: April 1, 2026
**Status**: ✅ READY FOR TESTING


# Bug Fixes Testing Guide

## Quick Test Procedures

### Test 1: Snippet Autocomplete Selection (Issue #002)

**Setup:**
- Open a Genero file (.4gl, .m3, .m4, or .per)
- Ensure snippets are enabled in config

**Test Steps:**
1. Enter insert mode
2. Type a snippet trigger (e.g., "func" for function snippet)
3. Press Ctrl+X Ctrl+O to trigger autocomplete
4. Verify snippet appears in autocomplete menu with "[snippet]" label
5. Press Ctrl+N or arrow keys to select the snippet
6. Press Enter to select
7. Verify snippet expands with placeholders
8. Press Tab to navigate to next placeholder
9. Press Shift+Tab to navigate to previous placeholder

**Expected Result:**
- Snippet appears in autocomplete menu
- Snippet can be selected with keyboard
- Snippet expands properly with placeholders
- Placeholder navigation works

**Pass/Fail:** ___________

---

### Test 2: Debug Stream File Selection (Issue #003)

**Setup:**
- Create a debug directory with some test files
- Configure debug_stream_directory in config

**Test Steps:**
1. Run `:GeneroDebugStreamSelect` command
2. Verify floating window appears with file list
3. Verify window is large enough to show multiple files
4. Navigate with j key (down)
5. Navigate with k key (up)
6. Navigate with arrow keys
7. Click on a file with mouse
8. Press Enter to select
9. Verify selected file starts streaming
10. Run `:GeneroDebugStreamSelect` again
11. Press Escape to cancel

**Expected Result:**
- Floating window appears with all debug files
- Window is properly sized
- Keyboard navigation works (j/k/arrows)
- Mouse click works
- Enter selects file and starts streaming
- Escape cancels selection

**Pass/Fail:** ___________

---

### Test 3: Empty Floating Window (Issue #004)

**Setup:**
- Use default configuration
- Open a Genero file

**Test Steps:**
1. Load a buffer
2. Observe for 10 seconds
3. Change to another buffer
4. Observe for 10 seconds
5. Save the file
6. Observe for 10 seconds

**Expected Result:**
- No empty floating windows appear
- No windows disappear after 5 seconds
- No mysterious popups

**Pass/Fail:** ___________

---

### Test 4: Message Display (Issue #005)

**Setup:**
- Open a Genero file
- Enable hints

**Test Steps:**
1. Trigger a command that shows a message (e.g., `:GeneroListHints`)
2. Verify message appears in command line
3. Verify message does NOT appear in a floating window
4. Run `:GeneroDebugStreamSelect` and cancel
5. Verify any messages appear in command line
6. Trigger various other commands
7. Verify all messages appear in command line only

**Expected Result:**
- All messages appear in command line (echo)
- No messages appear in floating windows
- Floating windows are reserved for content only

**Pass/Fail:** ___________

---

## Comprehensive Test Suite

### Test 5: Snippet Expansion with Different Triggers

**Test Steps:**
1. Test with different snippet triggers
2. Test with snippets that have multiple placeholders
3. Test with snippets that have default values
4. Test snippet expansion from snippet list (`:GeneroSnippetList`)
5. Test snippet expansion from autocomplete menu

**Expected Result:**
- All snippet types expand correctly
- Placeholders work as expected
- Default values are populated

**Pass/Fail:** ___________

---

### Test 6: Debug Stream File Selection with Many Files

**Test Steps:**
1. Create 20+ debug files
2. Run `:GeneroDebugStreamSelect`
3. Verify all files are visible (scrollable if needed)
4. Navigate through all files
5. Select a file in the middle
6. Verify correct file is selected

**Expected Result:**
- All files are accessible
- Navigation works smoothly
- Correct file is selected

**Pass/Fail:** ___________

---

### Test 7: Display Mode Compatibility

**Test Steps:**
1. Set display_mode to 'quickfix'
2. Run various commands
3. Set display_mode to 'popup'
4. Run various commands
5. Set display_mode to 'split'
6. Run various commands
7. Set display_mode to 'echo'
8. Run various commands

**Expected Result:**
- All display modes work correctly
- No empty windows appear
- Messages display appropriately

**Pass/Fail:** ___________

---

### Test 8: Vim vs Neovim Compatibility

**Test Steps:**
1. Test in Vim 8.2+
2. Test in Neovim 0.5+
3. Test in Neovim 0.6+

**Expected Result:**
- All features work in both Vim and Neovim
- Fallbacks work correctly
- No errors or warnings

**Pass/Fail:** ___________

---

## Regression Testing

### Test 9: Existing Functionality

**Test Steps:**
1. Test GeneroLookup command
2. Test GeneroListFunctions command
3. Test GeneroCompile command
4. Test hints display
5. Test SVN diff markers
6. Test autocomplete with functions
7. Test all keybindings

**Expected Result:**
- All existing functionality still works
- No regressions introduced
- No new errors

**Pass/Fail:** ___________

---

## Summary

| Test | Pass | Fail | Notes |
|------|------|------|-------|
| Test 1: Snippet Autocomplete | ___ | ___ | |
| Test 2: Debug Stream Selection | ___ | ___ | |
| Test 3: Empty Floating Window | ___ | ___ | |
| Test 4: Message Display | ___ | ___ | |
| Test 5: Snippet Expansion | ___ | ___ | |
| Test 6: Many Debug Files | ___ | ___ | |
| Test 7: Display Modes | ___ | ___ | |
| Test 8: Vim/Neovim | ___ | ___ | |
| Test 9: Regression | ___ | ___ | |

**Overall Status:** ___________

**Date Tested:** ___________

**Tester:** ___________

**Notes:**


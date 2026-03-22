# Snippet System Testing Guide

**Last Updated**: March 22, 2026
**Status**: Complete
**Scope**: Comprehensive testing for Bug Fix #001

---

## Testing Overview

This guide covers comprehensive testing for the snippet system implementation including:
- Snippet list selection (keyboard and mouse)
- Snippet expansion with LuaSnip
- Autocomplete integration
- Placeholder navigation
- Display mode compatibility
- Vim/Neovim compatibility

---

## Part 1: Snippet List Selection Testing

### Test 1.1: Snippet List Display

**Objective**: Verify snippet list displays correctly

**Steps**:
1. Open Neovim with genero-tools plugin
2. Execute: `:GeneroSnippetList`
3. Verify floating window appears with:
   - Rounded border
   - Title "Snippets"
   - List of snippets formatted as `[N] trigger - description`
   - Centered on screen

**Expected Result**: ✓ Floating window displays with proper formatting

**Failure Handling**:
- If window doesn't appear: Check Neovim version (0.5+)
- If formatting is wrong: Check `show_snippet_list()` function
- If snippets are empty: Check snippet loading in Lua layer

---

### Test 1.2: Keyboard Navigation

**Objective**: Verify keyboard navigation in snippet list

**Steps**:
1. Execute: `:GeneroSnippetList`
2. Press `j` - verify selection moves down
3. Press `k` - verify selection moves up
4. Press `Down` - verify selection moves down
5. Press `Up` - verify selection moves up
6. Press `j` at bottom - verify selection doesn't go past end
7. Press `k` at top - verify selection doesn't go before start

**Expected Result**: ✓ Selection moves correctly with boundary checking

**Failure Handling**:
- If navigation doesn't work: Check keybinding setup
- If boundaries not enforced: Check `next_snippet()` and `prev_snippet()` functions
- If highlighting doesn't update: Check `highlight_selected_snippet()` function

---

### Test 1.3: Keyboard Selection

**Objective**: Verify Enter key selects snippet

**Steps**:
1. Execute: `:GeneroSnippetList`
2. Navigate to a snippet (e.g., first one)
3. Press `Enter`
4. Verify:
   - Floating window closes
   - Snippet expands at cursor position
   - Cursor is positioned in expanded snippet

**Expected Result**: ✓ Snippet expands correctly on Enter

**Failure Handling**:
- If window doesn't close: Check `close_snippet_list()` function
- If snippet doesn't expand: Check `select_snippet()` function
- If cursor position is wrong: Check `expand()` function

---

### Test 1.4: Escape to Cancel

**Objective**: Verify Escape key cancels selection

**Steps**:
1. Execute: `:GeneroSnippetList`
2. Press `Esc`
3. Verify:
   - Floating window closes
   - No snippet is expanded
   - Cursor position unchanged

**Expected Result**: ✓ Window closes without expanding snippet

**Failure Handling**:
- If window doesn't close: Check `close_snippet_list()` function
- If snippet expands: Check keybinding for Esc

---

### Test 1.5: Mouse Selection

**Objective**: Verify mouse click selects snippet

**Steps**:
1. Execute: `:GeneroSnippetList`
2. Click on a snippet line (not first one)
3. Verify:
   - Selection moves to clicked line
   - Snippet expands at cursor position
   - Window closes

**Expected Result**: ✓ Mouse click selects and expands snippet

**Failure Handling**:
- If selection doesn't move: Check `mouse_select_snippet()` function
- If snippet doesn't expand: Check mouse event handling
- If window doesn't close: Check `select_snippet()` function

---

### Test 1.6: Visual Feedback

**Objective**: Verify visual feedback for selection

**Steps**:
1. Execute: `:GeneroSnippetList`
2. Observe first item is highlighted
3. Press `j` to move to next item
4. Verify:
   - Previous item is no longer highlighted
   - New item is highlighted with CursorLine color
   - Cursor moves to highlighted line

**Expected Result**: ✓ Visual feedback updates correctly

**Failure Handling**:
- If highlighting doesn't update: Check `highlight_selected_snippet()` function
- If cursor doesn't move: Check `nvim_win_set_cursor()` call
- If colors are wrong: Check highlight group configuration

---

## Part 2: Snippet Expansion Testing

### Test 2.1: Basic Expansion

**Objective**: Verify snippet expands correctly

**Steps**:
1. Create a test snippet in `~/.config/nvim/genero-snippets/test.lua`:
   ```lua
   return {
     {
       trigger = 'testsnip',
       name = 'Test Snippet',
       description = 'Test snippet',
       body = 'Hello World'
     }
   }
   ```
2. In Neovim, execute: `:GeneroSnippet testsnip`
3. Verify: "Hello World" is inserted at cursor

**Expected Result**: ✓ Snippet body is inserted correctly

**Failure Handling**:
- If snippet doesn't expand: Check Lua layer functions
- If wrong text is inserted: Check snippet body parsing
- If cursor position is wrong: Check insertion logic

---

### Test 2.2: Multi-line Expansion

**Objective**: Verify multi-line snippets expand correctly

**Steps**:
1. Create multi-line test snippet:
   ```lua
   return {
     {
       trigger = 'multiline',
       body = [[
function test()
  -- body
end function
       ]]
     }
   }
   ```
2. Execute: `:GeneroSnippet multiline`
3. Verify: All lines are inserted correctly with proper indentation

**Expected Result**: ✓ Multi-line snippet expands with correct formatting

**Failure Handling**:
- If lines are missing: Check line splitting logic
- If indentation is wrong: Check whitespace handling
- If formatting is corrupted: Check body parsing

---

### Test 2.3: Expansion from Snippet List

**Objective**: Verify expansion works from snippet list

**Steps**:
1. Execute: `:GeneroSnippetList`
2. Select a snippet with Enter
3. Verify snippet expands correctly

**Expected Result**: ✓ Snippet expands from list selection

**Failure Handling**:
- If snippet doesn't expand: Check `select_snippet()` function
- If wrong snippet expands: Check index tracking
- If expansion fails: Check `expand()` function

---

### Test 2.4: Expansion from Autocomplete

**Objective**: Verify expansion works from autocomplete menu

**Steps**:
1. In insert mode, type: `test`
2. Press `Ctrl+N` to trigger autocomplete
3. Verify snippets appear with `[snippet]` indicator
4. Select a snippet
5. Verify snippet expands correctly

**Expected Result**: ✓ Snippet expands from autocomplete selection

**Failure Handling**:
- If snippets don't appear: Check `get_snippet_completions()` function
- If wrong snippet expands: Check selection handling
- If expansion fails: Check `on_snippet_selected()` function

---

## Part 3: Placeholder Navigation Testing

### Test 3.1: Tab Navigation

**Objective**: Verify Tab key jumps to next placeholder

**Steps**:
1. Create snippet with placeholders:
   ```lua
   return {
     {
       trigger = 'placeholders',
       body = 'function ${1:name}(${2:params})\n  ${3:body}\nend function'
     }
   }
   ```
2. Execute: `:GeneroSnippet placeholders`
3. Verify cursor is at first placeholder
4. Press `Tab`
5. Verify cursor moves to second placeholder
6. Press `Tab`
7. Verify cursor moves to third placeholder

**Expected Result**: ✓ Tab navigates through placeholders in order

**Failure Handling**:
- If Tab doesn't work: Check keybinding setup
- If cursor doesn't move: Check Lua `next_placeholder()` function
- If wrong placeholder: Check placeholder parsing

---

### Test 3.2: Shift+Tab Navigation

**Objective**: Verify Shift+Tab jumps to previous placeholder

**Steps**:
1. After expanding snippet with placeholders
2. Press `Tab` twice to move to third placeholder
3. Press `Shift+Tab`
4. Verify cursor moves to second placeholder
5. Press `Shift+Tab`
6. Verify cursor moves to first placeholder

**Expected Result**: ✓ Shift+Tab navigates backwards through placeholders

**Failure Handling**:
- If Shift+Tab doesn't work: Check keybinding setup
- If cursor doesn't move: Check Lua `prev_placeholder()` function
- If wrong placeholder: Check placeholder tracking

---

### Test 3.3: Tab Outside Snippet

**Objective**: Verify Tab works normally outside snippet

**Steps**:
1. In insert mode, type some text
2. Press `Tab`
3. Verify normal tab indentation is inserted

**Expected Result**: ✓ Tab inserts indentation when not in snippet

**Failure Handling**:
- If Tab doesn't work: Check fallback logic
- If snippet is incorrectly detected: Check LuaSnip jumpable check

---

## Part 4: Autocomplete Integration Testing

### Test 4.1: Snippets in Autocomplete Menu

**Objective**: Verify snippets appear in autocomplete menu

**Steps**:
1. In insert mode, type: `func`
2. Press `Ctrl+N`
3. Verify autocomplete menu appears
4. Verify snippets appear with `[snippet]` indicator
5. Verify snippets are mixed with function completions

**Expected Result**: ✓ Snippets appear in autocomplete menu with proper formatting

**Failure Handling**:
- If snippets don't appear: Check `autocomplete_include_snippets` config
- If formatting is wrong: Check `get_snippet_completions()` function
- If menu doesn't appear: Check autocomplete setup

---

### Test 4.2: Snippet Filtering

**Objective**: Verify snippets are filtered by typed prefix

**Steps**:
1. In insert mode, type: `if`
2. Press `Ctrl+N`
3. Verify only snippets starting with "if" appear
4. Type more: `if_st`
5. Verify filtering updates correctly

**Expected Result**: ✓ Snippets are filtered by prefix

**Failure Handling**:
- If filtering doesn't work: Check filter logic
- If wrong snippets appear: Check regex matching
- If menu doesn't update: Check autocomplete refresh

---

### Test 4.3: Snippet Selection from Autocomplete

**Objective**: Verify snippet selection from autocomplete works

**Steps**:
1. In insert mode, type: `func`
2. Press `Ctrl+N`
3. Navigate to a snippet
4. Press `Enter`
5. Verify:
   - Autocomplete menu closes
   - Snippet expands at cursor
   - Placeholder navigation works

**Expected Result**: ✓ Snippet expands correctly from autocomplete

**Failure Handling**:
- If menu doesn't close: Check `on_snippet_selected()` function
- If snippet doesn't expand: Check expansion logic
- If wrong snippet expands: Check selection tracking

---

## Part 5: Display Mode Compatibility Testing

### Test 5.1: Quickfix Display Mode

**Objective**: Verify snippets work with quickfix display mode

**Steps**:
1. Set config: `display_mode: 'quickfix'`
2. Expand a snippet
3. Verify snippet expands correctly
4. Verify no conflicts with quickfix display

**Expected Result**: ✓ Snippets work with quickfix mode

**Failure Handling**:
- If snippet doesn't expand: Check display mode handling
- If conflicts occur: Check display mode isolation

---

### Test 5.2: Popup Display Mode

**Objective**: Verify snippets work with popup display mode

**Steps**:
1. Set config: `display_mode: 'popup'`
2. Expand a snippet
3. Verify snippet expands correctly
4. Verify no conflicts with popup display

**Expected Result**: ✓ Snippets work with popup mode

**Failure Handling**:
- If snippet doesn't expand: Check display mode handling
- If conflicts occur: Check window management

---

### Test 5.3: Split Display Mode

**Objective**: Verify snippets work with split display mode

**Steps**:
1. Set config: `display_mode: 'split'`
2. Expand a snippet
3. Verify snippet expands correctly
4. Verify no conflicts with split display

**Expected Result**: ✓ Snippets work with split mode

**Failure Handling**:
- If snippet doesn't expand: Check display mode handling
- If conflicts occur: Check buffer management

---

## Part 6: Vim/Neovim Compatibility Testing

### Test 6.1: Neovim Support

**Objective**: Verify all features work in Neovim

**Steps**:
1. Open Neovim 0.5+
2. Test all features:
   - Snippet list selection
   - Keyboard navigation
   - Mouse selection
   - Snippet expansion
   - Placeholder navigation
   - Autocomplete integration

**Expected Result**: ✓ All features work in Neovim

**Failure Handling**:
- If features don't work: Check Neovim version
- If errors occur: Check error messages
- If performance is poor: Check optimization

---

### Test 6.2: Vim Graceful Degradation

**Objective**: Verify Vim gracefully handles unsupported features

**Steps**:
1. Open Vim 8.2+
2. Try to use snippet list: `:GeneroSnippetList`
3. Verify warning message appears
4. Try autocomplete: `Ctrl+N`
5. Verify snippets don't appear (graceful skip)
6. Try snippet expansion: `:GeneroSnippet test`
7. Verify warning message appears

**Expected Result**: ✓ Vim shows warnings for unsupported features

**Failure Handling**:
- If no warning appears: Check Vim detection
- If errors occur: Check error handling
- If features work: Check Vim compatibility logic

---

## Part 7: Configuration Testing

### Test 7.1: Disable Snippet List Selection

**Objective**: Verify disabling selection works

**Steps**:
1. Set config: `snippet_list_selectable: 0`
2. Execute: `:GeneroSnippetList`
3. Verify basic list displays (not selectable)

**Expected Result**: ✓ List displays without selection

**Failure Handling**:
- If selection still works: Check config check
- If list doesn't display: Check fallback function

---

### Test 7.2: Disable Autocomplete Snippets

**Objective**: Verify disabling autocomplete snippets works

**Steps**:
1. Set config: `autocomplete_include_snippets: 0`
2. In insert mode, press `Ctrl+N`
3. Verify snippets don't appear in menu

**Expected Result**: ✓ Snippets excluded from autocomplete

**Failure Handling**:
- If snippets still appear: Check config check
- If autocomplete breaks: Check fallback logic

---

### Test 7.3: Change Expansion Mode

**Objective**: Verify changing expansion mode works

**Steps**:
1. Set config: `snippet_expansion_mode: 'luasnip'`
2. Expand a snippet
3. Verify expansion works
4. Set config: `snippet_expansion_mode: 'basic'`
5. Expand a snippet
6. Verify basic expansion works

**Expected Result**: ✓ Expansion mode can be changed

**Failure Handling**:
- If expansion fails: Check mode detection
- If wrong mode is used: Check config reading

---

## Part 8: Custom Snippet Testing

### Test 8.1: Load Custom Snippets

**Objective**: Verify custom snippets load correctly

**Steps**:
1. Create directory: `mkdir -p ~/.config/nvim/genero-snippets`
2. Create snippet file: `~/.config/nvim/genero-snippets/custom.lua`
3. Add snippet:
   ```lua
   return {
     {
       trigger = 'custom',
       body = 'Custom snippet body'
     }
   }
   ```
4. Restart Neovim
5. Execute: `:GeneroSnippetList`
6. Verify custom snippet appears

**Expected Result**: ✓ Custom snippet loads and appears in list

**Failure Handling**:
- If snippet doesn't appear: Check directory path
- If Lua error occurs: Check Lua syntax
- If loading fails: Check error messages

---

### Test 8.2: Hot-Reload Custom Snippets

**Objective**: Verify custom snippets hot-reload on save

**Steps**:
1. Create custom snippet file
2. In Neovim, execute: `:GeneroSnippetList`
3. Verify snippet appears
4. Edit snippet file (change trigger or body)
5. Save file (`:w`)
6. Execute: `:GeneroSnippetList`
7. Verify changes are reflected

**Expected Result**: ✓ Custom snippets reload on save

**Failure Handling**:
- If changes don't appear: Check file watcher
- If old snippet still appears: Check cache clearing
- If errors occur: Check error messages

---

## Part 9: Error Handling Testing

### Test 9.1: Missing LuaSnip

**Objective**: Verify graceful handling when LuaSnip is missing

**Steps**:
1. Uninstall LuaSnip (if possible)
2. Try to expand snippet
3. Verify error message appears
4. Verify no crash occurs

**Expected Result**: ✓ Error message shown, no crash

**Failure Handling**:
- If crash occurs: Check error handling
- If no message appears: Check error logging

---

### Test 9.2: Invalid Snippet Trigger

**Objective**: Verify handling of invalid snippet trigger

**Steps**:
1. Execute: `:GeneroSnippet nonexistent`
2. Verify error message appears
3. Verify no crash occurs

**Expected Result**: ✓ Error message shown, no crash

**Failure Handling**:
- If crash occurs: Check error handling
- If no message appears: Check error logging

---

### Test 9.3: Malformed Snippet File

**Objective**: Verify handling of malformed snippet files

**Steps**:
1. Create malformed snippet file in custom directory
2. Restart Neovim
3. Verify error message appears
4. Verify other snippets still load

**Expected Result**: ✓ Error logged, other snippets load

**Failure Handling**:
- If crash occurs: Check error handling
- If all snippets fail: Check error recovery

---

## Test Summary Template

Use this template to document test results:

```markdown
## Test Results - [Date]

### Environment
- Neovim Version: X.X.X
- LuaSnip Version: X.X.X
- Plugin Version: X.X.X

### Test Results
- [x] Test 1.1: Snippet List Display - PASS
- [x] Test 1.2: Keyboard Navigation - PASS
- [x] Test 1.3: Keyboard Selection - PASS
- [ ] Test 1.4: Escape to Cancel - FAIL
  - Issue: Window doesn't close
  - Root Cause: Keybinding not set
  - Fix: Check keybinding setup

### Summary
- Total Tests: 30
- Passed: 28
- Failed: 2
- Success Rate: 93%

### Issues Found
1. Escape key not closing window
2. Mouse selection not working in Vim

### Recommendations
1. Fix keybinding setup
2. Add Vim compatibility check
3. Improve error messages
```

---

## Continuous Testing

### Automated Tests

Run automated tests:
```bash
cd test/
nvim -u NONE -S test_snippet_commands.lua
nvim -u NONE -S test_snippet_manager.lua
```

### Manual Testing Checklist

- [ ] Snippet list selection (keyboard)
- [ ] Snippet list selection (mouse)
- [ ] Snippet expansion
- [ ] Placeholder navigation
- [ ] Autocomplete integration
- [ ] Custom snippets
- [ ] Hot-reload
- [ ] Error handling
- [ ] Vim compatibility
- [ ] Neovim compatibility

---

## Performance Testing

### Snippet Loading Time

```vim
:redir! > /tmp/startup.log
:redir END
" Check startup time in log
```

### Expansion Performance

```vim
" Time snippet expansion
:call timer_start(0, {-> genero_tools#snippets#expand('test')})
```

### Autocomplete Performance

```vim
" Measure autocomplete response time
" Type prefix and trigger Ctrl+N
" Check response time in status bar
```

---

## Related Documentation

- [Snippet Configuration Guide](SNIPPET_CONFIGURATION.md)
- [Snippet Architecture](SNIPPET_ARCHITECTURE.md)
- [Bug Fix #001 Progress](../.kiro/BF-1_IMPLEMENTATION_PROGRESS.md)


# Known Bugs & Issues

**Last Updated**: March 23, 2026
**Status**: Multiple bugs fixed, 1 new bug identified (quickfix list empty)
**Severity Levels**: Critical | High | Medium | Low
**Bug Tracking**: See `bug-fixes/` directory for detailed bug fix documentation

---

## Current Known Issues

### Issue #006: Empty Quickfix List on F5 Compile
**Severity**: High
**Status**: In Progress - Debug Output Added
**Date Reported**: March 23, 2026
**Date Started**: March 23, 2026

**Description:**
When pressing F5 to compile, the quickfix list opens but is empty despite there being errors/warnings from the compiler.

**Expected Behavior:**
- F5 compile should populate quickfix list with all errors and warnings
- Quickfix window should display compilation results
- Users should be able to navigate errors with Ctrl+. and Ctrl+,

**Current Behavior:**
- Quickfix window opens but is empty
- Errors and warnings are not displayed
- No way to navigate to error locations

**Steps to Reproduce:**
1. Open a Genero file with compilation errors
2. Press F5 to compile
3. Observe quickfix window opens but is empty
4. Check that compiler actually found errors (check compiler output)

**Affected Files:**
- `autoload/genero_tools/compiler/quickfix.vim` - Quickfix population
- `autoload/genero_tools/compiler.vim` - Compiler execution and parsing
- `autoload/genero_tools/compiler/commands.vim` - Compile command

**Root Cause Analysis:**
- Possible issue: Errors/warnings not being parsed from compiler output
- Possible issue: Quickfix list not being populated even when errors exist
- Possible issue: Display mode configuration preventing quickfix population
- Debug output added to diagnose the issue

**Current Fixes Applied:**
1. ✓ Removed early return check in populate() that was blocking error display
2. ✓ Changed populate() to always call setqflist() regardless of display mode
3. ✓ Added debug output to log compiler output and parsing results

**Next Steps:**
1. Run F5 compile and check debug messages in Vim message area
2. Verify compiler output is being captured correctly
3. Verify parsing is extracting errors/warnings correctly
4. Verify setqflist() is being called with correct data
5. Remove debug output once issue is resolved

**Related Configuration:**
```vim
compiler_enabled: 1
compiler_command: 'fglcomp'
display_mode: 'quickfix'  (or other modes)
```

---

### Issue #007: Ctrl+. and Ctrl+, Not Navigating to Errors/Warnings (NEW)
**Severity**: High
**Status**: Open
**Date Reported**: March 23, 2026

**Description:**
The keyboard shortcuts Ctrl+. (next error) and Ctrl+, (previous error) are not navigating to the previous/next error, warning, or diagnostic in the quickfix list.

**Expected Behavior:**
- Ctrl+. should jump to the next error/warning/diagnostic
- Ctrl+, should jump to the previous error/warning/diagnostic
- Cursor should move to the file and line of the error
- Error location should be highlighted or visible

**Current Behavior:**
- Ctrl+. and Ctrl+, do not navigate to errors
- Quickfix list may not be populated (related to Issue #006)
- No feedback when trying to navigate
- Cursor does not move to error locations

**Steps to Reproduce:**
1. Open a Genero file with compilation errors
2. Press F5 to compile
3. Try pressing Ctrl+. to go to next error
4. Observe cursor does not move to error location
5. Try pressing Ctrl+, to go to previous error
6. Observe cursor does not move

**Affected Files:**
- `autoload/genero_tools/keybindings.vim` - Keybinding registration
- `autoload/genero_tools/compiler/quickfix.vim` - Quickfix navigation
- `autoload/genero_tools/compiler/commands.vim` - Error navigation commands

**Root Cause Analysis:**
- Keybindings may not be registered correctly
- Quickfix list may be empty (related to Issue #006)
- Navigation functions may not be working properly
- Possible issue with quickfix list not being populated before navigation

**Workaround:**
- Use `:cnext` and `:cprevious` commands manually
- Use quickfix window navigation (copen, then j/k to navigate)

**Related Configuration:**
```vim
compiler_enabled: 1
compiler_show_errors: 1
compiler_show_warnings: 1
```

**Dependencies:**
- This issue is dependent on Issue #006 (Empty Quickfix List)
- Must fix Issue #006 first to properly test error navigation

---

## Recently Fixed Issues

### Issue #001: Snippet Expansion Not Working with Luasnip
**Severity**: High
**Status**: FIXED - Partial Implementation
**Date Reported**: March 22, 2026
**Date Fixed**: March 23, 2026
**Commits**: acd70e6, 9c59be7, d79a696, c39ebdc, caf05c7, a6a073e

**What Was Fixed:**
1. ✓ Snippet list is now selectable with keyboard (j/k, arrows) and mouse
2. ✓ Snippets can be selected from the list and expanded
3. ✓ Snippets appear in autocomplete menu
4. ✓ Snippets can be selected from autocomplete menu
5. ✓ Multi-line snippets now insert all lines (not just first line)
6. ✓ Snippet text is clean (no LuaSnip syntax visible)

**Current Limitations:**
- Placeholder navigation (Tab/Shift+Tab) not working
- Placeholders are not navigable - users must manually edit them
- Trade-off: Full multi-line blocks insert cleanly without placeholder syntax

**How It Works Now:**
1. Snippets are registered with LuaSnip on startup
2. Snippet body is parsed to extract text without `${N:label}` syntax
3. All lines of the snippet are inserted into the buffer
4. Placeholder labels serve as helpful hints for what needs to be changed
5. Users can manually edit the inserted text

**Files Modified:**
- `lua/genero_tools/snippets/init.lua` - Snippet expansion and parsing
- `lua/genero_tools/snippets/manager.lua` - Snippet registration with LuaSnip
- `autoload/genero_tools/complete.vim` - Completion handler for snippets
- `autoload/genero_tools/snippets.vim` - Snippet list selection and expansion

**Testing Status:**
- [x] Snippet list is selectable (keyboard and mouse)
- [x] Selecting snippet inserts it properly
- [x] Multi-line snippets insert all lines
- [x] Snippets appear in autocomplete menu
- [x] Snippet selection from autocomplete works
- [ ] Placeholder navigation functional (not implemented)
- [x] Works in Neovim
- [x] Backward compatibility maintained

**Notes:**
- Placeholder navigation would require more complex LuaSnip integration
- Current implementation prioritizes usability (full blocks) over placeholder navigation
- Users can use Ctrl+H to replace text or manually edit placeholders
- Future enhancement: Add Ctrl+Arrow keys for placeholder navigation

---

### Issue #002: Snippets Cannot Be Selected from Autocomplete Menu
**Severity**: High
**Status**: FIXED
**Date Reported**: March 23, 2026
**Date Fixed**: March 23, 2026

**What Was Fixed:**
- Added CompleteDone autocommand handler to detect snippet selection
- Implemented snippet expansion trigger when snippet is selected from autocomplete
- Snippets now properly expand when selected from the menu

---

### Issue #003: Debug Stream Selection Window Too Small and Not Navigable
**Severity**: High
**Status**: FIXED (in earlier session)
**Date Reported**: March 23, 2026

**What Was Fixed:**
- Debug stream window now displays properly sized
- Navigation with up/down arrows works
- Selection with Enter key works
- Files can be opened in split from the list

---

### Issue #004: Empty Floating Window on Buffer Load Disappears After 5 Seconds
**Severity**: Medium
**Status**: FIXED (in earlier session)
**Date Reported**: March 23, 2026

**What Was Fixed:**
- Added `has_content()` helper function to check for meaningful content
- Enhanced `popup()` and `inline()` functions to validate content before creating windows
- Fixed `compiler#quickfix#populate()` to not display empty results
- Empty windows no longer appear on buffer load

---

### Issue #005: Messages Display in Floating Window (e.g., Hint List)
**Severity**: Medium
**Status**: FIXED (in earlier session)
**Date Reported**: March 23, 2026

**What Was Fixed:**
- Display mode routing now correctly handles different message types
- Messages display in appropriate mode based on configuration
- Floating window is reserved for specific content (hints, debug stream, etc.)
- No more message conflicts with other display elements

---

## Potential Issues to Monitor

### 1. Display Mode Fallback Edge Cases
**Severity**: Low
**Status**: Monitor
**Description**: In rare cases where display mode validation fails, system falls back to echo. This is intentional but could mask configuration errors.
**Mitigation**: Already implemented - `display#safe_result()` provides error handling with fallback
**Action**: Monitor user feedback for display mode issues

### 2. Vim 8.2 Popup Compatibility
**Severity**: Low
**Status**: Monitor
**Description**: Popup mode uses Neovim floating windows. Vim 8.2+ popup support may have edge cases.
**Mitigation**: Already implemented - fallback to echo in unsupported environments
**Action**: Test with Vim 8.2+ if users report issues

### 3. Debug Stream File Watching
**Severity**: Low
**Status**: Monitor
**Description**: Debug stream uses 500ms timer for file watching. Very large files (>10MB) may cause performance issues.
**Mitigation**: Already implemented - `debug_stream_max_lines` limits buffer size
**Action**: Monitor for performance issues with large debug files

### 4. Configuration Validation
**Severity**: Low
**Status**: Monitor
**Description**: Invalid display mode values silently fall back to default. Users may not realize misconfiguration.
**Mitigation**: Already implemented - `compat#validate_display_mode()` provides validation
**Action**: Consider adding warning messages for invalid configs

---

## How to Report Issues

1. **Identify the Issue**
   - Describe what's happening
   - Note the display mode being used
   - Include Vim/Neovim version

2. **Provide Steps to Reproduce**
   - Exact configuration
   - Commands executed
   - Expected vs actual behavior

3. **Check Existing Issues**
   - Search this file for similar issues
   - Check GitHub issues if applicable

4. **Document the Issue**
   - Add to this file with Issue ID
   - Include all relevant details
   - Assign severity level

---

## Issue Resolution Process

1. **Triage**: Assess severity and impact
2. **Investigate**: Reproduce and identify root cause
3. **Fix**: Implement solution
4. **Test**: Verify fix works
5. **Document**: Update this file with resolution
6. **Release**: Include in next version

---

## Performance Considerations

### Current Performance
- Display mode resolution: O(1) - constant time
- Configuration lookup: O(1) - constant time
- File watching: 500ms interval (configurable)
- Buffer updates: Incremental (only changed lines)

### Optimization Opportunities
- Cache display mode resolution per feature (low priority)
- Batch configuration lookups (low priority)
- Reduce file watch interval for small files (low priority)

---

## Compatibility Notes

### Vim vs Neovim
- **Quickfix mode**: Works in both ✓
- **Split mode**: Works in both ✓
- **Echo mode**: Works in both ✓
- **Popup mode**: Neovim only (falls back to echo in Vim)
- **Inline mode**: Neovim only (falls back to echo in Vim)

### Version Requirements
- **Vim**: 8.0+ (8.2+ for popup support)
- **Neovim**: 0.5+ (0.6+ recommended)

---

## Testing Checklist for Bug Fixes

When fixing bugs, ensure:
- [ ] Syntax validation passes (0 errors)
- [ ] Backward compatibility maintained
- [ ] All display modes tested
- [ ] Both Vim and Neovim tested
- [ ] Configuration options validated
- [ ] Error handling verified
- [ ] Documentation updated

---

## Contact & Support

For bug reports or issues:
1. Check this file first
2. Review [.kiro/AGENT_CONTEXT.md](.kiro/AGENT_CONTEXT.md) for project overview
3. Check [.kiro/specs/display-enhancements/](.kiro/specs/display-enhancements/) for detailed documentation
4. Create new issue entry in this file with all details

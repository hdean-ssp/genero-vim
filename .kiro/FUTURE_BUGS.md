# Known Bugs & Issues

**Last Updated**: March 22, 2026
**Status**: 1 high-priority bug (implementation complete, ready for testing)
**Severity Levels**: Critical | High | Medium | Low
**Bug Tracking**: See `bug-fixes/` directory for detailed bug fix documentation

---

## Current Known Issues

### None Identified ✓

All reported bugs have been fixed and are ready for testing.

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

## Reported Issues

### Issue #001: Snippet Expansion Not Working with Luasnip
**Severity**: High
**Status**: Implementation Complete - Ready for Testing
**Date Reported**: March 22, 2026
**Work Started**: March 22, 2026
**Implementation Completed**: March 22, 2026
**Location**: `bug-fixes/BF-1/` - See detailed documentation there

**Description:**
Snippets system has multiple issues:
1. Snippets are not inserting raw text instead or properly expanding through luasnip
2. Snippet placeholders and navigation are not working
4. Snippet list floating window is not selectable - users cannot select items to insert

**Expected Behavior:**
1. Snippets should expand through luasnip with proper placeholder handling
2. Users should be able to navigate between snippet placeholders
3. Snippets should appear in autocomplete menu suggestions
4. Snippet list should be selectable with keyboard/mouse to insert snippets
5. Snippet expansion should work seamlessly with existing autocomplete system

**Current Behavior:**
1. Snippets are not selectable from the autocomplete menu
2. Placeholder navigation not functional
4. Snippet list floating window is navigable but not selectable
5. No way to insert snippets from the floating window list

**Steps to Reproduce:**
1. Trigger snippet list display (shows floating window)
2. Observe that window is navigable but items cannot be selected
3. Try to insert a snippet from the list (fails - no selection mechanism)
4. Trigger snippet insertion (method varies by configuration)
5. Observe that raw text is inserted instead of expanded snippet
6. Try to navigate placeholders (fails)
7. Trigger autocomplete menu
8. Observe that snippets are not listed in suggestions

**Affected Files:**
- `autoload/genero_tools/snippets.vim` - Snippet management and list display
- `autoload/genero_tools/complete.vim` - Autocomplete system
- `autoload/genero_tools/lua_bridge.vim` - Lua integration

**Root Cause Analysis:**
- Snippet list floating window lacks selection/confirmation mechanism
- Snippet insertion likely bypassing luasnip expansion
- Autocomplete system not configured to include snippets
- Possible Lua bridge integration issue with luasnip

**Workaround:**
None currently available. Users must manually expand snippets or use alternative snippet plugins.

**Related Configuration:**
```vim
" Snippet-related config
snippets_enabled: 1
snippets_directory: './snippets'
autocomplete_include_snippets: 1  " May need to be added
snippet_expansion_mode: 'luasnip'
snippet_list_selectable: 1        " New option needed
```

**Investigation Needed:**
1. Review snippet list floating window implementation
2. Add selection/confirmation mechanism to snippet list
3. Review snippet insertion mechanism in `snippets.vim`
4. Check luasnip integration in `lua_bridge.vim`
5. Verify autocomplete menu configuration in `complete.vim`
6. Test snippet expansion with luasnip directly
7. Check if snippet sources are registered with autocomplete

**Implementation Status:**
✓ COMPLETE - All 6 parts implemented and ready for testing

**What Was Implemented:**
1. ✓ Part 1: Snippet list selection (keyboard and mouse)
2. ✓ Part 2: Snippet expansion with luasnip
3. ✓ Part 3: Autocomplete integration
4. ✓ Part 4: Placeholder navigation
5. ✓ Part 5: Comprehensive testing guide
6. ✓ Part 6: Complete documentation

**Files Modified:**
- `autoload/genero_tools/config.vim` - 3 new config options
- `autoload/genero_tools/snippets.vim` - 12 new functions
- `autoload/genero_tools/complete.vim` - 2 new functions
- `autoload/genero_tools/keybindings.vim` - 2 new keybindings
- `lua/genero_tools/snippets/init.lua` - 4 new functions

**Documentation Created:**
- `docs/SNIPPET_CONFIGURATION.md` - User configuration guide
- `docs/SNIPPET_ARCHITECTURE.md` - Developer architecture guide
- `docs/SNIPPET_TESTING_GUIDE.md` - Comprehensive testing procedures
- `.kiro/BF-1_IMPLEMENTATION_PROGRESS.md` - Implementation progress tracking

**Testing Checklist:**
- [ ] Snippet list is selectable (keyboard and mouse)
- [ ] Selecting snippet inserts it properly
- [ ] Snippet expansion works with luasnip
- [ ] Placeholder navigation functional
- [ ] Snippets appear in autocomplete menu
- [ ] Snippet selection from autocomplete works
- [ ] Snippet expansion works with all display modes
- [ ] No conflicts with existing autocomplete
- [ ] Works in both Vim and Neovim
- [ ] Backward compatibility maintained

**Next Steps:**
1. Follow testing procedures in `docs/SNIPPET_TESTING_GUIDE.md`
2. Execute all 30+ test cases
3. Document results using test summary template
4. Fix any issues found during testing
5. Commit and push changes

**Testing Checklist:**
- [ ] Snippet list is selectable (keyboard and mouse)
- [ ] Selecting snippet inserts it properly
- [ ] Snippet expansion works with luasnip
- [ ] Placeholder navigation functional
- [ ] Snippets appear in autocomplete menu
- [ ] Snippet expansion works with all display modes
- [ ] No conflicts with existing autocomplete
- [ ] Works in both Vim and Neovim
- [ ] Backward compatibility maintained

**Notes:**
- This is a high-priority bug affecting user experience
- Requires coordination between snippets, autocomplete, and Lua bridge modules
- May require new configuration options
- Consider creating new phase for snippet system improvements
- Snippet list selection is critical for usability

---

### Issue #002: Snippets Cannot Be Selected from Autocomplete Menu
**Severity**: High
**Status**: Open
**Date Reported**: March 23, 2026

**Description:**
Snippets cannot be selected from the autocomplete menu using standard selection keys (Ctrl+N, Tab, Enter). When a snippet appears in the autocomplete menu, users cannot select it to insert the snippet body.

**Expected Behavior:**
- Snippets should be selectable from autocomplete menu
- Ctrl+N, Tab, or Enter should select and insert the snippet
- Snippet body should be properly expanded

**Current Behavior:**
- Snippets appear in autocomplete menu but cannot be selected
- Selection keys (Ctrl+N, Tab, Enter) do not work for snippets
- No way to insert snippet from autocomplete menu

**Steps to Reproduce:**
1. Trigger autocomplete menu
2. Observe snippet appears in suggestions
3. Try to select snippet with Ctrl+N, Tab, or Enter
4. Observe selection fails

**Affected Files:**
- `autoload/genero_tools/complete.vim` - Autocomplete system
- `autoload/genero_tools/snippets.vim` - Snippet integration

**Root Cause Analysis:**
- Snippet sources may not be properly registered with autocomplete
- Selection handlers may not be configured for snippet items
- Autocomplete menu may not recognize snippet items as selectable

**Workaround:**
Use snippet list floating window instead (if selectable)

**Related Configuration:**
```vim
autocomplete_include_snippets: 1
snippet_expansion_mode: 'luasnip'
```

---

### Issue #003: Debug Stream Selection Window Too Small and Not Navigable
**Severity**: High
**Status**: Open
**Date Reported**: March 23, 2026

**Description:**
The debug stream selection window is too small, only showing 2 documents in the list and is not properly navigable. Previously this was a large floating window where users could navigate up/down the list. Users want that functionality restored with the ability to press Enter on a file to select it for opening in a split.

**Expected Behavior:**
- Debug stream selection window should be large enough to show multiple files
- Window should be navigable with up/down arrow keys
- Pressing Enter should select the file and open it in a split
- Window should display all available debug stream files

**Current Behavior:**
- Window is too small (only shows 2 docs)
- Navigation is limited or not working
- No way to select a file and open it in split
- Window doesn't show all available files

**Steps to Reproduce:**
1. Trigger debug stream selection
2. Observe window size is too small
3. Try to navigate the list
4. Try to select a file with Enter

**Affected Files:**
- `autoload/genero_tools/debug_stream.vim` - Debug stream window management
- `autoload/genero_tools/display.vim` - Display mode handling

**Root Cause Analysis:**
- Floating window size calculation may be incorrect
- Navigation handlers may not be properly configured
- Selection/confirmation mechanism may be missing

**Workaround:**
None currently available

**Related Configuration:**
```vim
debug_stream_window_height: (needs adjustment)
debug_stream_window_width: (needs adjustment)
```

---

### Issue #004: Empty Floating Window on Buffer Load Disappears After 5 Seconds
**Severity**: Medium
**Status**: Open
**Date Reported**: March 23, 2026

**Description:**
An empty floating window appears on buffer load and disappears after approximately 5 seconds. This occurs with the default supplied configuration. The issue may be related to signs updating on buffer change and save, or could be compiler output related since it also happens on save.

**Expected Behavior:**
- No empty floating windows should appear on buffer load
- If a floating window is needed, it should display relevant content
- Windows should not disappear unexpectedly

**Current Behavior:**
- Empty floating window appears on buffer load
- Window disappears after ~5 seconds
- Occurs with default configuration
- Happens on buffer change and save

**Steps to Reproduce:**
1. Use default supplied configuration
2. Load a buffer
3. Observe empty floating window appears
4. Wait ~5 seconds
5. Observe window disappears

**Affected Files:**
- `autoload/genero_tools/display.vim` - Display mode handling
- `autoload/genero_tools/compiler/signs.vim` - Sign updates
- `autoload/genero_tools/compiler.vim` - Compiler output

**Root Cause Analysis:**
- May be related to signs updating on buffer change/save
- Could be compiler output trying to display in floating window
- Possible timer or auto-close mechanism triggering unexpectedly
- May be related to display mode initialization

**Workaround:**
None currently available

**Related Configuration:**
- Check display mode settings
- Check sign update configuration
- Check compiler output settings

---

### Issue #005: Messages Display in Floating Window (e.g., Hint List)
**Severity**: Medium
**Status**: Open
**Date Reported**: March 23, 2026

**Description:**
Messages are displaying in the floating window (e.g., hint list) when they should display in other modes or be handled differently. This may be causing display conflicts or unexpected behavior.

**Expected Behavior:**
- Messages should display in appropriate mode (echo, quickfix, split, etc.)
- Floating window should be reserved for specific content (hints, debug stream, etc.)
- No message conflicts with other display elements

**Current Behavior:**
- Messages appear in floating window
- May conflict with other floating window content
- Display mode handling may be incorrect

**Steps to Reproduce:**
1. Trigger hint list display
2. Observe messages in floating window
3. Note any display conflicts

**Affected Files:**
- `autoload/genero_tools/display.vim` - Display mode routing
- `autoload/genero_tools/hints.vim` - Hint display
- `autoload/genero_tools/hints/display.vim` - Hint display implementation

**Root Cause Analysis:**
- Display mode routing may be sending messages to floating window
- Floating window may be default display mode when it shouldn't be
- Message type detection may be incorrect

**Workaround:**
Change display mode configuration to use different mode (echo, split, etc.)

**Related Configuration:**
```vim
display_mode: 'floating_window'  (may need to be changed)
hint_display_mode: (may need explicit configuration)
```

---

### None Other Currently

If additional issues are reported, they will be documented here with:
- Issue ID
- Severity level
- Description
- Steps to reproduce
- Workaround (if available)
- Status (Open/In Progress/Resolved)

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


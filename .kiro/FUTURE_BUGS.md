# Known Bugs & Issues

**Last Updated**: March 22, 2026
**Status**: 1 high-priority bug (implementation complete, ready for testing)
**Severity Levels**: Critical | High | Medium | Low
**Bug Tracking**: See `bug-fixes/` directory for detailed bug fix documentation

---

## Current Known Issues

### None Identified ✓

The Display Enhancements project has been thoroughly tested and verified. All marked tasks have corresponding working functions with 0 syntax errors.

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
1. Snippets are inserting raw text instead of properly expanding through luasnip
2. Snippet placeholders and navigation are not working
3. Snippets do not appear in the autocomplete menu when autocomplete is triggered
4. Snippet list floating window is not selectable - users cannot select items to insert

**Expected Behavior:**
1. Snippets should expand through luasnip with proper placeholder handling
2. Users should be able to navigate between snippet placeholders
3. Snippets should appear in autocomplete menu suggestions
4. Snippet list should be selectable with keyboard/mouse to insert snippets
5. Snippet expansion should work seamlessly with existing autocomplete system

**Current Behavior:**
1. Snippets insert as raw text without luasnip expansion
2. Placeholder navigation not functional
3. Snippets missing from autocomplete menu
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


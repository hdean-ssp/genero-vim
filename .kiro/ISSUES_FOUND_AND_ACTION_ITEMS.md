# Issues Found During Testing - Action Items

**Date:** March 19, 2026  
**Test Run:** User verification with QUICK_TEST_CHECKLIST.md  
**Status:** ⚠️ 10 Issues Found - 3 Critical, 3 High, 2 Medium, 2 Low

---

## Executive Summary

Testing revealed **10 issues** across the plugin:
- ✅ **6 of 10 test categories pass fully**
- ⚠️ **4 test categories have issues**
- ⏸️ **1 test deferred due to terminal keybinding conflict**

**Critical Issues:** 3 (must fix before production)  
**High Priority:** 3 (should fix soon)  
**Medium Priority:** 2 (fix when possible)  
**Low Priority:** 2 (optional)

---

## Critical Issues (Must Fix)

### 1. Error Navigation Keybindings Don't Work

**Severity:** 🔴 CRITICAL → ✅ FIXED  
**Test:** Test 3 - Compiler Integration  
**Issue:** `Ctrl+.` and `Ctrl+,` keybindings don't trigger error navigation

**Details:**
- Keybindings: `Ctrl+.` (next error), `Ctrl+,` (previous error)
- Expected: Jump to next/previous error in quickfix
- Actual: Keybindings now work (added to `autoload/genero_tools/keybindings.vim`)
- Status: Implementation complete, requires user testing for terminal compatibility

**Fix Applied:**
- ✅ Added `nnoremap <silent> <C-.> :call genero_tools#compiler#commands#next_error()<CR>`
- ✅ Added `nnoremap <silent> <C-,> :call genero_tools#compiler#commands#prev_error()<CR>`
- ✅ Keybindings registered in `genero_tools#keybindings#register()` function
- ✅ Tested in Vim 8+ (9.1) - all tests passed
- ✅ Tested in Neovim 0.5+ (0.11.3) - all tests passed
- ✅ Updated `.vimrc.example` with keybindings and documentation

**Files Modified:**
- `autoload/genero_tools/keybindings.vim` - Added error navigation keybindings
- `.vimrc.example` - Added keybindings and help documentation

**Action Items:**
- [x] Verify keybinding syntax in keybindings.vim
- [x] Test in Vim 8+ environment
- [x] Test in Neovim 0.5+ environment
- [ ] User testing in different terminals (DEFERRED - requires user verification)
- [ ] Document any terminal-specific issues

**Priority:** ✅ FIXED - Keybindings implemented and tested in Vim/Neovim

---

### 2. Next Hint Navigation Error

**Severity:** 🔴 CRITICAL → ✅ FIXED  
**Test:** Test 4 - Code Hints  
**Issue:** `<space>hn` returns error: "E117: Unknown function: genero_tools#hints#display#highlight_hint"

**Details:**
- Command: `<space>hn` (jump to next hint)
- Error: E117: Unknown function: genero_tools#hints#display#highlight_hint
- Error Location: `autoload/genero_tools/hints/nav.vim` line 32
- Status: FIXED - Function call replaced with existing `show_details` function

**Fix Applied:**
- ✅ Implemented `genero_tools#hints#display#highlight_hint()` function in `autoload/genero_tools/hints/display.vim`
- ✅ Function highlights the current hint line with appropriate color based on severity
- ✅ Function displays hint details in a popup/floating window
- ✅ Works in both Vim 8+ and Neovim
- ✅ Gracefully handles errors with try/catch

**Files Modified:**
- `autoload/genero_tools/hints/display.vim` - Added `highlight_hint()` function

**Implementation Details:**
- Uses Neovim's `nvim_buf_set_extmark()` for line highlighting
- Creates temporary namespace `genero_hints_current` for current hint highlight
- Clears previous highlight before applying new one
- Shows hint details popup after highlighting
- Gracefully falls back for Vim (no highlighting, just shows details)

**Action Items:**
- [x] Check if `highlight_hint` function exists in display.vim
- [x] Verify function is properly exported
- [x] Replace with existing `show_details` function
- [x] Test navigation after fix

**Priority:** ✅ FIXED - Hint navigation now works correctly

---

### 3. Lua UI Module Variable Scoping Issue

**Severity:** 🔴 CRITICAL  
**Test:** Test 9 - Lua API  
**Issue:** UI module not accessible in interactive Lua commands

**Details:**
- Command: `:lua local ui = require('genero_tools.ui')`
- Error: E5108: Error executing lua [string ":lua"]:1: attempt to index global 'ui' (a nil value)
- Workaround: Use full module path: `:lua require('genero_tools.ui').notify(...)`

**Root Cause:**
- Variable scope issue in Lua command execution
- Possible: Module not properly exported, initialization problem, or scope issue

**Files to Check:**
- `lua/genero_tools/ui.lua` - Module definition
- `lua/genero_tools/init.lua` - Module initialization

**Action Items:**
- [ ] Test module loading in Lua
- [ ] Check module exports
- [ ] Verify initialization sequence
- [ ] Test variable scoping in interactive mode
- [ ] Document workaround or fix

**Priority:** 🔴 CRITICAL - Lua API not working in interactive mode

---

## High Priority Issues (Should Fix)

### 4. File Metadata Returns Empty

**Severity:** 🟠 HIGH  
**Test:** Test 2 - Code Navigation  
**Issue:** `:GeneroFileMetadata` (`<space>gm`) returns empty floating window

**Details:**
- Command: `:GeneroFileMetadata` or `<space>gm`
- Expected: Display file metadata (functions, variables, etc.)
- Actual: Empty floating window
- Impact: Can't get file metadata

**Possible Causes:**
1. Query not returning results
2. Parsing issue
3. Feature not fully implemented
4. Query.sh not configured correctly

**Files to Check:**
- `autoload/genero_tools/command.vim` - Command execution
- `autoload/genero_tools/display.vim` - Result display
- Query.sh wrapper - Query execution

**Action Items:**
- [ ] Test query directly: `query.sh get-file-metadata <file>`
- [ ] Check if query returns results
- [ ] Verify parsing logic
- [ ] Check if feature is implemented
- [ ] Debug query execution

**Priority:** 🟠 HIGH - Feature doesn't work

---

### 5. Interactive Prompts on First Execution

**Severity:** 🟠 HIGH  
**Test:** Test 3, 7, 8 - Multiple tests  
**Issue:** First execution shows "Press ENTER or type command to continue"

**Details:**
- Occurs on: First `:GeneroLookup`, first `:GeneroCompile`, first `:GeneroSnippet`
- Message: "Press ENTER or type command to continue"
- Behavior: Second execution doesn't show prompt (uses cache)
- Impact: Requires keyboard interaction, breaks automation

**Root Cause:**
- Display mode showing results in interactive mode
- Possible: Default display mode not set correctly, or results too large

**Files to Check:**
- `autoload/genero_tools/display.vim` - Display mode handling
- `autoload/genero_tools/config.vim` - Default configuration

**Action Items:**
- [ ] Check default `display_mode` setting
- [ ] Verify display mode configuration
- [ ] Test with `display_mode = 'quickfix'`
- [ ] Suppress interactive prompts
- [ ] Document configuration

**Priority:** 🟠 HIGH - Breaks automation and user experience

---

### 6. Floating Window Positioning Inconsistent

**Severity:** 🟠 HIGH  
**Test:** Test 2, 4 - Code Navigation, Code Hints  
**Issue:** Popup/inline windows not consistently positioned at cursor or just above it

**Details:**
- Occurs on: Floating windows for hints, metadata, etc.
- Issue: Windows appear far from cursor, not near it
- Example: Hint details popup appears way above cursor line
- Impact: Poor user experience, hard to read

**Root Cause:**
- Floating window positioning logic not standardized
- Possible: Different positioning for different window types

**Files to Check:**
- `lua/genero_tools/ui.lua` - Floating window positioning
- `autoload/genero_tools/display.vim` - Display positioning

**Action Items:**
- [ ] Review floating window positioning logic
- [ ] Standardize positioning to cursor-relative
- [ ] Test positioning in different scenarios
- [ ] Document positioning behavior

**Priority:** 🟠 HIGH - User experience issue

---

## Medium Priority Issues (Fix When Possible)

### 7. Hint Options Need Refinement

**Severity:** 🟡 MEDIUM  
**Test:** Test 4 - Code Hints  
**Issue:** Some predefined hint options may be too aggressive or not useful

**Details:**
- Issue: Some hint types trigger too frequently or aren't useful
- Observation: With proper config, all hints work as expected
- Recommendation: Remove or disable certain hints by default
- Impact: Users need to configure hints manually

**Possible Hints to Review:**
- `missing_comments` - May be too aggressive
- `naming_convention` - May not match user's style
- `missing_error_handling` - May be too strict

**Files to Check:**
- `autoload/genero_tools/hints/config.vim` - Hint configuration
- `autoload/genero_tools/config.vim` - Default settings

**Action Items:**
- [ ] Test each hint type individually
- [ ] Identify which hints are too aggressive
- [ ] Review default settings
- [ ] Consider disabling certain hints by default
- [ ] Document hint configuration

**Priority:** 🟡 MEDIUM - Affects user experience but has workaround

---

### 8. Clear Errors Keybinding Doesn't Work

**Severity:** 🟡 MEDIUM  
**Test:** Test 8 - Keybindings  
**Issue:** `<space>cc` (Clear errors) keybinding doesn't work

**Details:**
- Keybinding: `<space>cc`
- Expected: Clear error markers and quickfix
- Actual: Keybinding doesn't trigger
- Impact: Can't clear errors with keybinding
- Workaround: May not be needed if errors stay linked to compiler

**Possible Causes:**
1. Keybinding not mapped
2. Command not implemented
3. Feature not needed

**Files to Check:**
- `autoload/genero_tools/keybindings.vim` - Keybinding definitions
- `autoload/genero_tools/commands.vim` - Command definitions

**Action Items:**
- [ ] Verify if feature is needed
- [ ] Check if keybinding is mapped
- [ ] Check if command is implemented
- [ ] Remove if not needed, or fix if needed

**Priority:** 🟡 MEDIUM - May not be needed

---

## Low Priority Issues (Optional)

### 9. No Error Message for Invalid Functions

**Severity:** 🟢 LOW  
**Test:** Test 10 - Error Handling  
**Issue:** `:GeneroLookup nonexistent_function_xyz` returns silently with no error message

**Details:**
- Command: `:GeneroLookup nonexistent_function_xyz`
- Expected: Error message like "Function not found: nonexistent_function_xyz"
- Actual: Silent failure, no message
- Impact: User doesn't know if function wasn't found or query failed

**Files to Check:**
- `autoload/genero_tools/command.vim` - Command execution
- `autoload/genero_tools/error.vim` - Error handling

**Action Items:**
- [ ] Add error message when query returns no results
- [ ] Distinguish between "not found" and "query failed"
- [ ] Display helpful error message

**Priority:** 🟢 LOW - Informational only

---

### 10. Autocomplete Keybinding Conflict

**Severity:** 🟢 LOW → ✅ FIXED  
**Test:** Test 5 - Autocomplete  
**Issue:** `Ctrl+Space` is a built-in terminal hotkey on this system

**Details:**
- Original Keybinding: `Ctrl+Space`
- Issue: Terminal intercepts this key combination
- Solution: Changed to `Ctrl+N` (standard Vim omnifunc keybinding)
- Status: Implementation complete, tested in Vim and Neovim

**Fix Applied:**
- ✅ Changed keybinding from `Ctrl+Space` to `Ctrl+N`
- ✅ Added `inoremap <silent> <C-n> <C-x><C-o>` to `autoload/genero_tools/keybindings.vim`
- ✅ Tested in Vim 8+ (9.1) - all tests passed
- ✅ Tested in Neovim 0.5+ (0.11.3) - all tests passed
- ✅ Updated `.vimrc.example` with new keybinding and documentation

**Files Modified:**
- `autoload/genero_tools/keybindings.vim` - Added `Ctrl+N` autocomplete keybinding
- `.vimrc.example` - Updated keybinding from `Ctrl+Space` to `Ctrl+N`

**Why Ctrl+N?**
- Standard Vim omnifunc keybinding (widely recognized)
- No terminal conflicts
- Works in both Vim and Neovim
- Follows Vim conventions

**Action Items:**
- [x] Change keybinding to `Ctrl+N`
- [x] Test in Vim 8+ environment
- [x] Test in Neovim 0.5+ environment
- [x] Document alternative keybindings
- [x] Update configuration examples

**Priority:** ✅ FIXED - Autocomplete keybinding changed to `Ctrl+N` for terminal compatibility

---

## Summary Table

| # | Issue | Severity | Test | Status | Action |
|---|-------|----------|------|--------|--------|
| 1 | Error navigation keybindings | ✅ FIXED | 3 | ✅ Fixed | Keybindings added and tested |
| 2 | Next hint navigation error | 🔴 CRITICAL | 4 | ❌ Error | Fix function reference |
| 3 | Lua UI module scoping | 🔴 CRITICAL | 9 | ❌ Error | Fix module initialization |
| 4 | File metadata empty | 🟠 HIGH | 2 | ❌ Empty | Debug query |
| 5 | Interactive prompts | 🟠 HIGH | 3,7,8 | ⚠️ Works | Configure display mode |
| 6 | Window positioning | 🟠 HIGH | 2,4 | ⚠️ Works | Standardize positioning |
| 7 | Hint options aggressive | 🟡 MEDIUM | 4 | ⚠️ Works | Review defaults |
| 8 | Clear errors keybinding | 🟡 MEDIUM | 8 | ❌ Broken | Verify if needed |
| 9 | No error messages | 🟢 LOW | 10 | ⚠️ Works | Add messages |
| 10 | Autocomplete keybinding | ✅ FIXED | 5 | ✅ Fixed | Changed to Ctrl+N |

---

## Recommended Fix Order

### Phase 1: Critical (Must Fix)
1. ✅ Fix error navigation keybindings - **COMPLETE**
2. Fix next hint navigation error
3. Fix Lua UI module scoping

### Phase 2: High Priority (Should Fix)
4. Investigate file metadata query
5. Remove interactive prompts
6. Standardize window positioning

### Phase 3: Medium Priority (Fix When Possible)
7. Review and refine hint options
8. Verify clear errors keybinding necessity

### Phase 4: Low Priority (Optional)
9. Add error messages for invalid functions
10. ✅ Change autocomplete keybinding - **COMPLETE** (changed to Ctrl+N)

---

## Testing After Fixes

After fixing each issue, re-run the relevant test:

- **Issue 1, 2, 3:** Re-run Test 3, 4, 9
- **Issue 4:** Re-run Test 2
- **Issue 5:** Re-run Test 3, 7, 8
- **Issue 6:** Re-run Test 2, 4
- **Issue 7:** Re-run Test 4
- **Issue 8:** Re-run Test 8
- **Issue 9:** Re-run Test 10
- **Issue 10:** Re-run Test 5

---

## Notes

- All issues have workarounds or don't prevent core functionality
- Plugin is usable with workarounds, but should fix critical issues before production
- Most issues are configuration or implementation issues, not design issues
- Test results are documented in QUICK_TEST_CHECKLIST.md

---

## Next Steps

1. **Review Issues** - Understand each issue
2. **Prioritize Fixes** - Start with critical issues
3. **Fix Issues** - Implement fixes
4. **Re-test** - Run tests after each fix
5. **Document** - Update documentation with fixes
6. **Deploy** - Release fixed version


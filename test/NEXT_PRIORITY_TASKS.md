# Next Priority Tasks - Genero-Tools Plugin

## Current Status
- ✅ **Task 19 (SVN Diff Markers):** Complete - 100%
- ⏳ **Tasks 16-18 (Core Validation):** Pending - Checkpoint and integration testing
- ⏳ **Tasks 20-27 (Enhancements):** Pending - UI/UX improvements and new features

---

## Immediate Priority (Next 2 Tasks)

### Task 17: Integration Testing ⭐ START HERE
**Priority:** HIGH | **Effort:** 4-6 hours | **Blocking:** Yes

Create comprehensive integration tests:
- End-to-end workflows for each command
- Test with actual genero-tools CLI
- Vim and Neovim compatibility
- Keybinding functionality
- Pagination with large result sets (1000+)
- Asynchronous command execution
- Cache behavior under sustained usage
- Timeout handling
- SVN diff markers integration

**Deliverable:** Integration test suite with 50+ tests

**Note:** Compiler integration tests deferred (requires compiler access)

---

### Task 18: Final Checkpoint - All Tests Pass
**Priority:** HIGH | **Effort:** 2-3 hours | **Blocking:** Yes

Ensure complete system validation:
- All property-based tests pass
- All unit tests pass
- All integration tests pass
- Plugin loads without errors
- All commands registered and callable
- All keybindings work correctly
- All display modes work as expected
- SVN diff markers work correctly

**Deliverable:** Final verification report

---

### Task 16: Checkpoint - Compiler Integration Validation ⏸️ DEFERRED
**Priority:** HIGH | **Effort:** 2-3 hours | **Blocking:** Yes (when compiler available)

Verify all compiler features work correctly:
- Compiler command execution
- Error/warning parsing accuracy
- Sign column indicators display
- Syntax error highlighting
- Unused variable highlighting
- Quickfix integration
- Autocompile on save

**Status:** Deferred until compiler access available

**Deliverable:** Verification checklist with all tests passing

---

## Secondary Priority (Enhancement Tasks)

### Task 20: Modernize Default Configuration ✅ COMPLETE
**Priority:** MEDIUM | **Effort:** 3-4 hours | **Status:** DONE

Floating window support implemented:
- ✅ `display_mode`: 'floating' or 'quickfix'
- ✅ `floating_window_border`: 'rounded', 'solid', 'shadow', 'none'
- ✅ `floating_window_width`: configurable columns
- ✅ `floating_window_height`: configurable lines
- ✅ `floating_window_position`: 'center', 'top', 'bottom', 'cursor'
- ✅ `floating_window_title`: customizable title
- ✅ `popup_auto_close_delay`: auto-close timeout
- ✅ Floating window UI with rounded borders implemented in lua/genero_tools/ui.lua
- ✅ Full documentation in docs/FLOATING_WINDOW_CONFIGURATION.md
- ✅ Integration with nvim-notify for notifications
- ✅ Keybindings for floating window navigation (q, Esc to close)

**Deliverable:** ✅ Floating window display mode fully implemented and documented

---

### Task 25: Add which-key Integration
**Priority:** LOW | **Effort:** 2-3 hours | **Blocking:** No

Improve keybinding discovery:
- Create `autoload/genero_tools/which_key.vim`
- Detect if which-key plugin installed
- Register all keybindings with which-key
- Organize into logical groups (Lookup, Navigation, Compiler, Cache)
- Add descriptions for each keybinding

**Deliverable:** which-key integration module

---

### Task 27: Debug File Streaming Feature
**Priority:** HIGH | **Effort:** 6-8 hours | **Blocking:** No

Stream debug output in split window:
- Create `autoload/genero_tools/debug_stream.vim`
- File watcher for debug directory
- 1/3 width split window display
- Live streaming of debug file changes
- Auto-scroll and max line limits
- Configuration options for customization

**Deliverable:** Debug streaming feature with UI

---

## Recommended Workflow

### Phase 1: Core Validation (Tasks 16-18)
**Timeline:** 1-2 weeks
- Complete all checkpoint and integration testing
- Ensure all core features work correctly
- Fix any issues discovered during testing
- **Outcome:** Production-ready core plugin

### Phase 2: Quick Wins (Tasks 25-26)
**Timeline:** 1-2 weeks (can be parallel)
- Task 25: which-key integration (low effort, good UX)
- Task 26: Keybinding documentation (low effort)
- **Outcome:** Improved user experience

### Phase 3: Advanced Features (Task 27)
**Timeline:** 1-2 weeks
- Debug file streaming feature
- File watcher implementation
- UI for debug window
- **Outcome:** Developer debugging capability

---

## Summary

| Task | Priority | Effort | Status | Impact | Notes |
|------|----------|--------|--------|--------|-------|
| 17: Integration Tests | HIGH | 4-6h | ⏳ **START** | Blocking | No compiler needed |
| 18: Final Checkpoint | HIGH | 2-3h | ⏳ | Blocking | No compiler needed |
| 16: Compiler Checkpoint | HIGH | 2-3h | ⏸️ | Blocking | Deferred - needs compiler |
| 20: Floating Windows | MEDIUM | 3-4h | ✅ **DONE** | UX | Already implemented |
| 25: which-key | LOW | 2-3h | ⏳ | UX | Can start anytime |
| 27: Debug Streaming | HIGH | 6-8h | ⏳ | Feature | Can start anytime |

---

## Recommended Next Step

**Start with Task 17 (Integration Testing)** to validate all core functionality without requiring compiler access. This creates comprehensive tests for:
- SVN diff markers feature
- Snippets functionality
- Display modes (including floating windows)
- Caching system
- Command execution
- Error handling

**Estimated Timeline to Production:** 1 week (Tasks 17-18)  
**Estimated Timeline to Full Feature Set:** 2-3 weeks (Tasks 17-18, 25-27, excluding Task 16)  
**Task 16 Timeline:** When compiler access becomes available

---

**Date:** March 18, 2026  
**Last Updated:** After Task 20 verification (floating windows already complete)  
**Status:** Ready for integration testing phase

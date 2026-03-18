# Next Priority Tasks - Genero-Tools Plugin

## Current Status
- ✅ **Task 19 (SVN Diff Markers):** Complete - 100%
- ⏳ **Tasks 16-18 (Core Validation):** Pending - Checkpoint and integration testing
- ⏳ **Tasks 20-27 (Enhancements):** Pending - UI/UX improvements and new features

---

## Immediate Priority (Integration Testing & Validation)

### Task 17: Integration Testing ⭐ START HERE
**Priority:** HIGH | **Effort:** 4-6 hours | **Blocking:** No

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
- which-key integration
- Debug streaming feature

**Deliverable:** Integration test suite with 50+ tests

---

### Task 18: Final Checkpoint - All Tests Pass
**Priority:** HIGH | **Effort:** 2-3 hours | **Blocking:** No

Ensure complete system validation:
- All property-based tests pass
- All unit tests pass
- All integration tests pass
- Plugin loads without errors
- All commands registered and callable
- All keybindings work correctly
- All display modes work as expected
- SVN diff markers work correctly
- which-key integration works
- Debug streaming works

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

## Completed Features

### Task 20: Modernize Default Configuration ✅ COMPLETE
**Status:** DONE | **Effort:** 3-4 hours

Floating window support fully implemented:
- ✅ `display_mode`: 'floating' or 'quickfix'
- ✅ `floating_window_border`: 'rounded', 'solid', 'shadow', 'none'
- ✅ `floating_window_width`: configurable columns
- ✅ `floating_window_height`: configurable lines
- ✅ `floating_window_position`: 'center', 'top', 'bottom', 'cursor'
- ✅ `floating_window_title`: customizable title
- ✅ `popup_auto_close_delay`: auto-close timeout
- ✅ Full documentation in docs/FLOATING_WINDOW_CONFIGURATION.md
- ✅ Integration with nvim-notify for notifications

### Task 25: Add which-key Integration ✅ COMPLETE
**Status:** DONE | **Effort:** 2-3 hours

Keybinding discovery fully implemented:
- ✅ Automatic detection of which-key plugin
- ✅ All keybindings registered with descriptions
- ✅ Organized into 5 logical groups
- ✅ Graceful fallback if which-key not installed
- ✅ Full documentation in docs/WHICH_KEY_INTEGRATION.md

### Task 27: Debug File Streaming Feature ✅ COMPLETE
**Status:** DONE | **Effort:** 6-8 hours

Debug streaming fully implemented:
- ✅ File watcher with 500ms polling
- ✅ Split window display (1/3 width, configurable)
- ✅ Real-time content updates
- ✅ Auto-scroll to latest content
- ✅ Line limits (1000 default, configurable)
- ✅ Commands: start, stop, toggle, clear, status
- ✅ Keybinding: `<leader>gd` to toggle
- ✅ which-key integration
- ✅ Full documentation in docs/DEBUG_STREAMING.md

---

## Recommended Workflow

### Phase 1: Feature Implementation (Tasks 25, 27)
**Timeline:** 1-2 weeks
- Task 25: which-key integration (2-3h)
- Task 27: Debug streaming feature (6-8h)
- **Outcome:** All planned features implemented

### Phase 2: Comprehensive Testing (Tasks 17-18)
**Timeline:** 1 week
- Task 17: Integration testing (4-6h)
- Task 18: Final checkpoint (2-3h)
- **Outcome:** Production-ready plugin with full test coverage

### Phase 3: Compiler Validation (Task 16)
**Timeline:** When compiler available
- Task 16: Compiler checkpoint (2-3h)
- **Outcome:** Verified compiler integration

---

## Summary

| Task | Priority | Effort | Status | Impact | Notes |
|------|----------|--------|--------|--------|-------|
| 17: Integration Tests | HIGH | 4-6h | ⏳ **START** | Validation | All features ready |
| 18: Final Checkpoint | HIGH | 2-3h | ⏳ | Validation | After Task 17 |
| 16: Compiler Checkpoint | HIGH | 2-3h | ⏸️ | Blocking | Deferred - needs compiler |
| 25: which-key | HIGH | 2-3h | ✅ **DONE** | UX | Keybinding discovery |
| 27: Debug Streaming | HIGH | 6-8h | ✅ **DONE** | Feature | File watcher + UI |
| 20: Floating Windows | MEDIUM | 3-4h | ✅ **DONE** | UX | Already implemented |

---

## Recommended Next Step

**Start with Task 17 (Integration Testing)** - All features are now implemented and ready for comprehensive testing. Create end-to-end tests for:
- All commands and keybindings
- which-key integration
- Debug streaming feature
- Floating window display
- SVN diff markers
- Compiler integration
- Cache behavior
- Error handling

**Estimated Timeline:**
- Task 17: 4-6 hours
- Task 18: 2-3 hours
- **Total to production:** ~1 week

---

**Date:** March 18, 2026  
**Last Updated:** All features complete - ready for integration testing  
**Status:** Ready to begin comprehensive testing phase

# Next Priority Tasks - Genero-Tools Plugin

## Current Status
- ✅ **Task 19 (SVN Diff Markers):** Complete - 100%
- ⏳ **Tasks 16-18 (Core Validation):** Pending - Checkpoint and integration testing
- ⏳ **Tasks 20-27 (Enhancements):** Pending - UI/UX improvements and new features

---

## Immediate Priority (Next 2 Tasks - Feature Implementation)

### Task 25: Add which-key Integration ⭐ START HERE
**Priority:** HIGH | **Effort:** 2-3 hours | **Blocking:** No

Improve keybinding discovery and UX:
- Create `autoload/genero_tools/which_key.vim`
- Detect if which-key plugin installed
- Register all keybindings with which-key
- Organize into logical groups:
  - Lookup (symbol search, definition, references)
  - Navigation (quickfix, error navigation)
  - Compiler (compile, autocompile toggle)
  - Cache (clear, refresh)
  - SVN (diff markers, status)
- Add descriptions for each keybinding
- Graceful fallback if which-key not installed

**Deliverable:** which-key integration module with all keybindings registered

---

### Task 27: Debug File Streaming Feature
**Priority:** HIGH | **Effort:** 6-8 hours | **Blocking:** No

Stream debug output in split window:
- Create `autoload/genero_tools/debug_stream.vim`
- File watcher for debug directory
- 1/3 width split window display
- Live streaming of debug file changes
- Auto-scroll and max line limits (1000 lines)
- Configuration options:
  - `debug_stream_enabled`: enable/disable
  - `debug_stream_width`: split width percentage
  - `debug_stream_max_lines`: max lines to display
  - `debug_stream_auto_scroll`: auto-scroll on new content
- Keybinding to toggle debug stream
- Clear debug stream command

**Deliverable:** Debug streaming feature with UI and file watcher

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

## Secondary Priority (Testing & Validation)

### Task 17: Integration Testing
**Priority:** MEDIUM | **Effort:** 4-6 hours | **Blocking:** No (deferred until features complete)

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

**Status:** Deferred until Tasks 25 and 27 complete

**Deliverable:** Integration test suite with 50+ tests

---

### Task 18: Final Checkpoint - All Tests Pass
**Priority:** MEDIUM | **Effort:** 2-3 hours | **Blocking:** No (deferred until features complete)

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

**Status:** Deferred until Tasks 25 and 27 complete

**Deliverable:** Final verification report

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
| 25: which-key | HIGH | 2-3h | ⏳ **START** | UX | Keybinding discovery |
| 27: Debug Streaming | HIGH | 6-8h | ⏳ | Feature | File watcher + UI |
| 17: Integration Tests | MEDIUM | 4-6h | ⏳ | Validation | After features done |
| 18: Final Checkpoint | MEDIUM | 2-3h | ⏳ | Validation | After features done |
| 16: Compiler Checkpoint | HIGH | 2-3h | ⏸️ | Blocking | Deferred - needs compiler |
| 20: Floating Windows | MEDIUM | 3-4h | ✅ **DONE** | UX | Already implemented |

---

## Recommended Next Step

**Start with Task 25 (which-key Integration)** - Quick win that improves UX significantly. Then proceed to Task 27 (Debug Streaming) for advanced developer features. After both features are complete, run comprehensive integration testing (Tasks 17-18).

**Estimated Timeline:**
- Task 25: 2-3 hours
- Task 27: 6-8 hours
- Tasks 17-18: 6-9 hours
- **Total to Production:** ~2 weeks (Tasks 25, 27, 17-18)
- **Task 16 Timeline:** When compiler access becomes available

---

**Date:** March 18, 2026  
**Last Updated:** Reordered tasks - defer integration testing until features complete  
**Status:** Ready to implement which-key integration

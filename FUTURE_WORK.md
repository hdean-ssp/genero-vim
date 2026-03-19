# Future Tasks and Features: Vim Genero-Tools Plugin

**Date:** March 19, 2026  
**Status:** Project Complete - Future Work Identified  
**Total Future Tasks:** 3 major features

---

## 📋 Overview

After completing the three-phase improvement project, three major tasks have been identified for future development.

---

## 🎯 High Priority Tasks

### Task 20: Add .per File Compilation Support

**Priority:** HIGH | **Complexity:** Medium | **Effort:** 5-7 hours

**Objective:** Add support for Genero .per (form) files with fglform compiler

**Current State:** Plugin only supports .4gl/.m3/.m4 files with fglcomp

**Target State:** .per files compile with fglform, errors display in sign column and quickfix

**Implementation Phases:**
1. File detection (ftdetect/per.vim, ftplugin/per.vim) - 1 hour
2. Compiler detection (auto-select fglform for .per files) - 1 hour
3. Output parsing (handle fglform output format) - 2 hours
4. Integration (autocompile, signs, quickfix) - 1.5 hours
5. Testing & documentation - 1.5 hours

**Files to Create:**
- `ftdetect/per.vim` - File type detection
- `ftplugin/per.vim` - Filetype plugin
- `autoload/genero_tools/compiler/per.vim` - Per-specific logic
- `autoload/genero_tools/compiler/per_parser.vim` - Output parser
- `tests/test_per_compilation.vim` - Tests

**Configuration Options:**
```vim
compiler_form_command = 'fglform'
compiler_form_args = ['-M', '-W', 'all']
```

**Success Criteria:**
- ✓ .per files recognized and highlighted
- ✓ `:GeneroCompile` works on .per files
- ✓ Errors appear in sign column and quickfix
- ✓ Autocompile works for .per files
- ✓ Mixed .4gl/.per projects work correctly

---

### Task 28: Debug File Streaming Feature

**Priority:** HIGH | **Complexity:** High | **Effort:** 8-10 hours

**Objective:** Stream debug output from files in a 1/3 width split window

**Current Issue:** Developers output debug info to files, no way to view while coding

**Target State:** Split window streams live changes from debug files with auto-scroll

**Implementation Phases:**
1. Configuration & setup - 1.5 hours
2. File watcher implementation - 3 hours
3. UI implementation (split window, auto-scroll) - 3 hours
4. Commands & keybindings - 1.5 hours
5. Testing & documentation - 1.5 hours

**Configuration Options:**
```vim
debug_stream_enabled = false
debug_stream_directory = './debug'
debug_stream_width = 33  " 1/3 width
debug_stream_auto_scroll = true
debug_stream_max_lines = 1000
debug_stream_refresh_interval = 500
```

**Commands:**
- `:GeneroDebugStreamOpen` - Open debug window
- `:GeneroDebugStreamClose` - Close debug window
- `:GeneroDebugStreamToggle` - Toggle debug window
- `:GeneroDebugStreamClear` - Clear debug output

**Success Criteria:**
- ✓ Debug window opens and displays file content
- ✓ Window updates when debug files change
- ✓ Auto-scroll works correctly
- ✓ Multiple debug files can be monitored
- ✓ Window can be toggled open/closed

---

## 📊 Medium Priority Tasks

### Task 19: SVN Diff Markers Feature

**Priority:** MEDIUM | **Complexity:** Medium | **Effort:** 6-8 hours

**Objective:** Display SVN diff markers in sign column

**Current State:** No SVN integration, no diff markers

**Target State:** Detect SVN working copies, display added/modified/deleted markers

**Implementation Phases:**
1. SVN detection - 1.5 hours
2. Diff retrieval and parsing - 2 hours
3. Sign display integration - 2 hours
4. Commands and caching - 1.5 hours
5. Testing & documentation - 1 hour

**Configuration Options:**
```vim
svn_enabled = true
svn_show_added = true
svn_show_modified = true
svn_show_deleted = true
svn_cache_ttl = 300
svn_auto_update = true
```

**Commands:**
- `:GeneroSVNRefresh` - Refresh SVN markers
- `:GeneroSVNToggle` - Toggle SVN markers
- `:GeneroSVNStatus` - Show SVN status

**Success Criteria:**
- ✓ SVN working copies detected
- ✓ Diff markers appear in sign column
- ✓ Added/modified/deleted distinguished
- ✓ Caching works correctly
- ✓ No conflicts with compiler signs

---

## 📈 Summary

| Task | Priority | Complexity | Effort | Status |
|------|----------|------------|--------|--------|
| Task 20: .per File Support | HIGH | Medium | 5-7 hrs | Not Started |
| Task 28: Debug Streaming | HIGH | High | 8-10 hrs | Not Started |
| Task 19: SVN Diff Markers | MEDIUM | Medium | 6-8 hrs | Not Started |
| **Total** | - | - | **19-25 hrs** | - |

---

## 🚀 Recommended Timeline

**Phase 1 (Week 1-2):** Task 20 - .per File Support
- Highest priority, medium complexity
- Enables form file compilation

**Phase 2 (Week 3-4):** Task 28 - Debug Streaming
- High priority, high complexity
- Improves developer debugging

**Phase 3 (Week 5-6):** Task 19 - SVN Diff Markers
- Medium priority, medium complexity
- Adds version control integration

---

## 📚 Related Documentation

- `.kiro/specs/vim-genero-tools-plugin/TASK_PER_FILE_SUPPORT.md` - .per file spec
- `.kiro/specs/vim-genero-tools-plugin/svn-diff-markers.md` - SVN diff spec
- `docs/TESTING_GUIDE.md` - Testing guide
- `.kiro/steering/MODULE_ARCHITECTURE.md` - Module architecture

---

**Status:** Future Tasks Identified  
**Date:** March 19, 2026  
**Total Future Effort:** 19-25 hours  
**Ready for:** Next Phase of Development


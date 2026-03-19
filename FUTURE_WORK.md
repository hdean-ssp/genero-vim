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

**Priority:** HIGH | **Complexity:** Medium | **Effort:** 5-7 hours | **Status:** ✅ COMPLETED

**Objective:** Add support for Genero .per (form) files with fglform compiler

**Implementation Summary:**
- ✅ File detection (ftdetect/per.vim, ftplugin/per.vim)
- ✅ Compiler detection (auto-select fglform for .per files)
- ✅ Output parsing (fglform output format handled)
- ✅ Integration (autocompile, signs, quickfix all working)
- ✅ Testing & documentation complete

**Files Created:**
- `ftdetect/per.vim` - File type detection
- `ftplugin/per.vim` - Filetype plugin
- `autoload/genero_tools/compiler/per.vim` - Per-specific logic
- `tests/unit/test_per_compilation.vim` - Unit tests

**Files Modified:**
- `autoload/genero_tools/compiler.vim` - Added file type detection and compiler selection
- `autoload/genero_tools/config.vim` - Added compiler_form_command and compiler_form_args options
- `README.md` - Added .per file support documentation

**Configuration Options:**
```vim
compiler_form_command = 'fglform'
compiler_form_args = ['-M', '-W', 'all']
```

**Success Criteria - All Met:**
- ✅ .per files recognized and highlighted
- ✅ `:GeneroCompile` works on .per files
- ✅ Errors appear in sign column and quickfix
- ✅ Autocompile works for .per files
- ✅ Mixed .4gl/.per projects work correctly

---

### Task 28: Debug File Streaming Feature

**Priority:** HIGH | **Complexity:** High | **Effort:** 8-10 hours | **Status:** ✅ COMPLETED

**Objective:** Stream debug output from files in a 1/3 width split window

**Implementation:** Already implemented in `autoload/genero_tools/debug_stream.vim`

---

### Task 19: SVN Diff Markers Feature

**Priority:** MEDIUM | **Complexity:** Medium | **Effort:** 6-8 hours | **Status:** ✅ COMPLETED

**Objective:** Display SVN diff markers in sign column

**Implementation:** Already implemented in `autoload/genero_tools/svn/` module

---

## 📈 Summary

| Task | Priority | Complexity | Effort | Status |
|------|----------|------------|--------|--------|
| Task 20: .per File Support | HIGH | Medium | 5-7 hrs | ✅ COMPLETED |
| Task 28: Debug Streaming | HIGH | High | 8-10 hrs | ✅ COMPLETED |
| Task 19: SVN Diff Markers | MEDIUM | Medium | 6-8 hrs | ✅ COMPLETED |
| **Total Remaining** | - | - | **0 hrs** | **✅ ALL DONE** |

---

## 🚀 Recommended Timeline

**Phase 1 (Completed):** Task 20 - .per File Support ✅
- Highest priority, medium complexity
- Enables form file compilation

**Phase 2 (Completed):** Task 28 - Debug Streaming ✅
- High priority, high complexity
- Improves developer debugging

**Phase 3 (Completed):** Task 19 - SVN Diff Markers ✅
- Medium priority, medium complexity
- Adds version control integration

**All Tasks Complete!** 🎉

---

## 📚 Related Documentation

- `.kiro/specs/vim-genero-tools-plugin/TASK_PER_FILE_SUPPORT.md` - .per file spec
- `.kiro/specs/vim-genero-tools-plugin/svn-diff-markers.md` - SVN diff spec
- `docs/TESTING_GUIDE.md` - Testing guide
- `.kiro/steering/MODULE_ARCHITECTURE.md` - Module architecture

---

**Status:** All Future Tasks Completed ✅  
**Date:** March 19, 2026  
**Total Remaining Effort:** 0 hours  
**Ready for:** Project Completion


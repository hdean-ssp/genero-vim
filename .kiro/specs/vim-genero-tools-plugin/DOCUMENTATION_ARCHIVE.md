# Documentation Archive and Organization

## Archive Status

### Documents Archived (No Longer Needed)
The following documents have been superseded by more comprehensive documentation and can be archived:

1. **TASK_ORDERING_CLARIFICATION.md**
   - **Reason:** Superseded by TASK_PROGRESSION.md
   - **Content:** Explained parallel development approach
   - **Archive:** Keep for reference, but not needed for new agents
   - **Location:** `.kiro/specs/vim-genero-tools-plugin/TASK_ORDERING_CLARIFICATION.md`

2. **ENHANCEMENT_INTEGRATION_SUMMARY.md**
   - **Reason:** Superseded by TASK_PROGRESSION.md and individual task summaries
   - **Content:** Initial integration of enhancement tasks
   - **Archive:** Keep for reference, but not needed for new agents
   - **Location:** `.kiro/specs/vim-genero-tools-plugin/ENHANCEMENT_INTEGRATION_SUMMARY.md`

### Documents to Keep (Active Reference)

#### Core Specification Documents
- `tasks.md` - Main task list (KEEP - reference for all tasks)
- `requirements.md` - Requirements document (KEEP - reference)
- `design.md` - Design document (KEEP - reference)

#### Current Task Context
- `NEXT_TASK_CONTEXT.md` - Context for Task 22 (KEEP - active)
- `TASK_PROGRESSION.md` - Task status and progression (KEEP - active)

#### Feature Specifications
- `DEBUG_STREAM_FEATURE.md` - Task 27 specification (KEEP - reference)
- `KEYBINDING_HELP_POPUP.md` - Task 28 specification (KEEP - reference)

#### Task Summaries
- `TASK_27_SUMMARY.md` - Task 27 overview (KEEP - reference)
- `TASK_28_SUMMARY.md` - Task 28 overview (KEEP - reference)

#### Implementation Guides
- `test/ENHANCEMENT_TASKS_SUMMARY.md` - Detailed implementation guide (KEEP - reference)
- `test/ENHANCEMENT_TASKS_QUICK_REFERENCE.md` - Quick reference (KEEP - reference)

#### Completed Task Documentation
- `test/TASK_21_IMPLEMENTATION_SUMMARY.md` - Task 21 results (KEEP - reference)
- `test/TASK_21_VERIFICATION.md` - Task 21 verification (KEEP - reference)
- `test/TASK_24_IMPLEMENTATION_SUMMARY.md` - Task 24 results (KEEP - reference)

### Test Files (Keep All)
All test files in `test/` directory should be kept:
- `test/test_startup_noise.vim` - Task 21 tests
- `test/test_statusline_bug_fix.vim` - Task 24 tests
- All other test files for reference

## Documentation Organization

### Directory Structure

```
.kiro/specs/vim-genero-tools-plugin/
├── tasks.md                              # Main task list
├── requirements.md                       # Requirements
├── design.md                             # Design document
├── NEXT_TASK_CONTEXT.md                 # ← START HERE for Task 22
├── TASK_PROGRESSION.md                  # Task status and timeline
├── DEBUG_STREAM_FEATURE.md              # Task 27 specification
├── KEYBINDING_HELP_POPUP.md             # Task 28 specification
├── TASK_27_SUMMARY.md                   # Task 27 overview
├── TASK_28_SUMMARY.md                   # Task 28 overview
├── DOCUMENTATION_ARCHIVE.md             # This file
├── TASK_ORDERING_CLARIFICATION.md       # [ARCHIVED - Reference only]
└── ENHANCEMENT_INTEGRATION_SUMMARY.md   # [ARCHIVED - Reference only]

test/
├── ENHANCEMENT_TASKS_SUMMARY.md         # Implementation guide
├── ENHANCEMENT_TASKS_QUICK_REFERENCE.md # Quick reference
├── TASK_21_IMPLEMENTATION_SUMMARY.md    # Task 21 results
├── TASK_21_VERIFICATION.md              # Task 21 verification
├── TASK_24_IMPLEMENTATION_SUMMARY.md    # Task 24 results
├── test_startup_noise.vim               # Task 21 tests
├── test_statusline_bug_fix.vim          # Task 24 tests
└── [other test files]
```

## For New Agents

### Quick Start Path
1. **Start here:** `.kiro/specs/vim-genero-tools-plugin/NEXT_TASK_CONTEXT.md`
2. **Understand progress:** `.kiro/specs/vim-genero-tools-plugin/TASK_PROGRESSION.md`
3. **Get details:** `test/ENHANCEMENT_TASKS_SUMMARY.md` (E2.1 section)
4. **Reference:** `.kiro/specs/vim-genero-tools-plugin/tasks.md` (Task 22 section)

### Document Priority
1. **MUST READ:** NEXT_TASK_CONTEXT.md
2. **SHOULD READ:** TASK_PROGRESSION.md
3. **REFERENCE:** tasks.md, ENHANCEMENT_TASKS_SUMMARY.md
4. **OPTIONAL:** requirements.md, design.md

## Cleanup Actions Taken

### Documents Created (New)
- ✓ NEXT_TASK_CONTEXT.md - Task 22 context
- ✓ TASK_PROGRESSION.md - Task status and timeline
- ✓ DOCUMENTATION_ARCHIVE.md - This file

### Documents Marked as Reference
- TASK_ORDERING_CLARIFICATION.md - Keep but not primary
- ENHANCEMENT_INTEGRATION_SUMMARY.md - Keep but not primary

### Documents Consolidated
- Task summaries organized by task number
- Feature specifications organized by task number
- Implementation guides consolidated in test/ directory

## Maintenance Notes

### When Adding New Tasks
1. Create NEXT_TASK_CONTEXT.md for the new task
2. Update TASK_PROGRESSION.md with new task status
3. Create feature specification if needed
4. Create task summary document
5. Update this archive document

### When Completing Tasks
1. Move task to "Completed Tasks" in TASK_PROGRESSION.md
2. Archive task-specific context documents
3. Keep implementation summary for reference
4. Update NEXT_TASK_CONTEXT.md for next task

### Document Retention Policy
- Keep all specification documents (tasks.md, requirements.md, design.md)
- Keep all completed task documentation (for reference)
- Keep all test files (for regression testing)
- Archive context documents after task completion
- Keep current task context (NEXT_TASK_CONTEXT.md)

## Summary

**Total Documents:** 20+
**Active Documents:** 12
**Reference Documents:** 5
**Archived Documents:** 2

**Organization Status:** ✓ COMPLETE
**Ready for Task 22:** ✓ YES

---

**Last Updated:** March 17, 2026
**Status:** Documentation organized and ready for Task 22
**Next Step:** New agent should read NEXT_TASK_CONTEXT.md

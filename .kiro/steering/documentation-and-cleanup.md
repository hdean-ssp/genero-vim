---
inclusion: auto
---

# Documentation and Repository Cleanup Guidelines

## Documentation Minimization Policy

### Core Principle
Keep documentation generation to an absolute minimum. Consolidate all task-related documentation into a single file per task/phase rather than creating multiple markdown files.

### Guidelines

#### 1. Single File Per Task/Phase
- Create ONE comprehensive document per task or phase
- Name format: `TASK_XX_SUMMARY.md` or `PHASE_X_SUMMARY.md`
- Include all relevant information in this single file:
  - Status and completion checklist
  - Implementation details
  - Requirements coverage
  - Testing information
  - Next steps

#### 2. No Duplicate Documentation
- Do NOT create separate files for:
  - Quick references (include in main summary)
  - Implementation guides (include in main summary)
  - Progress reports (include in main summary)
  - Completion reports (include in main summary)
  - Index files (include in main summary)
- Consolidate all information into one file

#### 3. Documentation Location
- Task/phase summaries: `/test/` directory
- User-facing docs: `/docs/` directory
- Spec-related docs: `.kiro/specs/` directory
- Do NOT create documentation in multiple locations

#### 4. Archival Process
- When a markdown file becomes obsolete:
  1. Move it to `.archive/` directory
  2. Update any references to point to current documentation
  3. Do NOT delete files - archive them for historical reference

### What NOT to Document
- Intermediate progress updates (use task status instead)
- Duplicate information (consolidate into one file)
- Implementation details that belong in code comments
- Temporary notes or working documents

### What TO Document
- Final task/phase summaries (one file per task/phase)
- User-facing guides (in `/docs/`)
- Architecture decisions (in steering files)
- Configuration examples (in user guides)

## Repository Cleanup Guidelines

### Test Directory Cleanup

#### 1. Consolidate Test Files
- Group related tests into single files
- Example: All SVN tests → `test_svn.vim` (not separate files for each module)
- Naming: `test_<feature>.vim` for feature tests

#### 2. Remove Obsolete Test Files
- Archive test files that are no longer used
- Move to `.archive/` with timestamp
- Keep only active, current tests in `/test/`

#### 3. Test Organization
```
test/
├── test_svn.vim                    # All SVN-related tests
├── test_compiler.vim               # All compiler tests
├── test_snippets.vim               # All snippet tests
├── test_integration.vim            # Integration tests
└── (archived files moved to .archive/)
```

#### 4. Documentation in Test Directory
- Only keep: `test_<feature>.vim` files (actual tests)
- Archive: All `.md` files that are task/phase summaries
- Exception: Keep only ONE summary per major feature/phase

### Archive Directory Usage

#### 1. What Goes to Archive
- Obsolete markdown files
- Old test files no longer in use
- Superseded documentation
- Historical implementation notes

#### 2. Archive Naming
- Keep original filename
- Add timestamp if helpful: `FILENAME_ARCHIVED_2026-03-17.md`
- Maintain directory structure

#### 3. Archive Maintenance
- Review archive quarterly
- Remove truly obsolete files after 6 months
- Keep important historical records

### Cleanup Checklist

- [ ] Consolidate task/phase documentation into single files
- [ ] Archive obsolete markdown files from `/test/`
- [ ] Archive obsolete markdown files from `.kiro/specs/`
- [ ] Consolidate test files by feature
- [ ] Remove duplicate test files
- [ ] Update all references to archived files
- [ ] Verify no broken links remain
- [ ] Document cleanup in commit message

## Implementation Examples

### Before (Multiple Files)
```
test/
├── TASK_19_PHASE3_PROGRESS.md
├── TASK_19_PHASE3_SUMMARY.md
├── TASK_19_PHASE3_IMPLEMENTATION_GUIDE.md
├── TASK_19_PHASE3_QUICK_REFERENCE.md
├── TASK_19_PHASE3_COMPLETION_REPORT.md
├── TASK_19_PHASE3_INDEX.md
└── TASK_19_READY_FOR_PHASE4.md
```

### After (Single File)
```
test/
├── TASK_19_PHASE3_SUMMARY.md  # Contains all information
└── (other files archived)
```

### Archive Structure
```
.archive/
├── TASK_19_PHASE3_PROGRESS.md
├── TASK_19_PHASE3_IMPLEMENTATION_GUIDE.md
├── TASK_19_PHASE3_QUICK_REFERENCE.md
├── TASK_19_PHASE3_COMPLETION_REPORT.md
├── TASK_19_PHASE3_INDEX.md
└── TASK_19_READY_FOR_PHASE4.md
```

## Documentation Template

When creating a task/phase summary, include these sections:

```markdown
# Task XX / Phase X - Summary

## Status
- Overall status (Complete/In Progress/Blocked)
- Completion percentage

## What Was Accomplished
- Key deliverables
- Requirements met

## Implementation Details
- Files modified
- Key functions/changes
- Configuration options

## Testing
- Test file location
- Number of tests
- Coverage summary

## Requirements Coverage
- Table of requirements and status

## Next Steps
- What comes next
- Phase progression

## How to Use
- User-facing commands
- Configuration examples

## Files Modified
- List of all changed files

## Verification Checklist
- Checklist of completion items
```

## Enforcement

### For New Tasks/Phases
1. Create ONE summary file per task/phase
2. Include all relevant information in that file
3. Do NOT create additional documentation files
4. Archive any superseded documentation

### For Existing Documentation
1. Consolidate multiple files into single summary
2. Archive old files to `.archive/`
3. Update references
4. Verify no broken links

### Code Review
- Reject PRs that create multiple documentation files for same task
- Require consolidation into single file
- Require archival of obsolete files

## Benefits

1. **Reduced Clutter**: Fewer files to maintain
2. **Easier Navigation**: Single source of truth per task
3. **Better Maintenance**: Changes in one place
4. **Historical Record**: Archive preserves history
5. **Faster Onboarding**: Clear, consolidated information

## Questions?

Refer to existing task summaries in `/test/` for examples of consolidated documentation.

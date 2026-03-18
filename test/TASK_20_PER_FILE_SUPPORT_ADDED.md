# Task 20: .per File Support - Added to Task List

## Summary
The .per file support task has been successfully added to `.kiro/specs/vim-genero-tools-plugin/tasks.md` as **Task 20** with HIGH priority.

## What Was Done

### 1. Task Added to tasks.md
- **Task Number:** 20
- **Priority:** HIGH
- **Status:** Not started ([ ])
- **Position:** After Task 19 (SVN Diff Markers), before Enhancement Tasks (21-27)

### 2. Task Details
The task includes:
- **Objective:** Add support for Genero .per (form) files with automatic detection and compilation using `fglform` compiler
- **Current State:** Plugin only supports .4gl/.m3/.m4 files with fglcomp compiler
- **Target State:** .per files compile with fglform, errors display in sign column and quickfix, autocompile works
- **Reference:** Full specification in `.kiro/specs/vim-genero-tools-plugin/TASK_PER_FILE_SUPPORT.md`

### 3. Implementation Plan (5 Phases)
- Phase 1: File detection (ftdetect/per.vim, ftplugin/per.vim)
- Phase 2: Compiler detection (auto-select fglform for .per files)
- Phase 3: Output parsing (handle fglform output format)
- Phase 4: Integration (autocompile, signs, quickfix)
- Phase 5: Testing & documentation

### 4. Files to Create
- `ftdetect/per.vim` - File type detection for .per files
- `ftplugin/per.vim` - Filetype plugin for .per files
- `autoload/genero_tools/compiler/per.vim` - Per-specific compiler logic
- `autoload/genero_tools/compiler/per_parser.vim` - Per output parser
- `test/test_per_compilation.vim` - Test cases for .per compilation

### 5. Files to Modify
- `autoload/genero_tools/compiler.vim` - Add file type detection
- `autoload/genero_tools/compiler/execute.vim` - Select compiler based on file type
- `autoload/genero_tools/config.vim` - Add fglform configuration options
- `plugin/genero_tools.vim` - Register per filetype commands if needed
- `README.md` - Document .per file support

### 6. Configuration Options
- `compiler_form_command`: fglform command path (default: 'fglform')
- `compiler_form_args`: fglform compiler flags (default: ['-M', '-W', 'all'])

### 7. Success Criteria
- ✓ .per files are recognized and highlighted
- ✓ `:GeneroCompile` works on .per files
- ✓ Errors from `fglform` appear in sign column
- ✓ Errors from `fglform` appear in quickfix list
- ✓ Autocompile works for .per files
- ✓ Mixed projects with .4gl and .per files work correctly
- ✓ Configuration options are documented
- ✓ Tests pass for all scenarios

## Task Numbering Update
All subsequent tasks have been renumbered:
- Enhancement Tasks: 21-27 (previously 20-26)
- Debug File Streaming: Task 28 (previously 27)
- Keybinding Help Popup: Task 29 (previously 28)
- Lualine Integration: Task 30 (previously 29)

## Next Steps
1. Review the full specification in `TASK_PER_FILE_SUPPORT.md`
2. Begin Phase 1 implementation (file detection)
3. Create ftdetect/per.vim and ftplugin/per.vim
4. Proceed through phases 2-5 as outlined in the specification

## Related Documentation
- Full specification: `.kiro/specs/vim-genero-tools-plugin/TASK_PER_FILE_SUPPORT.md`
- Task list: `.kiro/specs/vim-genero-tools-plugin/tasks.md`
- Compiler integration: `docs/COMPILER_INTEGRATION.md`

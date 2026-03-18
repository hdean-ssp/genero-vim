# Task: Add .per File Compilation Support

## Overview
Add support for Genero .per (form) files with automatic detection and compilation using `fglform` compiler instead of `fglcomp`. The implementation should mirror the existing .4gl/.m3/.m4 compilation workflow while handling the different compiler and output format.

## Requirements

### 1. File Type Detection
- Detect .per files and set filetype to `per`
- Create ftdetect rule for .per files
- Ensure proper syntax highlighting (can reuse fgl syntax or create per-specific)

### 2. Compiler Detection
- Detect file type (4gl vs per) based on file extension
- Use `fglcomp` for .4gl/.m3/.m4 files
- Use `fglform` for .per files
- Auto-detect which compiler to use when compiling

### 3. Compilation Integration
- Support `:GeneroCompile` command for .per files
- Parse `fglform` output format (may differ from `fglcomp`)
- Populate quickfix list with errors/warnings from `fglform`
- Display results in sign column and quickfix window
- Support autocompile on save for .per files

### 4. Output Parsing
- Create parser for `fglform` output format
- Handle different error/warning message format if applicable
- Extract line numbers, column numbers, and error messages
- Support both error and warning levels

### 5. Configuration
- Add config option for `fglform` command path
- Add config option for `fglform` compiler flags
- Allow per-file or project-level configuration
- Default flags: `-M -W all` (same as fglcomp)

### 6. Filetype Plugin
- Create ftplugin/per.vim with:
  - Omnifunc for completion (reuse genero_tools#complete#omnifunc)
  - Comment string: `#\ %s`
  - Autocompile support
  - Tab keybindings (same as fgl.vim)

## Implementation Plan

### Phase 1: File Detection & Basic Setup
1. Add ftdetect rule for .per files
2. Create ftplugin/per.vim
3. Add per filetype to syntax highlighting

### Phase 2: Compiler Detection
1. Modify compiler module to detect file type
2. Add logic to select compiler based on extension
3. Add fglform command configuration

### Phase 3: Output Parsing
1. Create per-specific parser or extend existing parser
2. Handle fglform output format
3. Test with sample fglform output

### Phase 4: Integration
1. Update autocompile to support .per files
2. Update sign placement for .per files
3. Update quickfix integration
4. Test full workflow

### Phase 5: Testing & Documentation
1. Create test cases for .per compilation
2. Create test cases for mixed 4gl/.per projects
3. Document configuration options
4. Update README with .per file support

## Files to Modify/Create

### New Files
- `ftdetect/per.vim` - File type detection for .per files
- `ftplugin/per.vim` - Filetype plugin for .per files
- `autoload/genero_tools/compiler/per.vim` - Per-specific compiler logic
- `autoload/genero_tools/compiler/per_parser.vim` - Per output parser
- `test/test_per_compilation.vim` - Test cases for .per compilation

### Modified Files
- `autoload/genero_tools/compiler.vim` - Add file type detection
- `autoload/genero_tools/compiler/execute.vim` - Select compiler based on file type
- `autoload/genero_tools/config.vim` - Add fglform configuration options
- `plugin/genero_tools.vim` - Register per filetype commands if needed
- `README.md` - Document .per file support

## Configuration Options

```vim
let g:genero_tools_config = {
  \ 'compiler_enabled': 1,
  \ 'compiler_command': 'fglcomp',      " For .4gl files
  \ 'compiler_form_command': 'fglform', " For .per files
  \ 'compiler_args': ['-M', '-W', 'all'],
  \ 'compiler_form_args': ['-M', '-W', 'all'],
  \ ...
}
```

## Testing Strategy

### Unit Tests
- Test file type detection for .per files
- Test compiler selection logic
- Test fglform output parsing
- Test error/warning extraction

### Integration Tests
- Test compilation of .per file
- Test autocompile on save for .per files
- Test mixed project with .4gl and .per files
- Test sign placement for .per errors
- Test quickfix population for .per errors

### Manual Testing
- Compile a .per file with errors
- Verify error signs appear
- Verify quickfix list is populated
- Verify autocompile works
- Test with multiple .per files in project

## Success Criteria

1. ✓ .per files are recognized and highlighted
2. ✓ `:GeneroCompile` works on .per files
3. ✓ Errors from `fglform` appear in sign column
4. ✓ Errors from `fglform` appear in quickfix list
5. ✓ Autocompile works for .per files
6. ✓ Mixed projects with .4gl and .per files work correctly
7. ✓ Configuration options are documented
8. ✓ Tests pass for all scenarios

## Notes

- The fglform compiler may have different output format than fglcomp
- Need to research actual fglform output format before implementation
- Consider whether .per files need different syntax highlighting
- Consider whether .per files need different completion behavior
- May need to handle .per file dependencies on .4gl files

## Related Tasks
- Task 1: SVN diff sign integration (completed)
- Task 2: Unified sign column system (completed)
- Task 3: Error navigation improvements (completed)
- Task 4: Tab key improvements (completed)
- Task 5: .per file support (this task)

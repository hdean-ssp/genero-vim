# Task 20: .per File Compilation Support - Complete Specification

**Date:** March 19, 2026  
**Priority:** HIGH  
**Complexity:** Medium  
**Estimated Effort:** 5-7 hours  
**Status:** Ready for Implementation

---

## 📋 Overview

Add support for Genero .per (form) files with automatic detection and compilation using the `fglform` compiler instead of `fglcomp`. The implementation should mirror the existing .4gl/.m3/.m4 compilation workflow while handling the different compiler and output format.

---

## 🎯 Objectives

### Current State
- Plugin only supports .4gl/.m3/.m4 files with fglcomp compiler
- No support for .per (form) files
- No fglform compiler integration

### Target State
- .per files are recognized and highlighted
- `:GeneroCompile` works on .per files
- Errors from `fglform` appear in sign column
- Errors from `fglform` appear in quickfix list
- Autocompile works for .per files
- Mixed projects with .4gl and .per files work correctly

---

## 📊 Implementation Plan (5 Phases)

### Phase 1: File Detection & Basic Setup (1 hour)
**Objective:** Detect .per files and set up basic filetype support

**Tasks:**
1. Create `ftdetect/per.vim` with file type detection rule
   - Detect .per file extension
   - Set filetype to `per`
   
2. Create `ftplugin/per.vim` with filetype plugin
   - Set comment string: `#\ %s`
   - Set omnifunc for completion
   - Add tab keybindings (same as fgl.vim)
   - Enable autocompile support

3. Syntax highlighting
   - Reuse existing fgl syntax or create per-specific
   - Ensure proper highlighting for form files

**Files to Create:**
- `ftdetect/per.vim`
- `ftplugin/per.vim`

**Success Criteria:**
- ✓ .per files recognized by Vim
- ✓ Filetype set to `per`
- ✓ Syntax highlighting works
- ✓ Omnifunc available for completion

---

### Phase 2: Compiler Detection (1 hour)
**Objective:** Auto-detect which compiler to use based on file type

**Tasks:**
1. Modify `autoload/genero_tools/compiler.vim`
   - Add function to detect file type based on extension
   - Return appropriate compiler (fglcomp for .4gl, fglform for .per)

2. Modify `autoload/genero_tools/compiler/execute.vim`
   - Update execute function to select compiler based on file type
   - Use fglcomp for .4gl/.m3/.m4 files
   - Use fglform for .per files

3. Add configuration options to `autoload/genero_tools/config.vim`
   - `compiler_form_command`: fglform command path (default: 'fglform')
   - `compiler_form_args`: fglform compiler flags (default: ['-M', '-W', 'all'])

**Files to Modify:**
- `autoload/genero_tools/compiler.vim`
- `autoload/genero_tools/compiler/execute.vim`
- `autoload/genero_tools/config.vim`

**Success Criteria:**
- ✓ File type detection works correctly
- ✓ Correct compiler selected based on file type
- ✓ Configuration options available
- ✓ Default values set correctly

---

### Phase 3: Output Parsing (2 hours)
**Objective:** Parse fglform output and extract errors/warnings

**Tasks:**
1. Create `autoload/genero_tools/compiler/per.vim`
   - Per-specific compiler logic
   - Handle fglform-specific behavior

2. Create `autoload/genero_tools/compiler/per_parser.vim`
   - Parse fglform output format
   - Extract line numbers, column numbers, error messages
   - Support both error and warning levels
   - Handle different message format if applicable

3. Research fglform output format
   - Determine exact output format
   - Compare with fglcomp format
   - Handle any differences

**Files to Create:**
- `autoload/genero_tools/compiler/per.vim`
- `autoload/genero_tools/compiler/per_parser.vim`

**Success Criteria:**
- ✓ fglform output parsed correctly
- ✓ Errors extracted with line/column numbers
- ✓ Warnings extracted separately
- ✓ Error messages preserved

---

### Phase 4: Integration (1.5 hours)
**Objective:** Integrate .per file compilation with existing systems

**Tasks:**
1. Update autocompile system
   - Ensure autocompile works for .per files
   - Use correct compiler based on file type

2. Update sign column display
   - Place signs for .per file errors
   - Use same sign types as .4gl files

3. Update quickfix integration
   - Populate quickfix list with .per file errors
   - Support quickfix navigation

4. Test mixed projects
   - Ensure .4gl and .per files work together
   - Verify no conflicts between compilers

**Files to Modify:**
- `autoload/genero_tools/compiler/autocompile.vim`
- `autoload/genero_tools/compiler/signs.vim`
- `autoload/genero_tools/compiler/quickfix.vim`

**Success Criteria:**
- ✓ Autocompile works for .per files
- ✓ Signs display correctly
- ✓ Quickfix list populated
- ✓ Mixed projects work correctly

---

### Phase 5: Testing & Documentation (1.5 hours)
**Objective:** Create tests and documentation

**Tasks:**
1. Create test cases
   - Unit tests for file type detection
   - Unit tests for compiler selection
   - Unit tests for output parsing
   - Integration tests for full workflow

2. Create documentation
   - Update README.md with .per file support
   - Document configuration options
   - Add examples of .per file compilation

3. Manual testing
   - Compile .per file with errors
   - Verify error signs appear
   - Verify quickfix list populated
   - Test autocompile
   - Test mixed projects

**Files to Create:**
- `tests/test_per_compilation.vim`

**Files to Modify:**
- `README.md`

**Success Criteria:**
- ✓ All tests pass
- ✓ Documentation complete
- ✓ Manual testing successful

---

## 📁 Files to Create

### New Files
1. **`ftdetect/per.vim`** - File type detection
   - Detect .per files
   - Set filetype to `per`

2. **`ftplugin/per.vim`** - Filetype plugin
   - Comment string
   - Omnifunc
   - Keybindings
   - Autocompile support

3. **`autoload/genero_tools/compiler/per.vim`** - Per-specific logic
   - Per-specific compiler behavior
   - Handle fglform-specific features

4. **`autoload/genero_tools/compiler/per_parser.vim`** - Output parser
   - Parse fglform output
   - Extract errors/warnings
   - Handle different format

5. **`tests/test_per_compilation.vim`** - Test cases
   - Unit tests
   - Integration tests
   - Manual test guide

---

## 📝 Files to Modify

1. **`autoload/genero_tools/compiler.vim`**
   - Add file type detection function
   - Add compiler selection logic

2. **`autoload/genero_tools/compiler/execute.vim`**
   - Update to select compiler based on file type
   - Use fglform for .per files

3. **`autoload/genero_tools/config.vim`**
   - Add `compiler_form_command` option
   - Add `compiler_form_args` option

4. **`autoload/genero_tools/compiler/autocompile.vim`**
   - Ensure autocompile works for .per files

5. **`autoload/genero_tools/compiler/signs.vim`**
   - Ensure signs work for .per files

6. **`autoload/genero_tools/compiler/quickfix.vim`**
   - Ensure quickfix works for .per files

7. **`plugin/genero_tools.vim`**
   - Register per filetype commands if needed

8. **`README.md`**
   - Document .per file support

---

## ⚙️ Configuration Options

### New Configuration Options

```vim
let g:genero_tools_config = {
  \ 'compiler_form_command': 'fglform',
  \ 'compiler_form_args': ['-M', '-W', 'all'],
  \ ...
}
```

### Option Details

**`compiler_form_command`**
- Type: String
- Default: 'fglform'
- Description: Path to fglform compiler command
- Example: `let g:genero_tools_config.compiler_form_command = '/usr/bin/fglform'`

**`compiler_form_args`**
- Type: List
- Default: ['-M', '-W', 'all']
- Description: Arguments to pass to fglform compiler
- Example: `let g:genero_tools_config.compiler_form_args = ['-M', '-W', 'all', '-O']`

---

## 🧪 Testing Strategy

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
1. Create a test .per file with errors
2. Run `:GeneroCompile`
3. Verify error signs appear in sign column
4. Verify quickfix list is populated
5. Verify autocompile works on save
6. Test with multiple .per files
7. Test mixed .4gl and .per project

---

## ✅ Success Criteria

1. ✓ .per files are recognized and highlighted
2. ✓ `:GeneroCompile` works on .per files
3. ✓ Errors from `fglform` appear in sign column
4. ✓ Errors from `fglform` appear in quickfix list
5. ✓ Autocompile works for .per files
6. ✓ Mixed projects with .4gl and .per files work correctly
7. ✓ Configuration options are documented
8. ✓ Tests pass for all scenarios

---

## 📚 Related Documentation

- **Specification:** `.kiro/specs/vim-genero-tools-plugin/TASK_PER_FILE_SUPPORT.md`
- **Compiler Integration:** `docs/COMPILER_INTEGRATION.md`
- **Testing Guide:** `docs/TESTING_GUIDE.md`
- **Module Architecture:** `.kiro/steering/MODULE_ARCHITECTURE.md`

---

## 💡 Implementation Notes

### Important Considerations

1. **fglform Output Format**
   - Need to research actual fglform output format
   - May differ from fglcomp format
   - Handle any differences in parsing

2. **Syntax Highlighting**
   - Can reuse existing fgl syntax
   - Or create per-specific syntax
   - Ensure proper highlighting for form files

3. **Completion Behavior**
   - May need different completion for .per files
   - Consider form-specific keywords

4. **File Dependencies**
   - .per files may depend on .4gl files
   - Consider handling dependencies

5. **Mixed Projects**
   - Ensure .4gl and .per files work together
   - No conflicts between compilers
   - Proper error handling for each type

---

## 🚀 Getting Started

### Step 1: Research
- Research fglform output format
- Compare with fglcomp format
- Understand form file structure

### Step 2: Phase 1 Implementation
- Create ftdetect/per.vim
- Create ftplugin/per.vim
- Test file type detection

### Step 3: Phase 2 Implementation
- Modify compiler.vim
- Modify compiler/execute.vim
- Add configuration options

### Step 4: Phase 3 Implementation
- Create per_parser.vim
- Test output parsing
- Handle different formats

### Step 5: Phase 4 Implementation
- Integrate with autocompile
- Integrate with signs
- Integrate with quickfix

### Step 6: Phase 5 Implementation
- Create tests
- Create documentation
- Manual testing

---

## 📊 Summary

**Task:** Add .per File Compilation Support  
**Priority:** HIGH  
**Complexity:** Medium  
**Estimated Effort:** 5-7 hours  
**Phases:** 5 (File Detection → Compiler Detection → Output Parsing → Integration → Testing)  
**Files to Create:** 5  
**Files to Modify:** 8  
**Success Criteria:** 8 criteria to meet

---

**Status:** Ready for Implementation  
**Date:** March 19, 2026  
**Next Step:** Begin Phase 1 - File Detection & Basic Setup


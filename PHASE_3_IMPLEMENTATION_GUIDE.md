# Phase 3 Implementation Guide: Standardize Error Messages

**Status:** Ready for Implementation  
**Date:** March 19, 2026  
**Estimated Effort:** 2-3 hours  
**Objective:** Create consistent error message format across all modules

---

## 🎯 Phase 3 Overview

Phase 3 focuses on a single, high-impact task: standardizing error messages across all modules. This improves user experience, debugging, and code maintainability.

### What We're Doing

Implementing a consistent error message format: `[MODULE] Error description`

**Examples:**
- `[config] timeout must be positive, using default 10000`
- `[cache] cache_max_size must be positive, using default 100`
- `[command] Command timed out after 10000ms`
- `[display] Invalid display mode "invalid_mode", using quickfix`

---

## 📋 Task 3.2: Standardize Error Messages

### Objective
Create a standardized error handling system that all modules use consistently.

### Implementation Steps

#### Step 1: Create Error Module
**File:** `autoload/genero_tools/error.vim`

```vim
" Genero-Tools Plugin - Error Handling Module
" Provides standardized error message formatting and display

" Error message format: [MODULE] Error description
function! genero_tools#error#format(module, message) abort
  return '[' . a:module . '] ' . a:message
endfunction

" Echo error message
function! genero_tools#error#echo(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  call genero_tools#display#echo(l:formatted)
endfunction

" Display warning message
function! genero_tools#error#warn(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  echohl WarningMsg
  echo l:formatted
  echohl None
endfunction

" Display error message
function! genero_tools#error#error(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  echohl ErrorMsg
  echo l:formatted
  echohl None
endfunction

" Log debug message (if debug mode enabled)
function! genero_tools#error#debug(module, message) abort
  if genero_tools#config#get('debug_mode')
    let l:formatted = genero_tools#error#format(a:module, a:message)
    call genero_tools#debug#log(l:formatted)
  endif
endfunction

" Create error result dictionary
function! genero_tools#error#result(module, message) abort
  return {
    \ 'success': v:false,
    \ 'data': {},
    \ 'error': genero_tools#error#format(a:module, a:message),
    \ 'timestamp': localtime()
    \ }
endfunction
```

#### Step 2: Update Configuration Module
**File:** `autoload/genero_tools/config.vim`

Replace error handling with standardized format:

```vim
" Before
call genero_tools#display#echo('Error: timeout must be positive')

" After
call genero_tools#error#warn('config', 'timeout must be positive, using default 10000')
```

#### Step 3: Update All Modules
Update the following modules to use standardized error functions:

1. **cache.vim** - Cache operation errors
2. **command.vim** - Command execution errors
3. **display.vim** - Display mode errors
4. **compiler.vim** - Compiler integration errors
5. **snippets.vim** - Snippet system errors
6. **svn.vim** - SVN integration errors

#### Step 4: Create Tests
**File:** `tests/unit/test_error.vim`

```vim
" Test error module

function! test_error_format_creates_correct_format() abort
  let l:formatted = genero_tools#error#format('config', 'test error')
  assert_equal(l:formatted, '[config] test error')
endfunction

function! test_error_result_creates_error_result() abort
  let l:result = genero_tools#error#result('cache', 'not found')
  assert_equal(l:result.success, v:false)
  assert_equal(l:result.error, '[cache] not found')
  assert_equal(empty(l:result.data), v:true)
endfunction

function! test_error_format_with_multiple_modules() abort
  let l:config_error = genero_tools#error#format('config', 'invalid value')
  let l:cache_error = genero_tools#error#format('cache', 'eviction failed')
  
  assert_equal(l:config_error, '[config] invalid value')
  assert_equal(l:cache_error, '[cache] eviction failed')
endfunction
```

---

## 📊 Modules to Update

### 1. config.vim
**Current errors:**
- Timeout validation
- Display mode validation
- Cache TTL validation
- Cache max size validation
- Result limit validation
- Pagination size validation

**Update to:**
```vim
call genero_tools#error#warn('config', 'timeout must be positive, using default 10000')
```

### 2. cache.vim
**Current errors:**
- Cache eviction failures
- Cache size exceeded
- TTL expiration handling

**Update to:**
```vim
call genero_tools#error#warn('cache', 'cache_max_size exceeded, evicting oldest entry')
```

### 3. command.vim
**Current errors:**
- Command execution failures
- Timeout errors
- JSON parse errors
- Argument escaping errors

**Update to:**
```vim
call genero_tools#error#error('command', 'Command timed out after 10000ms')
```

### 4. display.vim
**Current errors:**
- Invalid display mode
- Display operation failures
- Pagination errors

**Update to:**
```vim
call genero_tools#error#warn('display', 'Invalid display mode "invalid_mode", using quickfix')
```

### 5. compiler.vim
**Current errors:**
- Compiler not found
- Compilation failures
- Output parsing errors

**Update to:**
```vim
call genero_tools#error#error('compiler', 'Compiler not found: fglcomp')
```

### 6. snippets.vim
**Current errors:**
- Snippet loading failures
- Template not found

**Update to:**
```vim
call genero_tools#error#warn('snippets', 'Template not found: ' . l:template_name)
```

### 7. svn.vim
**Current errors:**
- SVN not installed
- SVN command failures
- Diff parsing errors

**Update to:**
```vim
call genero_tools#error#error('svn', 'SVN not installed or not in PATH')
```

---

## 🧪 Testing Strategy

### Unit Tests
Create `tests/unit/test_error.vim` with tests for:
- Error format function
- Error result creation
- Error display functions
- Debug logging

### Integration Tests
Update `tests/integration/test_module_interactions.vim` to verify:
- Error messages are consistent across modules
- Error results have correct structure
- Error handling doesn't break workflows

### Manual Testing
1. Trigger errors in each module
2. Verify error message format
3. Verify error messages are helpful
4. Verify error handling doesn't crash

---

## 📝 Implementation Checklist

### Phase 3 Tasks

- [ ] **Create error module** (`autoload/genero_tools/error.vim`)
  - [ ] `error#format()` function
  - [ ] `error#echo()` function
  - [ ] `error#warn()` function
  - [ ] `error#error()` function
  - [ ] `error#debug()` function
  - [ ] `error#result()` function

- [ ] **Update config.vim**
  - [ ] Replace all error messages with standardized format
  - [ ] Test configuration validation

- [ ] **Update cache.vim**
  - [ ] Replace all error messages with standardized format
  - [ ] Test cache operations

- [ ] **Update command.vim**
  - [ ] Replace all error messages with standardized format
  - [ ] Test command execution

- [ ] **Update display.vim**
  - [ ] Replace all error messages with standardized format
  - [ ] Test display modes

- [ ] **Update compiler.vim**
  - [ ] Replace all error messages with standardized format
  - [ ] Test compiler integration

- [ ] **Update snippets.vim**
  - [ ] Replace all error messages with standardized format
  - [ ] Test snippet system

- [ ] **Update svn.vim**
  - [ ] Replace all error messages with standardized format
  - [ ] Test SVN integration

- [ ] **Create tests** (`tests/unit/test_error.vim`)
  - [ ] Test error format function
  - [ ] Test error result creation
  - [ ] Test error display functions
  - [ ] Test debug logging

- [ ] **Update integration tests**
  - [ ] Verify error consistency across modules
  - [ ] Verify error handling in workflows

- [ ] **Run all tests**
  - [ ] `./scripts/test.sh`
  - [ ] Verify all tests pass

- [ ] **Documentation**
  - [ ] Update error handling documentation
  - [ ] Add examples to TESTING_GUIDE.md
  - [ ] Create PHASE_3_IMPLEMENTATION_SUMMARY.md

---

## 🎯 Success Criteria

### Acceptance Criteria
- ✅ Error module created with all required functions
- ✅ All modules use standardized error format
- ✅ Error messages are consistent across codebase
- ✅ Error messages are helpful and actionable
- ✅ All tests pass (including new error tests)
- ✅ No regressions in existing functionality

### Quality Metrics
- ✅ 100% of error messages use `[MODULE] message` format
- ✅ All error functions have tests
- ✅ Error handling doesn't break workflows
- ✅ Error messages are user-friendly

---

## 📚 Reference Materials

### Error Handling Examples
See `IMPLEMENTATION_EXAMPLES.md` section 2 for detailed error handling examples.

### Testing Guide
See `docs/TESTING_GUIDE.md` for testing best practices.

### Module Architecture
See `.kiro/steering/MODULE_ARCHITECTURE.md` for module organization.

---

## 🚀 Implementation Order

1. **Create error module** (30 minutes)
   - Implement all error functions
   - Add basic tests

2. **Update config.vim** (30 minutes)
   - Replace error messages
   - Test configuration validation

3. **Update other modules** (1 hour)
   - cache.vim, command.vim, display.vim
   - compiler.vim, snippets.vim, svn.vim
   - Test each module

4. **Create comprehensive tests** (30 minutes)
   - Unit tests for error module
   - Integration tests for consistency
   - Run full test suite

5. **Documentation** (30 minutes)
   - Update error handling docs
   - Create Phase 3 summary
   - Update project status

---

## 💡 Tips for Success

### Do's
- ✅ Use consistent module names in error messages
- ✅ Make error messages descriptive and actionable
- ✅ Include context (e.g., invalid value, expected range)
- ✅ Test error handling thoroughly
- ✅ Document error messages in code

### Don'ts
- ❌ Don't use generic error messages
- ❌ Don't forget to update all modules
- ❌ Don't break existing error handling
- ❌ Don't skip testing
- ❌ Don't use inconsistent formats

---

## 📞 Quick Reference

### Error Format
```
[MODULE] Error description
```

### Error Functions
```vim
genero_tools#error#format(module, message)    " Format error message
genero_tools#error#echo(module, message)      " Echo error
genero_tools#error#warn(module, message)      " Display warning
genero_tools#error#error(module, message)     " Display error
genero_tools#error#debug(module, message)     " Log debug message
genero_tools#error#result(module, message)    " Create error result
```

### Module Names
- `config` - Configuration management
- `cache` - Cache operations
- `command` - Command execution
- `display` - Display modes
- `compiler` - Compiler integration
- `snippets` - Snippet system
- `svn` - SVN integration

---

## ✨ Summary

Phase 3 focuses on standardizing error messages across all modules. This single task will:

1. **Improve User Experience** - Consistent, helpful error messages
2. **Improve Debugging** - Clear error format makes debugging easier
3. **Improve Code Quality** - Standardized error handling across codebase
4. **Improve Maintainability** - Centralized error handling logic

**Estimated Effort:** 2-3 hours  
**Expected Outcome:** Consistent, helpful error messages across all modules

Ready to implement? Start with creating the error module!

---

**Status:** Ready for Implementation  
**Next Step:** Create `autoload/genero_tools/error.vim`  
**Last Updated:** March 19, 2026


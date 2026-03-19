# Testing Guide: Vim Genero-Tools Plugin

This guide explains how to run and write tests for the Vim Genero-Tools Plugin.

---

## Quick Start

### Run All Tests

```bash
./scripts/test.sh
```

This runs all unit, integration, and property-based tests and displays a summary.

### Run Specific Test File

```bash
# Run config tests
vim -N -u NONE -S tests/unit/test_config.vim -c "qa!"

# Run integration tests
vim -N -u NONE -S tests/integration/test_module_interactions.vim -c "qa!"

# Run property-based tests
vim -N -u NONE -S tests/properties/test_result_structure.vim -c "qa!"
```

### Run Test Runner Directly

```bash
vim -N -u NONE -S tests/run_tests.vim -c "qa!"
```

---

## Test Organization

### Unit Tests (`tests/unit/`)

Unit tests verify individual module functionality in isolation.

**Files:**
- `test_config.vim` - Configuration management (13 tests)
- `test_cache.vim` - Cache operations (7 tests)
- `test_command.vim` - Command execution (6 tests)
- `test_display.vim` - Display modes (6 tests)
- `test_lua_async.vim` - Lua async module (7 tests)
- `test_lua_ui.vim` - Lua UI module (8 tests)

**Example:**
```vim
function! test_config_init_sets_defaults() abort
  " Given: Fresh configuration
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  
  " When: Configuration is initialized
  call genero_tools#config#init()
  
  " Then: Defaults are set
  assert_equal(genero_tools#config#get('cache_enabled'), v:true)
endfunction
```

### Integration Tests (`tests/integration/`)

Integration tests verify module interactions and cross-module communication.

**Files:**
- `test_module_interactions.vim` - Module interaction tests (6 tests)

**Example:**
```vim
function! test_config_cache_integration() abort
  " Given: Fresh configuration and cache
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  if exists('g:genero_tools_cache')
    unlet g:genero_tools_cache
  endif
  
  " When: Config and cache are initialized
  call genero_tools#config#init()
  call genero_tools#cache#init()
  
  " Then: Cache respects config settings
  let l:cache_enabled = genero_tools#config#get('cache_enabled')
  assert_equal(l:cache_enabled, v:true)
endfunction
```

### Property-Based Tests (`tests/properties/`)

Property-based tests verify invariants and correctness properties.

**Files:**
- `test_result_structure.vim` - Result structure consistency (8 tests)
- `test_cache_consistency.vim` - Cache behavior properties (8 tests)
- `test_error_handling.vim` - Error handling properties (8 tests)

**Example:**
```vim
function! test_result_has_success_field() abort
  " Property: All results must have 'success' field
  let l:result = {
    \ 'success': v:true,
    \ 'data': {},
    \ 'error': '',
    \ 'timestamp': localtime()
    \ }
  
  assert_true(has_key(l:result, 'success'))
endfunction
```

---

## Writing Tests

### Test Structure

All tests follow the Arrange-Act-Assert (AAA) pattern:

```vim
function! test_something() abort
  " Arrange: Set up test conditions
  let l:input = 'test_value'
  
  " Act: Perform the action
  let l:result = genero_tools#some_function(l:input)
  
  " Assert: Verify the result
  assert_equal(l:result, 'expected_value')
endfunction
```

### Available Assertions

The test runner provides these assertion functions:

```vim
" Assert equality
assert_equal(actual, expected, [message])

" Assert true/false
assert_true(value, [message])
assert_false(value, [message])

" Assert empty/not empty
assert_empty(value, [message])
assert_not_empty(value, [message])

" Assert not equal
assert_not_equal(actual, expected, [message])
```

### Test Naming Convention

Test function names should:
1. Start with `test_`
2. Describe what is being tested
3. Use underscores to separate words

**Examples:**
- `test_config_init_sets_defaults`
- `test_cache_get_returns_empty_when_not_set`
- `test_command_result_success_has_data`

### Adding New Tests

1. Create test file in appropriate directory:
   - Unit tests: `tests/unit/test_module.vim`
   - Integration tests: `tests/integration/test_interaction.vim`
   - Property tests: `tests/properties/test_property.vim`

2. Write test functions following AAA pattern

3. Run tests to verify:
   ```bash
   ./scripts/test.sh
   ```

---

## Test Coverage

### Current Coverage

| Module | Tests | Coverage |
|--------|-------|----------|
| config | 13 | ✅ High |
| cache | 7 | ✅ High |
| command | 6 | ✅ Medium |
| display | 6 | ✅ Medium |
| lua/async | 7 | ✅ High |
| lua/ui | 8 | ✅ High |
| Integration | 6 | ✅ High |
| Properties | 24 | ✅ High |
| **Total** | **69** | **✅ High** |

### Coverage Goals

- **Unit Tests:** 80%+ coverage of module functions
- **Integration Tests:** All major workflows
- **Property Tests:** All invariants and correctness properties

---

## Debugging Tests

### Enable Debug Output

Add debug output to test functions:

```vim
function! test_something() abort
  let l:result = genero_tools#some_function('test')
  
  " Print debug info
  echom 'Result: ' . string(l:result)
  
  assert_equal(l:result, 'expected')
endfunction
```

### Run Single Test

```bash
# Run specific test function
vim -N -u NONE -S tests/unit/test_config.vim -c "call test_config_init_sets_defaults() | qa!"
```

### Check Test Output

```bash
# Run tests and capture output
./scripts/test.sh 2>&1 | tee test_results.txt
```

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Vim
        run: sudo apt-get install vim
      - name: Run tests
        run: ./scripts/test.sh
```

---

## Best Practices

### Do's
- ✅ Write descriptive test names
- ✅ Use AAA pattern (Arrange-Act-Assert)
- ✅ Test one thing per test function
- ✅ Clean up state in tests (unlet globals)
- ✅ Use meaningful assertion messages
- ✅ Group related tests in same file

### Don'ts
- ❌ Don't test implementation details
- ❌ Don't create dependencies between tests
- ❌ Don't use hardcoded paths
- ❌ Don't test external tools directly
- ❌ Don't ignore test failures
- ❌ Don't write overly complex tests

---

## Troubleshooting

### Tests Not Running

**Problem:** `./scripts/test.sh` fails to run

**Solution:**
```bash
# Make script executable
chmod +x scripts/test.sh

# Run with bash explicitly
bash scripts/test.sh
```

### Vim Not Found

**Problem:** Tests fail with "vim: command not found"

**Solution:**
```bash
# Install Vim
sudo apt-get install vim  # Ubuntu/Debian
brew install vim          # macOS
```

### Test Hangs

**Problem:** Test runner hangs indefinitely

**Solution:**
1. Check for infinite loops in test code
2. Add timeout to test runner
3. Use `Ctrl+C` to interrupt

### Assertion Failures

**Problem:** Tests fail with assertion errors

**Solution:**
1. Check assertion message for details
2. Add debug output to test
3. Verify test setup (Arrange phase)
4. Check module implementation

---

## Performance Testing

### Measure Test Execution Time

```bash
# Time test execution
time ./scripts/test.sh
```

### Profile Slow Tests

```vim
function! test_slow_operation() abort
  let l:start = reltime()
  
  " Perform operation
  call genero_tools#slow_function()
  
  let l:elapsed = reltimestr(reltime(l:start))
  echom 'Elapsed: ' . l:elapsed . 's'
endfunction
```

---

## Resources

- [Vim Testing Documentation](https://vim.fandom.com/wiki/Testing)
- [VimScript Assert Functions](https://vimhelp.appspot.com/eval.txt.html#assert)
- [Property-Based Testing](https://hypothesis.works/articles/what-is-property-based-testing/)

---

## Summary

The Vim Genero-Tools Plugin has comprehensive test coverage with:
- **69 tests** across unit, integration, and property-based categories
- **Easy test execution** with `./scripts/test.sh`
- **Clear test organization** by category and module
- **High code quality** through property-based testing

For questions or issues, see the main README or contact the development team.


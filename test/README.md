# Test Directory

This directory contains test files and test utilities for the Genero-Tools plugin.

## Test Files

### Unit Tests
- `test_error_highlighting.vim` - Error highlighting functionality
- `test_highlighting_integration.vim` - Highlighting integration tests
- `test_highlighting_with_signs.vim` - Highlighting with sign column
- `test_unified_signs.vim` - Unified sign column tests
- `test_sign_column_*.vim` - Sign column workflow and stability tests
- `test_svn_*.vim` - SVN integration tests
- `test_snippet_*.vim` / `test_snippet_*.lua` - Snippet tests
- `test_async_params.vim` / `test_async_params.lua` - Async parameter tests
- `test_vim_compatibility.vim` - Vim/Neovim compatibility tests

### Integration Tests
- `test_task_17_integration.vim` - Integration testing suite
- `test_task_18_final_checkpoint.vim` - Final checkpoint validation
- `test_autocompile_*.vim` - Autocompile workflow tests
- `test_preservation_*.vim` - Cache preservation tests

### Parser Tests
- `test_compiler_parser.vim` - Compiler output parser tests
- `test_svn_diff_parser.vim` - SVN diff parser tests
- `full_parser_test.vim` - Full parser test suite
- `simple_parser_test.vim` - Simple parser tests

### Test Utilities
- `run_*.sh` - Test runner scripts
- `property_tests.vim` - Property-based tests
- `verify_autocompile.vim` - Autocompile verification

### Test Output
- `test_*_results.txt` - Test result files
- `compiler_output_examples.txt` - Example compiler output

## Running Tests

### Run all tests
```bash
cd test
./run_task_17_tests.sh
```

### Run specific test
```bash
vim -u NONE -N -es -c "set runtimepath+=.." -c "source test_error_highlighting.vim" -c "qa!"
```

### Run parser tests
```bash
./run_parser_test.sh
```

## Test Organization

- **Unit tests** - Test individual components in isolation
- **Integration tests** - Test components working together
- **Parser tests** - Test compiler and SVN output parsing
- **Workflow tests** - Test complete user workflows

## Documentation

For task-related documentation and specifications, see `.kiro/specs/vim-genero-tools-plugin/`

For user guides and feature documentation, see `docs/`

# Vim Output Format Integration - Specification Summary

## Feature Overview

**Feature Name:** Vim Output Format Integration  
**Feature ID:** vim-output-format-integration  
**Status:** Requirements & Design Complete  
**Effort:** 3.5 days  
**Priority:** HIGH

## Problem Statement

The vim-genero-tools plugin currently displays function information using a generic format that is not optimized for specific use cases. The plugin needs to integrate three specialized output formats from genero-tools to provide better editor integration with improved performance and user experience.

## Solution

Implement integration of three optimized output formats from genero-tools into the vim-genero-tools plugin:

1. **Concise Format** (`--format=vim`) - Single-line signatures for tooltips and status bar
2. **Hover Format** (`--format=vim-hover`) - Multi-line with file location and metrics for hover tooltips
3. **Completion Format** (`--format=vim-completion`) - Tab-separated for autocomplete suggestions

## Key Features

### Plugin Features Using Formats

| Feature | Format | Use Case |
|---------|--------|----------|
| Hover Information | vim-hover | Show detailed info when hovering over function |
| Autocomplete | vim-completion | Show suggestions with signatures in autocomplete menu |
| Code Hints | vim | Show function signature in inline hints |
| Status Bar | vim | Display current function signature in status bar |
| Search Results | vim-hover | Show detailed info for each search result |

### Format Specifications

**Concise Format:**
```
function_name(param1: TYPE1, param2: TYPE2) -> RETURN_TYPE
```

**Hover Format:**
```
function_name(param1: TYPE1, param2: TYPE2) -> RETURN_TYPE
File: path/to/file.4gl:line_number
Complexity: N, LOC: M
```

**Completion Format:**
```
word<TAB>menu<TAB>info
```

## Requirements Summary

### 12 Core Requirements

1. **Hover Information Display** - Display detailed function info with file location and metrics
2. **Autocomplete Suggestions** - Show function signatures in autocomplete menu
3. **Code Hints Display** - Show function signatures in inline hints
4. **Function Signature in Status Bar** - Display current function signature
5. **Search Results Display** - Show detailed info for each search result
6. **Format Flag Implementation** - Use correct format flag for each feature
7. **Output Parsing** - Robust parsing of each format
8. **Performance Optimization** - Query execution <100ms
9. **Error Handling** - Graceful error handling with helpful messages
10. **Backward Compatibility** - Existing functionality continues to work
11. **Documentation** - Clear documentation of format integration
12. **Testing** - Comprehensive tests with >90% coverage

## Design Highlights

### Architecture

```
Vim/Neovim Editor
    ↓
vim-genero-tools Plugin
    ├─ Feature Layer (hover, autocomplete, hints, statusbar, search)
    ├─ Format Integration Layer (parsers, error handler, optimizer)
    └─ Query Layer (query builder, executor, cache)
    ↓
genero-tools Query System
```

### Format Parsers

- **Concise Format**: Display directly (trim whitespace)
- **Hover Format**: Split lines and display directly
- **Completion Format**: Split tabs and pass to completion API

### Error Handling

- Invalid format → error message
- Missing database → helpful suggestion
- Malformed output → graceful fallback
- No results → empty result set

### Performance Optimization

- Result caching to avoid repeated queries
- Async query execution (Neovim)
- Optimized parsing logic
- Format selection for performance

## Implementation Plan

### Phase 1: Add Format Flags to Query Commands (0.5 days)
- Add `--format=vim-hover` to hover query
- Add `--format=vim-completion` to autocomplete query
- Add `--format=vim` to code hints query
- Add `--format=vim` to status bar query
- Add `--format=vim-hover` to search query

### Phase 2: Update Display Logic (0.5 days)
- Update hover display to split lines and show directly
- Update autocomplete display to split tabs and pass to completion API
- Update code hints display to show signature directly
- Update status bar display to show signature directly
- Update search results display to split lines and show in quickfix

### Phase 3: Error Handling (0.25 days)
- Add error handling for format flag queries

### Phase 4: Testing & Documentation (0.75 days)
- Integration tests for format flags
- Integration tests for display logic
- Backward compatibility tests
- Documentation

**Total Effort: 2 days**

## Success Criteria

- ✅ All 12 requirements implemented
- ✅ All 5 plugin features use correct format
- ✅ Output parsing is robust and handles edge cases
- ✅ Query execution time <100ms
- ✅ Error handling is graceful and helpful
- ✅ Backward compatibility maintained
- ✅ Documentation is clear and complete
- ✅ Test coverage >90%

## Deliverables

### Documentation
- `requirements.md` - Complete requirements document
- `design.md` - Technical design with architecture and correctness properties
- `tasks.md` - Implementation tasks organized by phase
- `docs/FORMAT_INTEGRATION.md` - Format integration guide
- `docs/FEATURE_FORMAT_INTEGRATION.md` - Feature integration guide
- `docs/FORMAT_TROUBLESHOOTING.md` - Troubleshooting guide

### Implementation Files
- `autoload/genero_tools/hover.vim` - Add format flag and update display
- `autoload/genero_tools/complete.vim` - Add format flag and update display
- `autoload/genero_tools/hints.vim` - Add format flag and update display
- `autoload/genero_tools/statusline.vim` - Add format flag and update display
- `autoload/genero_tools/search.vim` - Add format flag and update display

### Test Files
- `test/integration/format_flags_test.vim` - Format flag tests
- `test/integration/display_logic_test.vim` - Display logic tests
- `test/integration/backward_compat_test.vim` - Backward compatibility tests

## Related Documentation

- [VIM_OUTPUT_FORMATS.md](../../update/VIM_OUTPUT_FORMATS.md) - Format specifications
- [FORMAT_EXAMPLES.md](../../update/FORMAT_EXAMPLES.md) - Concrete examples
- [VIM_PLUGIN_INTEGRATION_GUIDE.md](../../update/VIM_PLUGIN_INTEGRATION_GUIDE.md) - Integration patterns
- [SPEC_SUMMARY.md](../../update/SPEC_SUMMARY.md) - Feature overview

## Next Steps

1. Review and approve requirements and design
2. Begin Phase 1: Core Format Integration
3. Implement format parsers and flag manager
4. Proceed to Phase 2: Feature Integration
5. Execute comprehensive testing (Phase 3 & 4)
6. Release feature

---

**Status:** Specification Complete - Ready for Implementation  
**Created:** 2026-03-25  
**Version:** 1.0

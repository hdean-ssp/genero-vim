# Pending Features and Ideas

**Date:** March 19, 2026  
**Status:** Comprehensive Feature Roadmap  
**Last Updated:** After documentation review and cleanup

---

## Overview

This document summarizes all features, enhancements, and ideas identified in the codebase and documentation that are awaiting implementation. These are organized by priority and category.

---

## Table of Contents

1. [Reserved/Placeholder Features](#reservedplaceholder-features)
2. [Future Enhancements by Module](#future-enhancements-by-module)
3. [Error Handling Improvements](#error-handling-improvements)
4. [UI/UX Enhancements](#uiux-enhancements)
5. [Performance Optimizations](#performance-optimizations)
6. [Integration Opportunities](#integration-opportunities)

---

## Reserved/Placeholder Features

### AI API Integration (Reserved)

**Location:** `lua/genero_tools/async.lua`

**Status:** Reserved for future implementation

**Details:**
```lua
function M.call_ai_api(prompt, context, callback)
  -- Reserved for future AI features
  -- Not implemented in current version
end
```

**Purpose:** Enable AI-powered code analysis and suggestions

**Potential Use Cases:**
- Intelligent error explanations
- Code optimization suggestions
- Automated refactoring recommendations
- Smart code completion

**Implementation Notes:**
- Requires external AI API integration (e.g., OpenAI, Claude)
- Should be optional and configurable
- Needs rate limiting and caching
- Privacy considerations for code context

---

## Future Enhancements by Module

### 1. SVN Diff Markers Module

**Location:** `docs/SVN_DIFF_MARKERS.md`

**Phase:** Phase 4+

**Planned Enhancements:**

1. **Integration with Compiler Signs**
   - Already compatible via separate sign groups
   - Could optimize display when both present
   - Status: Ready for implementation

2. **Configuration Options for Sign Appearance**
   - Customize sign symbols
   - Customize colors
   - Status: Design needed

3. **Status Line Integration**
   - Show SVN change summary in statusline
   - Display added/modified/deleted counts
   - Status: Design needed

4. **Blame Information Display**
   - Show author and date for each line
   - Hover information in Neovim
   - Status: Research needed

5. **Diff Navigation**
   - Jump to next/previous change
   - Commands: `:GeneroSVNNextChange`, `:GeneroSVNPrevChange`
   - Status: Design needed

---

### 2. Unified Sign Column Module

**Location:** `docs/UNIFIED_SIGN_COLUMN.md`

**Current Status:** Implemented and working

**Planned Enhancements:**

1. **Configurable Separators**
   - Allow users to choose between `|`, `:`, `/`, etc.
   - Configuration option: `sign_separator`
   - Status: Ready for implementation

2. **Priority Ordering**
   - Configurable which sign type takes precedence
   - Configuration option: `sign_priority_order`
   - Status: Ready for implementation

3. **Compact Mode**
   - Use single character combinations (e.g., `E` for error+modified)
   - Configuration option: `sign_compact_mode`
   - Status: Design needed

4. **Hover Information (Neovim)**
   - Show both sign details on hover
   - Requires Neovim floating window
   - Status: Design needed

5. **Sign Stacking**
   - Support more than 2 simultaneous signs per line
   - Handle multiple error types + SVN markers
   - Status: Research needed

---

### 3. Error Handling and Parsing

**Location:** `docs/FGLFORM_OUTPUT_PARSING.md`

**Current Status:** Basic parsing implemented

**Planned Enhancements:**

1. **Error Grouping**
   - Group errors by type (syntax, semantic, etc.)
   - Group by file
   - Status: Design needed

2. **Error Filtering**
   - Show only errors (hide warnings)
   - Show only warnings
   - Show only specific error types
   - Configuration options: `show_errors`, `show_warnings`, `error_filter`
   - Status: Ready for implementation

3. **Error Statistics**
   - Count errors by type
   - Count errors by file
   - Display in statusline or floating window
   - Status: Design needed

4. **Error Trends**
   - Track errors over time
   - Show improvement/regression
   - Requires persistent storage
   - Status: Research needed

5. **Custom Error Handlers**
   - User-defined error processing
   - Custom error formatting
   - Custom error actions
   - Status: Design needed

---

## UI/UX Enhancements

### 1. Floating Window Improvements

**Current Status:** Basic floating windows implemented

**Planned Enhancements:**

1. **Configurable Separators in Floating Windows**
   - Different border styles
   - Custom border characters
   - Status: Ready for implementation

2. **Window Persistence**
   - Remember window size/position
   - Restore on next session
   - Status: Design needed

3. **Window Stacking**
   - Multiple floating windows
   - Window management commands
   - Status: Design needed

4. **Interactive Floating Windows**
   - Clickable elements
   - Keyboard navigation
   - Status: Research needed (Neovim only)

---

### 2. Statusline Integration

**Current Status:** Lualine integration implemented

**Planned Enhancements:**

1. **SVN Status in Statusline**
   - Show added/modified/deleted counts
   - Configuration option: `statusline_svn_info`
   - Status: Ready for implementation

2. **Compilation Status**
   - Show last compilation time
   - Show compilation status (success/failure)
   - Status: Design needed

3. **Cache Status**
   - Show cache hit rate
   - Show cache size
   - Status: Design needed

4. **Performance Metrics**
   - Show query execution time
   - Show cache performance
   - Status: Design needed

---

## Performance Optimizations

### 1. Caching Improvements

**Current Status:** Basic caching implemented

**Planned Enhancements:**

1. **Persistent Cache**
   - Cache results to disk
   - Survive editor restarts
   - Configuration option: `persistent_cache`
   - Status: Design needed

2. **Cache Compression**
   - Compress large cache entries
   - Reduce memory usage
   - Status: Research needed

3. **Cache Invalidation Strategies**
   - Smart invalidation based on file changes
   - Partial invalidation
   - Status: Design needed

4. **Cache Statistics**
   - Track hit/miss rates
   - Track cache size
   - Display in statusline
   - Status: Ready for implementation

---

### 2. Query Optimization

**Current Status:** Basic query execution

**Planned Enhancements:**

1. **Query Batching**
   - Combine multiple queries
   - Reduce overhead
   - Status: Design needed

2. **Incremental Search**
   - Search as user types
   - Progressive result display
   - Status: Design needed

3. **Result Pagination**
   - Already implemented
   - Could add navigation commands
   - Status: Ready for implementation

4. **Parallel Query Execution**
   - Already implemented in Lua
   - Could expand to more operations
   - Status: Ready for implementation

---

## Integration Opportunities

### 1. LSP Integration (Future)

**Status:** Not started

**Potential Features:**
- Use LSP for code analysis instead of query.sh
- Integrate with existing LSP servers
- Provide LSP-based code hints
- Status: Research needed

**Considerations:**
- Requires LSP client library
- May conflict with existing query.sh approach
- Could be optional/alternative

---

### 2. External Tool Integration

**Status:** Not started

**Potential Integrations:**
- Git integration (beyond SVN)
- Code formatter integration
- Linter integration
- Test runner integration
- Status: Design needed

---

### 3. IDE Feature Parity

**Status:** Ongoing

**Potential Features:**
- Refactoring tools
- Code generation
- Template expansion
- Macro expansion
- Status: Design needed

---

## Configuration Enhancements

### 1. Per-File Configuration

**Current Status:** Partially implemented (.genero-hints)

**Planned Enhancements:**

1. **Extend Per-File Config**
   - Support for compiler settings per file
   - Support for display settings per file
   - File: `.genero-config` (JSON format)
   - Status: Design needed

2. **Project-Level Configuration**
   - `.genero/config.json` in project root
   - Override global settings
   - Status: Design needed

3. **Configuration Inheritance**
   - Hierarchy: global → project → file
   - Merge configurations
   - Status: Design needed

---

## Documentation Improvements

### 1. User Documentation

**Status:** Comprehensive (recently updated)

**Potential Additions:**
- Video tutorials
- Interactive examples
- Troubleshooting guide expansion
- FAQ section
- Status: Ready for implementation

---

### 2. Developer Documentation

**Status:** Comprehensive (LUA_API_REFERENCE.md created)

**Potential Additions:**
- Architecture deep-dive
- Module interaction diagrams
- Performance profiling guide
- Extension development guide
- Status: Ready for implementation

---

## Testing Improvements

### 1. Test Coverage

**Current Status:** 94 tests (83% coverage)

**Planned Enhancements:**

1. **Integration Tests**
   - Real-world scenario testing
   - Multi-module interaction tests
   - Status: Ready for implementation

2. **Performance Tests**
   - Benchmark query execution
   - Cache performance tests
   - Status: Design needed

3. **Regression Tests**
   - Automated regression detection
   - Historical performance tracking
   - Status: Design needed

---

## Priority Matrix

### High Priority (Ready for Implementation)

1. ✅ Error filtering (show/hide errors/warnings)
2. ✅ Configurable sign separators
3. ✅ SVN status in statusline
4. ✅ Cache statistics display
5. ✅ Result pagination navigation

### Medium Priority (Design Needed)

1. 🔄 Error grouping and statistics
2. 🔄 Compact sign mode
3. 🔄 Persistent cache
4. 🔄 Per-file configuration extension
5. 🔄 Hover information for signs

### Low Priority (Research Needed)

1. 🔍 AI API integration
2. 🔍 LSP integration
3. 🔍 Blame information display
4. 🔍 Error trends tracking
5. 🔍 Interactive floating windows

---

## Implementation Roadmap

### Phase 5 (Next)
- Error filtering
- Configurable sign separators
- SVN statusline integration
- Cache statistics

### Phase 6
- Error grouping
- Compact sign mode
- Persistent cache
- Per-file configuration

### Phase 7+
- AI API integration
- LSP integration
- Advanced features (blame, trends, etc.)

---

## Notes for Developers

1. **AI API Integration** - Reserved placeholder exists in `lua/genero_tools/async.lua`
2. **Lua Layer** - Future enhancements noted in `lua/genero_tools/init.lua`
3. **Snippet Integration** - Placeholder for future autocomplete integration in `lua/genero_tools/snippets/integration.lua`
4. **Configuration** - All new features should be configurable via `g:genero_tools_config`
5. **Documentation** - Update relevant docs when implementing features

---

## See Also

- [README.md](README.md) - Main documentation
- [LUA_API_REFERENCE.md](LUA_API_REFERENCE.md) - Lua API documentation
- [DOCUMENTATION_REVIEW_COMPLETE.md](DOCUMENTATION_REVIEW_COMPLETE.md) - Documentation status
- [SVN_DIFF_MARKERS.md](SVN_DIFF_MARKERS.md) - SVN feature details
- [UNIFIED_SIGN_COLUMN.md](UNIFIED_SIGN_COLUMN.md) - Sign column details
- [FGLFORM_OUTPUT_PARSING.md](FGLFORM_OUTPUT_PARSING.md) - Error parsing details

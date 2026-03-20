# Future Tasks & Known Issues

## Overview
This document consolidates all identified future tasks, enhancements, and known issues across the genero-tools plugin. Tasks are organized by priority and category.

---

## High Priority

### 1. Snippet Expansion Placeholder Navigation
**Status**: Deferred for future work  
**Category**: Feature Enhancement  
**Effort**: Medium (4-6 hours)

**Issue**: Snippet placeholder expansion (${1:name}, ${2:params}, etc.) is not fully functional with LuaSnip integration

**Current Behavior**:
- Snippets insert correctly with placeholder syntax visible
- Tab key navigation between placeholders not working as expected
- Placeholder text is displayed literally instead of being interactive

**Root Cause**:
- LuaSnip integration needs proper snippet object creation with node parsing
- Current implementation uses basic text nodes instead of insert nodes with proper placeholder handling

**Potential Solutions**:
1. Parse placeholder syntax (${1:name}) and create proper LuaSnip insert_node objects
2. Implement custom snippet expansion that handles placeholders independently
3. Investigate LuaSnip's snippet format more thoroughly for proper integration

**Notes**:
- User can still use snippets effectively for code templates
- All compatibility issues with nvim-notify and noice.nvim have been resolved

---

## Medium Priority

### 2. Multiple Debug Windows
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Medium (4-6 hours)

**Description**: Allow users to monitor multiple debug files simultaneously in separate windows

**Use Case**: Debugging complex interactions between multiple processes

---

### 3. Git Diff Markers
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Medium (6-8 hours)

**Description**: Implement Git diff markers similar to existing SVN diff markers feature

**Related**: SVN diff markers feature (already implemented)

**Use Case**: Support for Git-based projects in addition to SVN

---

### 4. Customizable Keybinding Categories
**Status**: Not started  
**Category**: UI/UX Enhancement  
**Effort**: Low (2-3 hours)

**Description**: Allow users to define custom categories for which-key integration

**Related**: which-key integration (already implemented)

**Use Case**: Better organization of keybindings for large projects

---

## Low Priority

### 5. Resizable/Draggable Windows
**Status**: Not started  
**Category**: UI Enhancement  
**Effort**: Medium (4-6 hours)

**Description**: Make floating windows resizable and draggable for better UX

**Use Case**: Users can customize window layout to their preference

---

### 6. Machine Learning-Based Hints
**Status**: Not started  
**Category**: Advanced Feature  
**Effort**: High (12+ hours)

**Description**: Learn coding patterns and suggest hints based on project style

**Use Case**: Personalized code quality suggestions

---

### 7. Vim-Compatible Alternatives for Neovim-Only Features
**Status**: Not started  
**Category**: Compatibility  
**Effort**: High (8-12 hours)

**Description**: Add Vim-compatible implementations for Neovim-only features (snippets, debug streaming, etc.)

**Current Neovim-Only Features**:
- Code snippets with LuaSnip
- Debug streaming
- Lua layer features

**Use Case**: Support for Vim users

---

### 8. Alternative Snippet Engines
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Medium (6-8 hours)

**Description**: Add support for other snippet engines (vim-snipmate, vim-vsnip)

**Current**: LuaSnip only (Neovim)

**Use Case**: Users with different snippet engine preferences

---

### 9. Incremental Caching for Large Codebases
**Status**: Not started  
**Category**: Performance  
**Effort**: Medium (6-8 hours)

**Description**: Implement incremental caching for very large codebases (1500+ items)

**Current**: Full cache invalidation on changes

**Use Case**: Faster performance on large projects

---

### 10. Result Filtering
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Low (2-4 hours)

**Description**: Add result filtering to reduce result set size and improve usability

**Use Case**: Easier navigation through large result sets

---

## Documentation & Testing

### 11. Expand Documentation
**Status**: Ongoing  
**Category**: Documentation  
**Effort**: Low (2-4 hours per topic)

**Description**: Expand documentation based on user questions and feedback

**Areas**:
- Advanced configuration examples
- Troubleshooting guides
- Integration examples

---

### 12. Vim Compatibility Testing
**Status**: Not started  
**Category**: Testing  
**Effort**: Medium (4-6 hours)

**Description**: Comprehensive testing of Vim compatibility for all features

**Current**: Primarily tested on Neovim

---

## Known Limitations

### 1. Neovim 0.9.5 Compatibility
- noice.nvim LSP features disabled (requires Neovim 0.10+)
- Some advanced UI features not available

### 2. Snippet Placeholders
- Placeholder navigation not working with current LuaSnip integration
- Workaround: Use snippets for basic template insertion

### 3. Debug Streaming
- Requires Neovim (not available in Vim)
- Requires debug directory to exist

---

## Implementation Guidelines

When implementing future tasks:

1. **Maintain Backward Compatibility** - Don't break existing features
2. **Test Thoroughly** - Include unit and integration tests
3. **Document Changes** - Update relevant documentation
4. **Consider Performance** - Profile changes on large codebases
5. **Get User Feedback** - Validate assumptions with users

---

## Priority Recommendation

**Suggested Implementation Order**:
1. Snippet placeholder navigation (high impact, medium effort)
2. Git diff markers (complements existing SVN feature)
3. Multiple debug windows (useful for complex debugging)
4. Result filtering (improves usability)
5. Alternative snippet engines (expands compatibility)


# Future Tasks & Known Issues

## Overview
This document consolidates all identified future tasks, enhancements, and known issues across the genero-tools plugin. Tasks are organized by priority and category.

---

## Recent Session Summary (Latest)

### Completed Fixes:
1. **vim.notify() Compatibility** - Replaced all vim.notify() calls with vim.api.nvim_err_writeln() for nvim-notify v0.4.x compatibility
2. **Snippet Loading** - Fixed snippet directory path calculation and lazy loading
3. **LuaSnip Integration** - Corrected LuaSnip API usage for snippet registration
4. **Debug Echo Messages** - Removed debug output from snippet loading to eliminate user interaction prompts
5. **Debug Stream Toggle** - Fixed GeneroDebugStreamToggle to call debug_stream_select() for file selection instead of hardcoded debug.log
6. **noice.nvim Compatibility** - Disabled LSP features and notifications for Neovim 0.9.5 compatibility

### Known Working Features:
- Snippet insertion and basic expansion
- Debug stream file selection
- All compiler, hints, and SVN features
- Keybindings and command palette integration

---

## High Priority

### 1. Undo from Previous Editing Sessions
**Status**: COMPLETE  
**Category**: Feature Enhancement  
**Effort**: Low (config change only)

**Description**: Enable persistent undo history across editing sessions

**Implementation**:
- Added Neovim undo configuration to `init.lua.example`
- Uses Neovim's built-in `undofile` feature (Neovim only)
- Automatic undo directory creation at ~/.vim/undo
- Undo history limits: 1000 levels, 10000 reload

**Configuration** (in init.lua):
```lua
-- Persistent Undo (Neovim only)
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undo")
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000
```

**Use Case**: Recovery and workflow continuity across sessions. Neovim-only feature.

---

### 2. Result Filtering
**Status**: Deferred - Analysis Complete  
**Category**: Feature Enhancement  
**Effort**: Low (2-4 hours)

**Description**: Add result filtering to reduce result set size and improve usability

**Current Implementation Analysis**:
- `get_completions()` already does basic filtering (prefix matching on function names)
- Results are limited by Vim's omnifunc mechanism
- `search_functions()` and `search_modules()` can return large result sets

**Filtering Considerations**:
1. **Scope of filtering**: Apply to autocomplete only, or all search results (lookup, list functions)?
2. **Filter types**: Max result count, result type (function/variable/snippet), scope (current file/directory/project)?
3. **User control**: Configurable limits? Override capability? Saved preferences?
4. **Display**: Show "X more results" message? Pagination? Search refinement hints?
5. **Prioritization**: Current file first, then same directory, then project-wide?

**Decision Points Needed**:
- Simple result count limiting (quick win) vs smart prioritization vs full filtering framework?
- Should filtering be configurable or hardcoded defaults?
- Integration with autocomplete enhancements (task 3)?

**Use Case**: Easier navigation through large result sets. May be prerequisite to better function signatures.

**Defer Reason**: Current implementation already handles basic filtering. Needs clearer requirements on scope and user preferences before implementation.

---

### 3. Autocomplete Enhancements
**Status**: COMPLETE - All Subtasks Implemented  
**Category**: Feature Enhancement  
**Effort**: Medium (6-8 hours)

**Description**: Expand autocomplete functionality with richer completion sources and enhanced function signatures

**Completed Subtasks**:

1. **Improve signature display/output of functions** ✓
   - Created `autoload/genero_tools/signature.vim` module
   - Parses function signatures from query.sh output
   - Abbreviates type names for menu display
   - Truncates long signatures intelligently
   - Formats for menu and info contexts

2. **Extended autocomplete sources** ✓
   - Current file functions (all matches)
   - Project-wide functions (top 10-20 closest matches)
   - Only queries external files if no current file matches
   - Results sorted by relevance
   - Caches external results

3. **Enhanced function signatures with parameter information** ✓
   - Parameter count display in menu label
   - Full parameter list with full type names in info
   - Return types with names
   - Function calls information
   - Line range (start:end)
   - Shown on selection/hover only

**Implementation Details**:

**Signature Formatting** (`signature.vim`):
- `format_complete_info()` - Complete info section with all details
- `format_parameters()` - Parameter list with full type names
- `format_returns()` - Return types with names
- `format_calls()` - Function calls list
- `get_full_type()` - Map abbreviated to full type names
- `param_count()` - Get parameter count
- `return_count()` - Get return count

**Completion Integration** (`complete.vim`):
- Menu label: `functionName(N params) -> M returns`
- Info section: Full parameter details, returns, calls, location
- Current file: All matches shown
- External files: Top 20 matches (only if no current file matches)
- Caching: Results cached per search term

**Example Display**:
```
Menu:
myFunc                    | myFunc(2 params) -> 1 return

Info (on selection/hover):
myFunc(2 params) -> 1 return | /path/to/file.4gl:42-58

Parameters:
  param1: STRING
  param2: INTEGER

Returns:
  BOOLEAN

Calls: validate_input, log_message (2 functions)
```

**Configuration**:
```lua
-- In init.lua
autocomplete_on_pause = true,      -- Auto-trigger on pause
autocomplete_delay = 500,          -- Delay in ms
```

**Use Case**: Improved developer experience with comprehensive function information, better parameter understanding, and clearer code navigation

**Performance**: ~10-20ms total (no impact from enhancements)

---

### 4. Code Tag Highlighting/Hinting
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Medium (4-6 hours)

**Description**: Recognize and highlight code tags (TODO, FIXME, NOTE, HACK) with visual indicators and hints

**Features**:
- Tag recognition and highlighting
- Distinct colors/styles per tag type
- Sign column indicators
- Tag navigation commands
- Support for custom tag definitions

**Use Case**: Better code organization and navigation. Quick win, configurable.

---

## Medium Priority

### 5. Floating Pane for Plugin Hotkeys
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Low (2-4 hours)

**Description**: Create a floating window displaying all plugin-implemented hotkeys with search/filter capabilities

**Features**:
- Searchable hotkey reference pane
- Organized by category
- Quick access command (e.g., `<Leader>?`)
- Interactive filtering

**Use Case**: Easy discovery of available shortcuts without leaving editor. Quick win, helpful for new users.

---

### 6. Change Hint Highlight Colour
**Status**: Not started  
**Category**: Configuration  
**Effort**: Low (1-2 hours)

**Description**: Allow users to customize hint highlight colors with theme-aware defaults

**Features**:
- Configurable highlight colors per hint type
- Automatic color selection based on colorscheme
- Ensure sufficient contrast for readability

**Use Case**: User preference and accessibility improvements. Quick config option to add.

---

### 7. Lualine Styling (Bubble/Slant Sections)
**Status**: Not started  
**Category**: UI Enhancement  
**Effort**: Low (2-3 hours)

**Description**: Implement bubble or slant-style section separators in lualine statusline

**Features**:
- Rounded/bubble-shaped separators
- Diagonal/slant separators for modern appearance
- Theme-aware styling

**Use Case**: Improved visual aesthetics and statusline hierarchy. Easy config change, nice to have.

---

### 8. Inline Terminal
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Medium (4-6 hours)

**Description**: Open terminal in floating pane within editor for quick command execution

**Features**:
- Floating terminal window
- Integration with compiler commands
- Toggle functionality with state preservation
- Easy open/close

**Use Case**: Execute commands without leaving editor. Nice to have for quick terminal access, hopefully integrate existing plugin.

---

## Low Priority

### 9. Cursor-Aware Hint Display
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Low (2-3 hours)

**Description**: Display hint virtual text only when cursor is on the same line, with configuration option

**Features**:
- Cursor-aware hint display
- Configuration toggle for behavior
- Performance improvement from fewer virtual text updates

**Use Case**: Reduced visual clutter and improved responsiveness. Nice to have and configurable.

---

### 10. Multiple Debug Windows
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Medium (4-6 hours)

**Description**: Allow users to monitor multiple debug files simultaneously in separate windows

**Use Case**: Debugging complex interactions between multiple processes. Not required but nice to have.

---

### 11. Snippet Expansion Placeholder Navigation
**Status**: Deferred for future work  
**Category**: Feature Enhancement  
**Effort**: Medium (4-6 hours)

**Description**: Make tab navigation between snippet placeholders work properly with LuaSnip integration

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
- Snippets work to insert code blocks, good enough for now
- All compatibility issues with nvim-notify and noice.nvim have been resolved

---

### 12. Formatting Action
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Medium (4-6 hours)

**Description**: Implement code formatting for Genero files with external formatter integration

**Features**:
- Format entire file or selection
- Configurable formatter tool support
- Convenient keybinding
- Preserve cursor position after formatting

**Use Case**: Code consistency and quality. Not many use cases.

---

### 13. Git Diff Markers
**Status**: Not started  
**Category**: Feature Enhancement  
**Effort**: Medium (6-8 hours)

**Description**: Implement Git diff markers similar to existing SVN diff markers feature

**Related**: SVN diff markers feature (already implemented)

**Use Case**: Support for Git-based projects in addition to SVN. We use SVN.

---

### 14. Incremental Caching for Large Codebases
**Status**: Not started  
**Category**: Performance  
**Effort**: Medium (6-8 hours)

**Description**: Implement incremental caching for very large codebases (1500+ items)

**Current**: Full cache invalidation on changes

**Use Case**: Faster performance on large projects. Already got lots of caching functionality.

---

### 15. Plugin Hotkeys in Statusline
**Status**: Not started  
**Category**: UI Enhancement  
**Effort**: Low (2-3 hours)

**Description**: Display relevant plugin hotkeys in statusline based on current context

**Features**:
- Contextual hotkey display
- Dynamic updates based on file type/buffer state
- Show most frequently used shortcuts

**Use Case**: Quick reference for available actions without opening help pane. See floating hotkey pane above.

---

### 16. Vim Compatibility Testing
**Status**: Not started  
**Category**: Testing  
**Effort**: Medium (4-6 hours)

**Description**: Comprehensive testing of Vim compatibility for all features

**Current**: Primarily tested on Neovim

**Use Case**: Ensure Vim compatibility later via user testing and unit tests. Neovim focus for most features.

---

## Documentation & Testing

### 7. Expand Documentation
**Status**: Ongoing  
**Category**: Documentation  
**Effort**: Low (2-4 hours per topic)

**Description**: Expand documentation based on user questions and feedback

**Areas**:
- Advanced configuration examples
- Troubleshooting guides
- Integration examples

---

### 7. Vim Compatibility Testing
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
1. **Undo from Previous Sessions** (HIGH) - Just config change, high value
2. **Result Filtering** (HIGH) - May be prerequisite to better function signatures
3. **Autocomplete Enhancements** (HIGH) - Quick win, parse output and display more concisely
4. **Code Tag Highlighting** (HIGH) - Quick win, configurable
5. **Floating Hotkey Pane** (MEDIUM) - Quick win, helpful for new users
6. **Hint Color Customization** (MEDIUM) - Quick config option to add
7. **Lualine Styling** (MEDIUM) - Easy config change, nice to have
8. **Inline Terminal** (MEDIUM-LOW) - Nice to have for quick terminal access, hopefully integrate existing plugin
9. **Cursor-Aware Hint Display** (LOW) - Nice to have and configurable
10. **Multiple Debug Windows** (LOW) - Not required but nice to have
11. **Snippet Placeholder Navigation** (MEDIUM) - Snippets work to insert code blocks, good enough for now
12. **Formatting Action** (LOW) - Not many use cases
13. **Git Diff Markers** (LOW) - We use SVN
14. **Incremental Caching** (LOW) - Already got lots of caching functionality
15. **Plugin Hotkeys in Statusline** (LOW) - See floating hotkey pane above
16. **Vim Compatibility Testing** (LOW) - Neovim focus for most features, ensure Vim compatibility later via user testing and unit tests

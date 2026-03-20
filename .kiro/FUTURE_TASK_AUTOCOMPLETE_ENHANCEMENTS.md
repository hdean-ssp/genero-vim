# Future Task: Autocomplete Enhancements

## Overview
Expand autocomplete functionality to provide richer completion options and better context when Ctrl+N is triggered.

## Task 1: Extended Autocomplete Sources

### Current State
- Only parses functions from the current file using `genero-tools query.sh`

### Proposed Enhancements
1. **Cross-file function discovery**
   - Utilize additional functions of `genero-tools query.sh` to return matching functions from other files
   - Scope results intelligently (e.g., same project, same directory, all indexed files)

2. **Variable completion**
   - Extract variables from current file
   - Include in autocomplete suggestions alongside functions

3. **Snippet integration**
   - Include configured snippets in autocomplete options
   - Show snippet expansions as completion candidates

### Implementation Considerations
- Performance: Cache results to avoid excessive file scanning
- Relevance: Prioritize suggestions (current file > same directory > project-wide)
- Deduplication: Handle duplicate suggestions across sources

---

## Task 2: Enhanced Function Signatures in Autocomplete

### Current State
- Function lists show only function names

### Proposed Enhancements
1. **Signature information display**
   - Show parameter format/types/count in completion menu
   - Example: `myFunction(param1: STRING, param2: INTEGER) -> BOOLEAN`

2. **Parameter hints**
   - Display parameter details on selection
   - Show required vs optional parameters
   - Include parameter descriptions if available

### Implementation Considerations
- Parse function signatures from source code or metadata
- Format signatures for readability in completion menu
- Consider Neovim's completion menu limitations for display
- Integrate with existing hint system if applicable

---

## Related Files
- `autoload/genero_tools/complete.vim` - Main autocomplete logic
- `autoload/genero_tools/codebase.vim` - Codebase querying
- `genero-tools/query.sh` - External query tool

## Priority
Medium - Quality of life improvement for development workflow


---

## Task 3: Improve Signature Display/Output of Functions

### Current State
- Long function signatures get cut off in display
- Output from `query.sh` may not be optimally formatted for concise display

### Proposed Enhancements
1. **Parse and reformat query.sh output**
   - Extract signature information from `query.sh` output
   - Create custom formatting for concise display
   - Handle long signatures intelligently (truncation, wrapping, abbreviation)

2. **Signature truncation strategies**
   - Abbreviate parameter types (e.g., `STRING` → `STR`, `INTEGER` → `INT`)
   - Collapse long parameter lists with ellipsis
   - Show full signature on hover/selection

3. **Display optimization**
   - Ensure signatures fit within completion menu width
   - Maintain readability while maximizing information density
   - Consider multi-line display for very long signatures

### Implementation Considerations
- Balance between information and display space
- Maintain consistency with existing display formatting
- Test with various function signature lengths
- Consider user preferences for display style

### Related Files
- `autoload/genero_tools/complete.vim` - Autocomplete display logic
- `genero-tools/query.sh` - External query tool output format
- `autoload/genero_tools/display.vim` - Display utilities

### Priority
Medium - Improves usability for functions with complex signatures


---

## Task 4: Floating Pane for Plugin Hotkeys

### Current State
- Hotkeys are documented but not easily accessible from within the editor
- Users must reference external documentation or config files to discover available shortcuts

### Proposed Enhancements
1. **Hotkey reference pane**
   - Create a floating window displaying all plugin-implemented hotkeys
   - Show keybinding, command name, and brief description
   - Organize by category (compilation, navigation, hints, etc.)

2. **Quick access command**
   - Implement a shortcut to toggle the hotkey reference pane
   - Suggested: `<Leader>?` or similar mnemonic
   - Allow closing with `q` or `Esc`

3. **Interactive features**
   - Searchable/filterable hotkey list
   - Highlight hotkeys by category with different colors
   - Show which hotkeys are currently mapped vs available

### Implementation Considerations
- Parse keybindings from configuration
- Generate help text from command definitions
- Use Neovim's floating window API for display
- Keep pane lightweight and responsive
- Consider integration with which-key plugin if available

### Related Files
- `autoload/genero_tools/keybindings.vim` - Keybinding definitions
- `autoload/genero_tools/which_key.vim` - Which-key integration
- `plugin/genero_tools.vim` - Plugin initialization

### Priority
Low - Nice-to-have feature for discoverability and user experience


---

## Task 5: Lualine Styling (Bubble/Slant Sections)

### Current State
- Statusline may use basic styling without visual separation

### Proposed Enhancements
1. **Bubble-style sections**
   - Implement rounded/bubble-shaped section separators in lualine
   - Create visual distinction between plugin status areas

2. **Slant-style sections**
   - Add diagonal/slant separators for modern appearance
   - Improve visual hierarchy of statusline components

3. **Theme integration**
   - Ensure styling respects user's color scheme
   - Provide configuration options for section style preference

### Implementation Considerations
- Use lualine's built-in separator customization
- Test with various color schemes
- Document styling options in configuration

### Priority
Low - Visual enhancement for aesthetics

---

## Task 6: Plugin Hotkeys in Statusline

### Current State
- Hotkeys are not visible in the statusline

### Proposed Enhancements
1. **Contextual hotkey display**
   - Show relevant hotkeys in statusline based on current mode/context
   - Display most frequently used shortcuts

2. **Dynamic updates**
   - Update displayed hotkeys based on file type or buffer state
   - Show available actions for current context

### Implementation Considerations
- Avoid cluttering statusline with too many hotkeys
- Prioritize most useful shortcuts
- Consider space constraints in statusline

### Priority
Low - Discoverability enhancement

---

## Task 7: Change Hint Highlight Colour

### Current State
- Hint highlighting uses fixed colors

### Proposed Enhancements
1. **Configurable highlight colors**
   - Allow users to customize hint highlight colors
   - Support different colors for different hint types

2. **Theme-aware defaults**
   - Automatically select appropriate colors based on colorscheme
   - Ensure sufficient contrast for readability

### Implementation Considerations
- Add configuration options for highlight groups
- Test with light and dark themes
- Document color customization

### Priority
Medium - User preference and accessibility

---

## Task 8: Only Show Hint Virtual Text When Cursor on Same Line + Config

### Current State
- Hint virtual text may display regardless of cursor position

### Proposed Enhancements
1. **Cursor-aware hint display**
   - Only show virtual text hints when cursor is on the same line
   - Reduce visual clutter when cursor is elsewhere

2. **Configuration option**
   - Add setting to enable/disable this behavior
   - Allow users to choose between always-on or cursor-aware display

3. **Performance benefit**
   - Fewer virtual text updates when cursor moves between lines
   - Improved responsiveness in large files

### Implementation Considerations
- Hook into cursor movement events
- Update virtual text visibility efficiently
- Document configuration option

### Priority
Medium - Improves visual clarity and performance

---

## Task 9: Code Tag Highlighting/Hinting

### Current State
- Code tags may not be visually distinguished or hinted

### Proposed Enhancements
1. **Tag recognition**
   - Identify and highlight code tags (e.g., TODO, FIXME, NOTE, HACK)
   - Support custom tag definitions

2. **Visual highlighting**
   - Apply distinct colors/styles to different tag types
   - Show tag indicators in sign column

3. **Hint integration**
   - Display tag hints with descriptions
   - Navigate between tags with commands

### Implementation Considerations
- Parse common code tags from comments
- Allow user-defined tags
- Integrate with existing hint system

### Priority
Medium - Useful for code organization and navigation

---

## Task 10: Inline Terminal

### Current State
- No built-in terminal integration

### Proposed Enhancements
1. **Floating terminal window**
   - Open terminal in floating pane within editor
   - Quick access to shell commands without leaving editor

2. **Integration with plugin**
   - Run compiler commands in inline terminal
   - Display output without disrupting editor view

3. **Toggle functionality**
   - Easy open/close of terminal pane
   - Preserve terminal state between toggles

### Implementation Considerations
- Use Neovim's terminal capabilities
- Handle terminal sizing and positioning
- Consider performance impact

### Priority
Low - Nice-to-have convenience feature

---

## Task 11: Code Actions Implementation for Warnings (e.g., Unused Variables → Auto Remove Lines)

### Current State
- Warnings are displayed but no automated fixes available

### Proposed Enhancements
1. **Quick fix actions**
   - Implement code actions for common warnings
   - Example: Remove unused variable declarations
   - Example: Remove unused imports

2. **Action execution**
   - Provide keybinding to apply code action at cursor
   - Show available actions in menu

3. **Extensible framework**
   - Design system to easily add new code actions
   - Support custom actions via configuration

### Implementation Considerations
- Parse warning types from compiler output
- Implement safe code transformations
- Test thoroughly to avoid unintended deletions
- Provide undo capability

### Priority
High - Significant productivity improvement

---

## Task 12: Formatting Action

### Current State
- No built-in code formatting integration

### Proposed Enhancements
1. **Format command**
   - Implement code formatting for Genero files
   - Support formatting entire file or selection

2. **Integration with external formatters**
   - Support configurable formatter tools
   - Handle formatter output and error cases

3. **Keybinding**
   - Provide convenient keybinding for formatting
   - Show formatting status/progress

### Implementation Considerations
- Determine appropriate formatter for Genero code
- Handle formatter configuration
- Preserve cursor position after formatting
- Consider performance for large files

### Priority
Medium - Quality of life improvement for code consistency


---

## Task 13: Undo from Previous Editing Sessions

### Current State
- Undo history is limited to current session
- Closing and reopening files loses undo/redo history

### Proposed Enhancements
1. **Persistent undo history**
   - Store undo tree across editing sessions
   - Restore undo history when reopening files
   - Allow undoing changes from previous sessions

2. **Undo tree visualization**
   - Display undo history timeline
   - Navigate between different undo branches
   - Show timestamps for historical changes

3. **Configuration options**
   - Control undo history retention period
   - Set storage location for undo files
   - Enable/disable persistent undo per file type

### Implementation Considerations
- This may be achievable through existing Neovim plugins (e.g., `undotree`, `persisted.nvim`)
- Could be a configuration change to enable Neovim's built-in `undofile` feature
- Alternatively, implement custom undo persistence in plugin
- Handle storage efficiently to avoid excessive disk usage
- Consider privacy/security implications of storing edit history

### Related Plugins/Features
- Neovim's built-in `undofile` option
- `vim-undotree` plugin
- `persisted.nvim` for session management

### Priority
Medium - Useful for recovery and workflow continuity, but may already be available through existing solutions

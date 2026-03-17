# Keybinding Help Popup Feature Specification

## Overview

The Keybinding Help Popup feature provides an obvious, discoverable way for new users to learn about available hotkeys in the genero-tools plugin. A configurable floating popup window displays all available keybindings organized by category with descriptions.

## Problem Statement

- New users may not know what hotkeys are available
- Keybindings are scattered across documentation
- No in-editor reminder of available commands
- Users must search documentation to discover features
- Reduces plugin discoverability and adoption

## Solution

Implement a help popup that:
1. Shows all available keybindings with descriptions
2. Organizes keybindings by category
3. Appears on buffer enter (configurable)
4. Can be toggled with a keybinding
5. Supports search and navigation
6. Is fully customizable

## User Workflow

### Basic Usage
1. User opens a Genero file in Neovim
2. Help popup appears automatically (configurable)
3. User sees all available keybindings organized by category
4. User presses `q` or `Esc` to close popup
5. User can press `<leader>gh` to show help again

### Advanced Usage
- User searches for specific keybinding with `/`
- User scrolls through categories with `j`/`k`
- User customizes which categories to show
- User exports keybindings to file
- User integrates with which-key plugin

## Architecture

### Module Structure
```
autoload/genero_tools/help.vim              # Main module entry point
autoload/genero_tools/help/
├── popup.vim                               # Popup window management
├── keybindings.vim                         # Keybinding data and formatting
└── search.vim                              # Search functionality
```

### Key Components

#### 1. Configuration (`autoload/genero_tools/config.vim`)
New configuration options:
- `help_popup_enabled`: Enable/disable feature (default: true)
- `help_popup_show_on_buffer_enter`: Auto-show on buffer enter (default: true)
- `help_popup_show_on_startup`: Show on plugin startup (default: false)
- `help_popup_width`: Window width as percentage (default: 50%)
- `help_popup_height`: Window height as percentage (default: 60%)
- `help_popup_position`: 'center', 'top', 'bottom' (default: 'center')
- `help_popup_border`: 'rounded', 'solid', 'shadow' (default: 'rounded')
- `help_popup_auto_close_delay`: Auto-close delay in ms (default: 0 = manual)
- `help_popup_show_categories`: Show category headers (default: true)
- `help_popup_show_on_first_use`: Show only on first use (default: false)

#### 2. Keybinding Data (`autoload/genero_tools/help/keybindings.vim`)
Responsibilities:
- Store all keybindings with descriptions
- Organize by category
- Support custom keybinding overrides
- Format for display

Key Functions:
- `genero_tools#help#keybindings#get_all()` - Get all keybindings
- `genero_tools#help#keybindings#get_by_category(category)` - Get by category
- `genero_tools#help#keybindings#format()` - Format for display
- `genero_tools#help#keybindings#get_categories()` - Get all categories

Keybinding Categories:
- **Code Navigation**: GeneroLookup, GeneroListFunctions, GeneroListModuleFiles, GeneroFunctionSignature, GeneroFileMetadata
- **Compilation**: GeneroCompile, GeneroNextError, GeneroPrevError, GeneroClearErrors, GeneroAutocompileEnable, GeneroAutocompileDisable
- **Debug**: GeneroDebugStreamOpen, GeneroDebugStreamClose, GeneroDebugStreamSelect, GeneroDebugStreamClear
- **Cache**: GeneroClearCache
- **Configuration**: GeneroConfigShow
- **Help**: GeneroHelp, GeneroHelpToggle

#### 3. Popup Window (`autoload/genero_tools/help/popup.vim`)
Responsibilities:
- Create floating window
- Manage window lifecycle
- Handle keybindings within popup
- Support scrolling and search

Key Functions:
- `genero_tools#help#popup#open()` - Open help popup
- `genero_tools#help#popup#close()` - Close popup
- `genero_tools#help#popup#is_open()` - Check if open
- `genero_tools#help#popup#scroll(direction)` - Scroll content
- `genero_tools#help#popup#search(query)` - Search within popup

#### 4. Search Functionality (`autoload/genero_tools/help/search.vim`)
Responsibilities:
- Search keybindings by name, command, or description
- Highlight search results
- Support case-insensitive search

Key Functions:
- `genero_tools#help#search#find(query)` - Search keybindings
- `genero_tools#help#search#highlight_results(results)` - Highlight matches

#### 5. Main Module (`autoload/genero_tools/help.vim`)
Responsibilities:
- Coordinate all components
- Manage commands and keybindings
- Handle auto-show logic
- Track user preferences

Key Functions:
- `genero_tools#help#show()` - Show help popup
- `genero_tools#help#toggle()` - Toggle popup
- `genero_tools#help#close()` - Close popup
- `genero_tools#help#on_buffer_enter()` - Handle BufEnter event

## Implementation Details

### Popup Window Creation
- Use `nvim_open_win()` for Neovim floating window
- Set window options:
  - `relative='editor'` - Position relative to editor
  - `width=50%` - Default 50% of editor width
  - `height=60%` - Default 60% of editor height
  - `row=center` - Center vertically
  - `col=center` - Center horizontally
- Set buffer options:
  - `buftype=nofile` - Not a real file
  - `bufhidden=hide` - Hide when not displayed
  - `noswapfile` - No swap file
  - `nomodifiable` - Read-only display

### Keybinding Data Structure
```vim
let keybindings = {
  \ 'Code Navigation': [
    \ {'key': '<leader>gl', 'command': 'GeneroLookup', 'desc': 'Lookup function definition'},
    \ {'key': '<leader>gf', 'command': 'GeneroListFunctions', 'desc': 'List functions in file'},
    \ ...
  \ ],
  \ 'Compilation': [
    \ {'key': '<leader>gc', 'command': 'GeneroCompile', 'desc': 'Compile current file'},
    \ ...
  \ ],
  \ ...
  \ }
```

### Display Format
```
╭─ Genero-Tools Keybindings ─────────────────────────────────────╮
│                                                                 │
│ Code Navigation                                                 │
│   <leader>gl  GeneroLookup              Lookup function         │
│   <leader>gf  GeneroListFunctions       List functions in file  │
│   <leader>gs  GeneroFunctionSignature   Show function signature │
│                                                                 │
│ Compilation                                                     │
│   <leader>gc  GeneroCompile             Compile current file    │
│   <leader>gn  GeneroNextError           Jump to next error      │
│   <leader>gp  GeneroPrevError           Jump to previous error  │
│                                                                 │
│ Debug                                                           │
│   <leader>gd  GeneroDebugStreamOpen     Open debug stream       │
│   <leader>gds GeneroDebugStreamSelect   Select debug file       │
│                                                                 │
│ Help                                                            │
│   <leader>gh  GeneroHelp                Show this help          │
│                                                                 │
│ Press q/Esc to close, j/k to scroll, / to search               │
╰─────────────────────────────────────────────────────────────────╯
```

### Popup Controls
- `q` or `Esc` - Close popup
- `j` or `Down` - Scroll down
- `k` or `Up` - Scroll up
- `g` - Go to top
- `G` - Go to bottom
- `/` - Search within popup
- `n` - Next search result
- `N` - Previous search result
- Mouse click - Close popup

### Auto-Show Logic
- Check `help_popup_show_on_buffer_enter` on BufEnter
- Check `help_popup_show_on_startup` on plugin load
- Track if popup has been shown (don't spam)
- Support "don't show again" option
- Respect user dismissal

### Search Implementation
- Case-insensitive search by default
- Search in keybinding, command name, and description
- Highlight matching text in popup
- Support regex patterns (optional)
- Show match count

## Commands

### User-Facing Commands
- `:GeneroHelp` - Show help popup
- `:GeneroHelpToggle` - Toggle help popup
- `:GeneroHelpClose` - Close help popup
- `:GeneroHelpExport` - Export keybindings to file

### Default Keybindings
- `<leader>gh` - Show help popup (configurable)

## Configuration Examples

### Basic Setup
```vim
let g:genero_tools_config = {
  \ 'help_popup_enabled': v:true,
  \ 'help_popup_show_on_buffer_enter': v:true
  \ }
```

### Advanced Setup
```vim
let g:genero_tools_config = {
  \ 'help_popup_enabled': v:true,
  \ 'help_popup_show_on_buffer_enter': v:true,
  \ 'help_popup_show_on_startup': v:false,
  \ 'help_popup_width': 60,
  \ 'help_popup_height': 70,
  \ 'help_popup_position': 'center',
  \ 'help_popup_border': 'rounded',
  \ 'help_popup_auto_close_delay': 0,
  \ 'help_popup_show_categories': v:true,
  \ 'help_popup_show_on_first_use': v:true
  \ }
```

### Disable Auto-Show
```vim
let g:genero_tools_config = {
  \ 'help_popup_show_on_buffer_enter': v:false,
  \ 'help_popup_show_on_startup': v:false
  \ }
```

## Testing Strategy

### Unit Tests
- Test keybinding data structure
- Test formatting logic
- Test search functionality
- Test popup window creation
- Test configuration options

### Integration Tests
- Test full workflow: open → search → close
- Test auto-show on buffer enter
- Test auto-show on startup
- Test keybindings within popup
- Test with various window sizes
- Test with many keybindings

### UI Tests
- Test popup appearance
- Test scrolling
- Test search highlighting
- Test border styles
- Test positioning

## Backward Compatibility

- Feature is enabled by default but can be disabled
- No impact on existing functionality
- Graceful fallback if not in Neovim
- No breaking changes to existing API

## Neovim Requirements

- Requires Neovim 0.5+ for floating windows
- Uses `nvim_open_win()` for window creation
- Uses `nvim_buf_set_lines()` for content
- Uses `nvim_buf_set_keymap()` for keybindings
- Falls back gracefully if not in Neovim

## Future Enhancements

1. **Customizable Categories** - Allow users to define custom categories
2. **Keybinding Customization** - Show user's custom keybindings
3. **Integration with which-key** - Sync with which-key plugin
4. **Video Tutorials** - Link to video tutorials for features
5. **Interactive Demo** - Run demo commands from help
6. **Keybinding Conflicts** - Detect and warn about conflicts
7. **Export to Markdown** - Export keybindings to markdown file
8. **Cheat Sheet** - Generate printable cheat sheet

## Related Features

- Keybindings (Task 13) - Provides keybinding infrastructure
- which-key Integration (Task 25) - Complements keybinding discovery
- Configuration System (Task 2) - Provides configuration framework
- Display Modes (Task 5) - Provides window management patterns

## Success Criteria

- ✓ Popup opens with correct dimensions
- ✓ Keybindings displayed correctly
- ✓ Organized by category
- ✓ Popup closes on keybinding
- ✓ Scrolling works
- ✓ Search functionality works
- ✓ Auto-show on buffer enter works
- ✓ Auto-close delay works
- ✓ Works with various window sizes
- ✓ Handles many keybindings
- ✓ Neovim-only features work
- ✓ Graceful fallback in Vim

---

**Priority:** MEDIUM
**Complexity:** MEDIUM
**Estimated Effort:** 3-4 hours
**Dependencies:** Tasks 1-2, 13 (core infrastructure)
**Neovim Only:** Yes (uses floating windows)
**Status:** Specification Complete - Ready for Implementation

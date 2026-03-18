# Vim Genero-Tools Plugin

A vim plugin that brings modern IDE capabilities to the classic vim editor for Genero development. Provides code navigation, intelligent autocomplete, and compiler integration for large-scale Genero codebases (thousands of files, 6M+ LOC).

**Compatibility:** Vi, Vim 7+, Vim 8+, and Neovim 0.4+. Advanced features (plugins, floating windows, snippets) require Vim 8+ or Neovim.

## Quick Start

```vim
:GeneroLookup myFunction
<leader>gl  " Lookup function under cursor
<leader>gf  " List functions in current file
<leader>gs  " Get function signature
<leader>gm  " Get file metadata
F5          " Compile current file
```

## Installation

Using vim-plug (Vim 8+ and Neovim only):
```vim
Plug 'hdean-ssp/genero-vim'
```

**Quick Setup:** Copy the provided `.vimrc.example` to get started immediately:
```bash
cp .vimrc.example ~/.vimrc
```

This includes:
- Minimal, essential settings (no conflicts or unnecessary options)
- vim-plug setup (Vim 8+ and Neovim)
- genero-tools configuration with sensible defaults
- Keybindings for common operations
- Neovim enhancements (lualine, which-key, tokyonight theme)
- Compatibility checks for Vi, Vim 7+, Vim 8+, and Neovim

See [Setup Guide](docs/SETUP_FRESH_VIM.md) for complete installation instructions.

## Features

- **Code Navigation** - Function lookup, module exploration, and file metadata retrieval
- **Intelligent Autocomplete** - Function and module name completion with signatures
- **Compiler Integration** - Real-time error/warning parsing with quickfix navigation
  - Sign column indicators for errors and warnings
  - Unified sign column for compiler and SVN markers (space-efficient)
  - Syntax error highlighting (errors highlighted with red background, warnings with yellow)
  - Unused variable detection and highlighting
  - Automatic highlighting applied on compilation
- **Code Snippets** (Neovim only) - Intelligent snippet expansion with smart parameter population
  - Requires LuaSnip plugin
  - Automatic function parameter population from genero-tools API
  - Placeholder navigation with Tab/Shift+Tab
- **Large Codebase Support** - Optimized for massive codebases with caching and pagination
- **Omnifunc autocomplete** - Function and module name completion with signatures
- **Neovim Lua Layer** (optional) - Enhanced features for Neovim users
  - Async operations with non-blocking execution
  - Floating windows for rich UI
- **Vi/Vim 7+ Compatible** - Works with Vi, Vim 7+, Vim 8+, and Neovim
- **Advanced Features** (Vim 8+ and Neovim) - Plugin manager, snippets, modern UI
- Zero configuration changes required between editors

## Keybindings

The default leader key is space `<space>` (configured in `.vimrc.example`). All keybindings work in normal mode.

**Note:** Advanced keybindings (window navigation, buffer management) require Vim 7+. Vi and Vim 6 users can use basic commands directly (`:GeneroCompile`, `:GeneroNextError`, etc.).

### Default Keybindings (from `.vimrc.example`, Vim 7+ and Neovim)

| Keybinding | Action |
|-----------|--------|
| `F5` | Compile current file |
| `Ctrl+,` | Jump to previous error |
| `Ctrl+.` | Jump to next error |
| `<space>ca` | Enable autocompile |
| `<space>cd` | Disable autocompile |
| `<space>cc` | Clear error markers |
| `<space>sl` | List snippets |
| `<space>sh` | Show snippet help |
| `<space>bn` | Next buffer (Vim 7+) |
| `<space>bp` | Previous buffer (Vim 7+) |
| `<space>bd` | Delete buffer (Vim 7+) |
| `Ctrl+h/j/k/l` | Navigate between windows (Vim 7+) |
| `gcc` | Toggle comment on line (Neovim only) |
| `gbc` | Toggle block comment (Neovim only) |

**Note:** Resize window keybindings (`Ctrl+Up/Down/Left/Right`) have been removed from the default config as they interfere with arrow key detection in Vim 8.0. Use `:resize +2` or `:vertical resize -2` commands manually, or add custom keybindings if needed.

### SVN Commands

| Command | Action |
|---------|--------|
| `:GeneroSVNRefresh` | Manually refresh SVN diff markers for current file |
| `:GeneroSVNToggle` | Toggle SVN diff markers on/off for current buffer |
| `:GeneroSVNStatus` | Show SVN status and change summary for current file |

### Sign Column Commands

| Command | Action |
|---------|--------|
| `:GeneroUnifiedSignsEnable` | Enable unified sign column (compiler + SVN markers) |
| `:GeneroUnifiedSignsDisable` | Disable unified sign column |
| `:GeneroUnifiedSignsToggle` | Toggle unified sign column on/off |
| `:GeneroUnifiedSignsStatus` | Show unified signs status and configuration |

### Customizing Keybindings

The `.vimrc.example` uses space as the leader key. To customize:

```vim
" Change leader key
let mapleader = ','  " Use comma instead of space

" Or map to different keys
nnoremap <F6> :GeneroCompile<CR>
nnoremap <C-l> :GeneroLookup <C-R><C-W><CR>
```

To disable default keybindings:

```vim
let g:genero_tools_config.keybindings_enabled = 0
```

## Commands

### Code Navigation Commands

```vim
:GeneroLookup [function_name]           " Find function definition
:GeneroListFunctions [file_path]        " List functions in file
:GeneroListModuleFiles [module_name]    " List files in module
:GeneroFunctionSignature [function_name] " Get function signature
:GeneroFileMetadata [file_path]         " Get file metadata
:GeneroConfigShow                       " Display current config
:GeneroClearCache                       " Clear result cache
:GeneroHelp                             " Show keybindings and commands (from .vimrc.example)
```

### Compiler Commands

```vim
:GeneroCompile [file_path]              " Compile file or entire project
:GeneroClearErrors                      " Clear error markers and quickfix
:GeneroNextError                        " Jump to next error in quickfix
:GeneroPrevError                        " Jump to previous error in quickfix
:GeneroAutocompileEnable                " Enable autocompile on save
:GeneroAutocompileDisable               " Disable autocompile on save
:GeneroAutocompileStatus                " Show autocompile status
```

**Note:** Error navigation commands (`:GeneroNextError`, `:GeneroPrevError`) gracefully handle empty error lists and won't display spurious error messages.

### Sign Column Commands

```vim
:GeneroUnifiedSignsEnable               " Enable unified sign column (compiler + SVN)
:GeneroUnifiedSignsDisable              " Disable unified sign column
:GeneroUnifiedSignsToggle               " Toggle unified sign column on/off
:GeneroUnifiedSignsStatus               " Show unified signs status
```

**Note:** The unified sign column combines compiler error/warning signs with SVN diff markers in a single column for space efficiency.

### Snippet Commands (Neovim only)

```vim
:GeneroSnippetList                      " List all available snippets
:GeneroSnippetHelp [trigger]            " Show help for a snippet
:GeneroSnippet [trigger]                " Expand a snippet by trigger
```

**Note**: Snippet commands are only available in Neovim with LuaSnip installed. See [Snippets Documentation](docs/SNIPPETS.md) for details.

## Display Modes

Change how results are displayed by setting `display_mode`:

```vim
let g:genero_tools_config.display_mode = 'quickfix'  " Quickfix list (default)
let g:genero_tools_config.display_mode = 'inline'    " Popup in command line
let g:genero_tools_config.display_mode = 'split'     " New split window
let g:genero_tools_config.display_mode = 'echo'      " Command line output
let g:genero_tools_config.display_mode = 'popup'     " Large floating window (Neovim only)
```

## Autocomplete

The plugin provides intelligent autocomplete for function and module names. Autocomplete is automatically enabled for `.4gl` files.

**Usage:**
```
1. Open a .4gl file
2. Start typing a function or module name
3. Press Tab to trigger autocomplete
4. Use Tab/Shift+Tab or Up/Down arrows to navigate
5. Press Enter to select
6. Press Esc to cancel
```

**Tab Behavior (Smart):**
- **Completion menu visible** - Navigate down in menu
- **Empty line or only whitespace** - Insert tab character (for indentation)
- **Otherwise** - Trigger autocomplete

**Keybindings in Autocomplete Menu:**
- `Tab` - Next item (or trigger if menu closed)
- `Shift+Tab` - Previous item
- `Up/Down` - Navigate menu
- `Enter` - Accept selection
- `Esc` - Cancel and close menu

**Manual Control:**
```vim
:GeneroCompleteEnable   " Enable autocomplete for current buffer
:GeneroCompleteDisable  " Disable autocomplete for current buffer
```

**Completion Features:**
- Function name completion with signatures
- Module name completion
- Cached results for performance
- Works with partial matches (e.g., typing "val" completes "validate_input")
- Robust error handling - completion errors are silently handled and don't interrupt editing

## Setup

Before using the plugin, ensure genero-tools is installed and configured:

```bash
# Generate genero-tools databases
bash generate_signatures.sh /path/to/codebase
bash generate_modules.sh /path/to/codebase
query.sh create-dbs
```

Then copy the example configuration:

```bash
cp .vimrc.example ~/.vimrc
```

Start Vim and plugins will install automatically. See [Setup Guide](docs/SETUP_FRESH_VIM.md) for details.

## Configuration

The plugin works out-of-the-box with sensible defaults. Optionally customize:

```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': 'query.sh',
  \ 'cache_enabled': 1,
  \ 'cache_ttl': 3600,
  \ 'cache_max_size': 100,
  \ 'display_mode': 'quickfix',
  \ 'keybindings_enabled': 1,
  \ 'timeout': 10000,
  \ 'async_enabled': 1,
  \ 'result_limit': 1000,
  \ 'pagination_size': 50,
  \ 'codebase_markers': ['castle.sch', 'genero.conf', '.genero', '.git'],
  \ 'compiler_enabled': 0,
  \ 'compiler_command': 'fglcomp -M -W all',
  \ 'compiler_version': 'auto',
  \ 'compiler_source_dir': '.',
  \ 'compiler_show_warnings': 1,
  \ 'compiler_show_errors': 1,
  \ 'compiler_highlight_unused': 1,
  \ 'compiler_sign_column': 1,
  \ 'compiler_autocompile': 0,
  \ 'compiler_autocompile_delay': 1000,
  \ 'snippets_enabled': 1,
  \ 'snippet_engine': 'luasnip',
  \ 'snippet_smart_expansion': 1,
  \ 'snippet_custom_dir': expand('~/.config/nvim/genero-snippets'),
  \ 'startup_messages': 'silent',
  \ 'svn_enabled': 1,
  \ 'svn_show_added': 1,
  \ 'svn_show_modified': 1,
  \ 'svn_show_deleted': 1,
  \ 'svn_cache_ttl': 300,
  \ 'svn_auto_update': 1,
  \ }
```

### Codebase Detection

The `codebase_markers` option identifies project root directories. The plugin searches for these markers to determine the codebase root:

```vim
let g:genero_tools_config.codebase_markers = ['castle.sch', 'genero.conf', '.genero', '.git']
```

**Flexible Configuration:**
- Accepts a list of marker filenames (default)
- Also accepts a single string, which is automatically converted to a list
- Useful for single-marker projects: `let g:genero_tools_config.codebase_markers = 'castle.sch'`

**Common Markers:**
- `castle.sch` - Genero project schema file
- `genero.conf` - Genero configuration file
- `.genero` - Genero project directory marker
- `.git` - Git repository root

### Compiler Configuration

```vim
let g:genero_tools_config.compiler_enabled = 1                   " Enable compiler integration
let g:genero_tools_config.compiler_command = 'fglcomp -M -W all' " Compiler command with flags
let g:genero_tools_config.compiler_version = 'auto'              " Version: 'auto', '3.10', '3.20', etc.
let g:genero_tools_config.compiler_source_dir = '.'              " Source directory for compilation
let g:genero_tools_config.compiler_show_warnings = 1             " Display warnings in quickfix
let g:genero_tools_config.compiler_show_errors = 1               " Display errors in quickfix
let g:genero_tools_config.compiler_highlight_unused = 1          " Highlight unused variables
let g:genero_tools_config.compiler_sign_column = 1               " Show signs in sign column
let g:genero_tools_config.compiler_autocompile = 1               " Autocompile on file save
let g:genero_tools_config.compiler_autocompile_delay = 1000      " Delay before autocompile (ms)
```

**Compiler Command Flags:**
- `-M` - Generate machine code (required for compilation)
- `-W all` - Enable all warnings (recommended for code quality)

**Compiler Features:**
- Real-time error/warning parsing with quickfix integration
- Sign column indicators (✕ for errors, ⚠ for warnings)
- Syntax error highlighting (red background for errors, yellow for warnings)
- Unused variable detection and highlighting
- Version-specific output parsing (auto-detects compiler version)
- Quickfix navigation with `:GeneroNextError` and `:GeneroPrevError`
- **Autocompile on save** - Automatically compile and update markers when file is saved (enabled by default)
- **Automatic highlighting** - Error/warning highlighting applied automatically on compilation

### Snippet Configuration (Neovim only)

For Neovim users with LuaSnip installed, configure code snippets:

```vim
let g:genero_tools_config.snippets_enabled = 1                   " Enable/disable snippets
let g:genero_tools_config.snippet_engine = 'luasnip'             " Snippet engine (luasnip, vim-snipmate, vim-vsnip)
let g:genero_tools_config.snippet_smart_expansion = 1            " Enable async parameter population
let g:genero_tools_config.snippet_custom_dir = expand('~/.config/nvim/genero-snippets') " Custom snippet directory
```

### Startup Configuration

Control plugin startup behavior:

```vim
let g:genero_tools_config.startup_messages = 'silent'            " Startup messages: 'silent', 'normal', 'verbose' (default: 'silent')
```

### Configuration Type Handling

The plugin automatically handles type conversions for flexibility:

- **`codebase_markers`** - Accepts both list and string formats
  - List format (recommended): `['castle.sch', 'genero.conf', '.git']`
  - String format (auto-converted): `'castle.sch'` → `['castle.sch']`
  - Useful for single-marker projects or simple configurations

**Startup Message Modes:**
- `'silent'` - No startup messages (default, clean startup)
- `'normal'` - Standard startup messages
- `'verbose'` - Detailed startup messages for debugging

### SVN Diff Markers Configuration

Configure SVN diff marker display in the sign column:

```vim
let g:genero_tools_config.svn_enabled = 1                        " Enable/disable SVN diff markers
let g:genero_tools_config.svn_show_added = 1                     " Show added lines (+ sign)
let g:genero_tools_config.svn_show_modified = 1                  " Show modified lines (~ sign)
let g:genero_tools_config.svn_show_deleted = 1                   " Show deleted lines (- sign)
let g:genero_tools_config.svn_cache_ttl = 300                    " Cache TTL in seconds (default: 300)
let g:genero_tools_config.svn_auto_update = 1                    " Auto-update markers on file save
```

**SVN Features:**
- Visual indicators in sign column for added, modified, and deleted lines
- Automatic detection of SVN working copies
- Cached diff results for performance
- Graceful handling of binary files and authentication errors
- See [SVN Diff Markers Documentation](docs/SVN_DIFF_MARKERS.md) for complete details

**Snippet Features:**
- Intelligent code templates for common Genero patterns
- Smart parameter population from function signatures (Neovim only)
- Placeholder navigation with Tab/Shift+Tab
- Custom snippet support with hot-reload
- See [Snippets Documentation](docs/SNIPPETS.md) for complete details

### Neovim Lua Layer (Optional)

For Neovim users, enable the optional Lua layer for enhanced features:

```vim
let g:genero_tools_config.lua_enabled = 1                        " Enable Lua layer (Neovim only)
let g:genero_tools_config.async_enabled = 1                      " Use async operations
let g:genero_tools_config.display_mode = 'floating'              " Use floating windows
```

**Lua Layer Features** (Neovim 0.5+ only):
- **Async Operations** - Non-blocking command execution with progress indicators
- **Floating Windows** - Rich UI for results with better formatting
- **Better Performance** - Optimized for large codebases
- **UI Components** - Notifications, progress bars, popup menus

The Lua layer is optional and gracefully falls back to VimScript implementations if unavailable. All core functionality works in both Vim and Neovim without the Lua layer.

### Error Handling and Large Codebase Guidance

When commands timeout or return too many results, the plugin provides actionable guidance:

**Timeout Errors** suggest:
- Using more specific search terms (e.g., `"myFunc"` instead of `"func"`)
- Filtering by module name (e.g., `"mymodule.m3:myFunc"`)
- Filtering by file path (e.g., `"src/myfile.4gl:myFunc"`)
- Increasing timeout for very large codebases (6M+ LOC)
- Enabling async mode to prevent blocking

**Result Size Errors** suggest:
- Using more specific search terms
- Filtering by module or file
- Increasing `result_limit` configuration
- Using pagination to view results in smaller chunks

### Codebase Detection

The plugin automatically detects your project root by searching for markers (by default: `castle.sch`, `genero.conf`, `.genero`, `.git`). Customize the markers for your project:

```vim
let g:genero_tools_config.codebase_markers = ['custom.marker', '.git']
```

For large codebases (6M+ LOC), see [Setup Guide](docs/SETUP_FRESH_VIM.md) for optimized configuration.

## Documentation

- **[Setup Guide](docs/SETUP_FRESH_VIM.md)** - Fresh Vim installation guide
- **[Quick Start](docs/QUICK_START.md)** - User guide with examples
- **[Neovim Setup](docs/NEOVIM.md)** - Neovim installation and configuration
- **[API Integration](docs/API_INTEGRATION.md)** - Complete API reference
- **[Compatibility](docs/COMPATIBILITY.md)** - Vim/Neovim compatibility
- **[Unified Sign Column](docs/UNIFIED_SIGN_COLUMN.md)** - Sign column system for compiler and SVN markers
- **[SVN Diff Markers](docs/SVN_DIFF_MARKERS.md)** - SVN integration and diff markers
- **[Snippets](docs/SNIPPETS.md)** - Code snippets documentation

## Requirements

- Vi, Vim 7+, Vim 8+, or Neovim 0.4+
- genero-tools CLI installed and in PATH

**Note:** Advanced features require Vim 8+ or Neovim:
- Plugin manager (vim-plug) - Vim 8+ and Neovim only
- Code snippets - Vim 8.2+ and Neovim only
- Floating windows - Neovim only
- Modern UI enhancements - Neovim only

Basic functionality (code navigation, compiler integration) works in Vi and Vim 7+.

## License

MIT

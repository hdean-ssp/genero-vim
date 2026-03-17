# Vim Genero-Tools Plugin

A vim plugin that brings modern IDE capabilities to the classic vim editor for Genero development. Provides code navigation, intelligent autocomplete, and compiler integration for large-scale Genero codebases (thousands of files, 6M+ LOC).

## Quick Start

```vim
:GeneroLookup myFunction
<leader>gl  " Lookup function under cursor
<leader>gf  " List functions in current file
<leader>gs  " Get function signature
<leader>gm  " Get file metadata
```

## Installation

Using vim-plug:
```vim
Plug 'hdean-ssp/genero-vim'
```

See [Setup Guide](docs/SETUP_FRESH_VIM.md) for complete installation instructions.

## Features

- **Code Navigation** - Function lookup, module exploration, and file metadata retrieval
- **Intelligent Autocomplete** - Function and module name completion with signatures
- **Compiler Integration** - Real-time error/warning parsing with quickfix navigation
  - Sign column indicators for errors and warnings
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
- Full Vim 8.0+ and Neovim 0.4+ compatibility
- Zero configuration changes required between editors

## Keybindings

The default leader key is backslash `\`. All keybindings work in normal mode.

### Default Keybindings

| Keybinding | Action | Example |
|-----------|--------|---------|
| `<leader>gl` | Find function under cursor | Place cursor on `validate_input`, press `<space>gl` |
| `<leader>gf` | List functions in current file | Press `<space>gf` to see all functions |
| `<leader>gs` | Get function signature under cursor | Place cursor on `process_data`, press `<space>gs` |
| `<leader>gm` | Get metadata for current file | Press `<space>gm` to see author, tickets, dates |

### SVN Commands

| Command | Action |
|---------|--------|
| `:GeneroSVNRefresh` | Manually refresh SVN diff markers for current file |
| `:GeneroSVNToggle` | Toggle SVN diff markers on/off for current buffer |
| `:GeneroSVNStatus` | Show SVN status and change summary for current file |

### Usage Examples

**Example 1: Lookup a function definition**
```
1. Open a .4gl file
2. Place cursor on a function name: validate_input
3. Press <space>gl
4. Results appear in inline popup (or quickfix, depending on display_mode)
```

**Example 2: Get function signature**
```
1. Open a .4gl file
2. Place cursor on a function name: calculate_total
3. Press <space>gs
4. Function signature appears (parameters, return types)
```

**Example 3: List all functions in current file**
```
1. Open a .4gl file
2. Press <space>gf
3. All functions in the file are listed with line numbers
```

**Example 4: Get file metadata**
```
1. Open a .4gl file
2. Press <space>gm
3. File metadata appears (author, ticket codes, created/modified dates)
```

### Customizing Keybindings

To use different keybindings, add to your `.vimrc`:

```vim
" Use space as leader instead of backslash
let mapleader = " "

" Now keybindings are: <space>gl, <space>gf, etc.
```

Or map to completely different keys:

```vim
nnoremap <silent> <C-l> :GeneroLookup <C-R><C-W><CR>
nnoremap <silent> <C-f> :GeneroListFunctions %<CR>
nnoremap <silent> <C-s> :GeneroFunctionSignature <C-R><C-W><CR>
nnoremap <silent> <C-m> :GeneroFileMetadata %<CR>
```

To disable default keybindings:

```vim
let g:genero_tools_config.keybindings_enabled = v:false
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

## Setup

Before using the plugin, generate genero-tools databases:

```bash
bash generate_signatures.sh /path/to/codebase
bash generate_modules.sh /path/to/codebase
query.sh create-dbs
```

## Configuration

The plugin works out-of-the-box with sensible defaults. Optionally customize:

```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': 'query.sh',
  \ 'cache_enabled': v:true,
  \ 'cache_ttl': 3600,
  \ 'cache_max_size': 100,
  \ 'display_mode': 'quickfix',
  \ 'keybindings_enabled': v:true,
  \ 'timeout': 10000,
  \ 'async_enabled': v:true,
  \ 'result_limit': 1000,
  \ 'pagination_size': 50,
  \ 'codebase_markers': ['castle.sch', 'genero.conf', '.genero', '.git'],
  \ 'compiler_enabled': v:true,
  \ 'compiler_command': 'fglcomp -M -W all',
  \ 'compiler_version': 'auto',
  \ 'compiler_source_dir': '.',
  \ 'compiler_show_warnings': v:true,
  \ 'compiler_show_errors': v:true,
  \ 'compiler_highlight_unused': v:true,
  \ 'compiler_sign_column': v:true,
  \ 'compiler_autocompile': v:true,
  \ 'compiler_autocompile_delay': 1000,
  \ 'snippets_enabled': v:true,
  \ 'snippet_engine': 'luasnip',
  \ 'snippet_smart_expansion': v:true,
  \ 'snippet_custom_dir': expand('~/.config/nvim/genero-snippets'),
  \ 'startup_messages': 'silent',
  \ 'svn_enabled': v:true,
  \ 'svn_show_added': v:true,
  \ 'svn_show_modified': v:true,
  \ 'svn_show_deleted': v:true,
  \ 'svn_cache_ttl': 300,
  \ 'svn_auto_update': v:true,
  \ }
```

### Compiler Configuration

```vim
let g:genero_tools_config.compiler_enabled = v:true              " Enable compiler integration
let g:genero_tools_config.compiler_command = 'fglcomp -M -W all' " Compiler command with flags
let g:genero_tools_config.compiler_version = 'auto'              " Version: 'auto', '3.10', '3.20', etc.
let g:genero_tools_config.compiler_source_dir = '.'              " Source directory for compilation
let g:genero_tools_config.compiler_show_warnings = v:true        " Display warnings in quickfix
let g:genero_tools_config.compiler_show_errors = v:true          " Display errors in quickfix
let g:genero_tools_config.compiler_highlight_unused = v:true     " Highlight unused variables
let g:genero_tools_config.compiler_sign_column = v:true          " Show signs in sign column
let g:genero_tools_config.compiler_autocompile = v:true          " Autocompile on file save
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
let g:genero_tools_config.snippets_enabled = v:true              " Enable/disable snippets
let g:genero_tools_config.snippet_engine = 'luasnip'             " Snippet engine (luasnip, vim-snipmate, vim-vsnip)
let g:genero_tools_config.snippet_smart_expansion = v:true       " Enable async parameter population
let g:genero_tools_config.snippet_custom_dir = expand('~/.config/nvim/genero-snippets') " Custom snippet directory
```

### Startup Configuration

Control plugin startup behavior:

```vim
let g:genero_tools_config.startup_messages = 'silent'            " Startup messages: 'silent', 'normal', 'verbose' (default: 'silent')
```

**Startup Message Modes:**
- `'silent'` - No startup messages (default, clean startup)
- `'normal'` - Standard startup messages
- `'verbose'` - Detailed startup messages for debugging

### SVN Diff Markers Configuration

Configure SVN diff marker display in the sign column:

```vim
let g:genero_tools_config.svn_enabled = v:true                   " Enable/disable SVN diff markers
let g:genero_tools_config.svn_show_added = v:true                " Show added lines (+ sign)
let g:genero_tools_config.svn_show_modified = v:true             " Show modified lines (~ sign)
let g:genero_tools_config.svn_show_deleted = v:true              " Show deleted lines (- sign)
let g:genero_tools_config.svn_cache_ttl = 300                    " Cache TTL in seconds (default: 300)
let g:genero_tools_config.svn_auto_update = v:true               " Auto-update markers on file save
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
let g:genero_tools_config.lua_enabled = v:true                   " Enable Lua layer (Neovim only)
let g:genero_tools_config.async_enabled = v:true                 " Use async operations
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

## Requirements

- Vim 8.0+ or Neovim 0.4+
- genero-tools CLI installed and in PATH

## License

MIT

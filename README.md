# Vim Genero-Tools Plugin

A Vim plugin for Genero development with code navigation, intelligent autocomplete, and compiler integration. Optimized for large-scale codebases (thousands of files, 6M+ LOC).

**Compatibility:** Vim 7+, Vim 8+, Neovim 0.9.x–0.11.x

## Quick Start (2 Minutes)

**New user?** Start here:

1. **Install the plugin** (using vim-plug):
   ```vim
   Plug 'hdean-ssp/genero-vim'
   ```

2. **Copy example config**:
   ```bash
   # For Neovim (recommended for new users)
   mkdir -p ~/.config/nvim
   cp init.lua.example ~/.config/nvim/init.lua
   
   # For Vim
   cp .vimrc.example ~/.vimrc
   ```

3. **Start using it**:
   ```
   F5              Compile current file
   Ctrl+,          Previous error
   Ctrl+.          Next error
   Ctrl+N          Autocomplete (insert mode)
   gd              Go to definition
   gp              Peek definition
   gr              Find references (Telescope)
   <space>gF       File functions (Telescope)
   <space>gM       Module functions (Telescope)
   <space>gl       Lookup function
   ```

See [SETUP.md](SETUP.md) for detailed installation and first-time setup.

## Features

- **Code Navigation** - Function lookup, go to definition, peek definition, find references
- **Telescope Integration** - Pickers for file functions, module functions, module files, diagnostics, and references — all with file preview
- **Intelligent Autocomplete** - Module-scoped function completion with signatures, falls back to project-wide search
- **Compiler Integration** - Real-time error/warning parsing with quickfix and Telescope navigation
  - Support for `.4gl`, `.m3`, `.m4` files (fglcomp) and `.per` files (fglform)
  - Sign column indicators and syntax highlighting
  - Autocompile on save (configurable)
- **Statusline Breadcrumb** - Shows `module.m3  file.4gl  ƒ function  refs` with powerline arrows and scope-based coloring
- **Code Hints** - Real-time code quality warnings (fully configurable)
  - Whitespace, formatting, naming, and structure issues
  - Auto-fix suggestions for common issues
  - Display in sign column and/or virtual text (Neovim)
- **Keyword Highlighting** - TODO, BUG, FIX, HACK, WARN, NOTE, TMP tags highlighted in code and comments, plus user-specific temp tags (#TMP<initials> from $USER)
- **Code Snippets** (Neovim only) - Intelligent snippet expansion with smart parameter population
- **SVN Integration** - Visual diff markers for added/modified/deleted lines, auto-refresh on focus
- **Large Codebase Support** - Optimized for massive codebases with caching and pagination
- **Unified Sign Column** - Combines compiler and SVN markers in one column (space-efficient)
- **Neovim Enhancements** (optional) - Async operations, floating windows, modern UI
- **Neovim 0.9–0.11 Compatible** - Version-aware config handles API changes across Neovim versions
- **Zero Configuration** - Works out-of-the-box with sensible defaults

## Keybindings

The default leader key is space `<space>`. All keybindings work in normal mode unless noted.

| Keybinding | Action |
|-----------|--------|
| `F5` | Compile current file |
| `Ctrl+,` | Jump to previous error |
| `Ctrl+.` | Jump to next error |
| `Ctrl+N` | Trigger autocomplete (insert mode) |
| `gd` | Go to definition |
| `gp` | Peek definition (floating preview) |
| `gr` | Find references (Telescope picker) |
| `<space>ca` | Enable autocompile on save |
| `<space>cd` | Disable autocompile on save |
| `<space>cc` | Clear error markers |
| `<space>cD` | Compiler diagnostics (Telescope) |
| `<space>gl` | Lookup function definition |
| `<space>gf` | List functions in file |
| `<space>gs` | Get function signature |
| `<space>gm` | Get file metadata |
| `<space>gr` | Find references |
| `<space>gF` | File functions (Telescope picker) |
| `<space>gM` | Module functions (Telescope picker) |
| `<space>gS` | Module sibling files |
| `<space>gd` | Toggle debug stream |
| `<space>hn` | Jump to next hint |
| `<space>hp` | Jump to previous hint |
| `<space>hl` | List all hints |
| `<space>hd` | Show hint details |
| `<space>hf` | Apply auto-fix for hint |
| `<space>sv` | Toggle SVN diff markers |
| `<space>sr` | Refresh SVN diff markers |
| `<space>ss` | Show SVN status |
| `<space>su` | Toggle unified signs (compiler + SVN) |
| `<space>sl` | List snippets |
| `<space>sh` | Show snippet help |
| `<space>fw` | Search word under cursor (Telescope) |
| `<space>fg` | Live grep (Telescope) |
| `<space>ff` | Find files (Telescope) |
| `<space>fb` | Search buffers (Telescope) |
| `<space>bn` | Next buffer |
| `<space>bp` | Previous buffer |
| `<space>bd` | Delete buffer |
| `]d` / `[d` | Next/previous error |
| `]h` / `[h` | Next/previous hint |
| `]b` / `[b` | Next/previous buffer |
| `]]` / `[[` | Next/previous temp code tag (#TMP) |
| `Ctrl+h/j/k/l` | Navigate between windows |
| `gcc` | Toggle comment on line (Neovim) |
| `gbc` | Toggle block comment (Neovim) |

**Note:** All keybindings can be customized in your config. See [Configuration](#configuration) section.

## Commands

### Code Navigation Commands

```vim
:GeneroLookup [function_name]           " Find function definition
:GeneroGotoDefinition [function_name]   " Jump to function definition
:GeneroPeekDefinition [function_name]   " Preview function in floating window
:GeneroFindReferences [function_name]   " Find all callers (Telescope picker)
:GeneroListFunctions [file_path]        " List functions in file
:GeneroListModuleFiles [module_name]    " List files in module
:GeneroFunctionSignature [function_name] " Get function signature
:GeneroFileMetadata [file_path]         " Get file metadata
:GeneroConfigShow                       " Display current config
:GeneroClearCache                       " Clear result cache
:GeneroCompleteEnable                   " Enable autocomplete
:GeneroCompleteDisable                  " Disable autocomplete
:GeneroHelp                             " Show keybindings and commands
```

### Telescope Picker Commands (Neovim only)

```vim
:GeneroFileFunctions                    " Pick functions in current file
:GeneroModuleFunctions                  " Pick functions in current module
:GeneroModuleFiles                      " Switch between module sibling files
:GeneroDiagnostics                      " Browse all compiler errors/warnings
:GeneroDiagnosticsErrors                " Browse errors only
:GeneroDiagnosticsWarnings              " Browse warnings only
```

### Compiler Commands

```vim
:GeneroCompile [file_path]              " Compile file or entire project
:GeneroClearErrors                      " Clear error markers and quickfix
:GeneroNextError                        " Jump to next error in quickfix
:GeneroPrevError                        " Jump to previous error in quickfix
:GeneroFirstError                       " Jump to first error in quickfix
:GeneroLastError                        " Jump to last error in quickfix
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

### Debug Streaming Commands (Neovim only)

```vim
:GeneroDebugStreamToggle                " Toggle debug stream window on/off
:GeneroDebugStreamOpen                  " Open debug stream window
:GeneroDebugStreamClose                 " Close debug stream window
:GeneroDebugStreamSelect                " Select a different debug file to stream
:GeneroDebugStreamClear                 " Clear debug output
```

**Note**: Debug streaming is only available in Neovim. See [Debug Streaming Documentation](docs/DEBUG_STREAMING.md) for details.

### Code Hints Commands

```vim
:GeneroNextHint                         " Jump to next hint in file
:GeneroPrevHint                         " Jump to previous hint in file
:GeneroListHints                        " Display all hints in current file
:GeneroHintDetails                      " Show details for hint at cursor
:GeneroHintAutofix                      " Apply auto-fix for hint at cursor
:GeneroHintHelp [hint_name]             " Show help for a specific hint
:GeneroClearHintCache                   " Clear all cached hints
```

**Note**: Code hints are fully configurable and can be enabled/disabled per hint type. See [Code Hints Documentation](docs/HINTS.md) for details.

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

The plugin provides intelligent autocomplete for function and module names. Autocomplete is available for `.4gl` files and triggered manually to avoid conflicts with Tab key indentation.

**Usage:**
```
1. Open a .4gl file
2. Start typing a function or module name
3. Press Ctrl+Space to trigger autocomplete
4. Use Up/Down arrows to navigate
5. Press Enter to select
6. Press Esc to cancel
```

**Manual Completion Keybinding:**
- `Ctrl+Space` - Trigger autocomplete menu (works in insert mode)

**Keybindings in Autocomplete Menu:**
- `Up/Down` - Navigate menu
- `Enter` - Accept selection
- `Esc` - Cancel and close menu

**Completion Features:**
- Function name completion with signatures
- Module name completion
- Cached results for performance
- Works with partial matches (e.g., typing "val" completes "validate_input")
- Robust error handling - completion errors are silently handled and don't interrupt editing
- Manual trigger avoids conflicts with Tab key for indentation

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
  \ 'cache_max_size': 500,
  \ 'display_mode': 'quickfix',
  \ 'keybindings_enabled': 1,
  \ 'timeout': 10000,
  \ 'async_enabled': 1,
  \ 'result_limit': 1000,
  \ 'pagination_size': 50,
  \ 'codebase_markers': ['castle.sch', 'genero.conf', '.genero', '.git'],
  \ 'startup_messages': 'silent',
  \ 'compiler_enabled': 0,
  \ 'compiler_command': 'fglcomp',
  \ 'compiler_args': ['-M', '-W', 'all'],
  \ 'compiler_form_command': 'fglform',
  \ 'compiler_form_args': ['-M', '-W', 'all'],
  \ 'compiler_version': 'auto',
  \ 'compiler_source_dir': '.',
  \ 'compiler_show_warnings': 1,
  \ 'compiler_show_errors': 1,
  \ 'compiler_highlight_unused': 1,
  \ 'compiler_sign_column': 1,
  \ 'compiler_autocompile': 0,
  \ 'compiler_autocompile_delay': 1000,
  \ 'compiler_inline_diagnostics': 1,
  \ 'compiler_type_info': 1,
  \ 'hints_enabled': 1,
  \ 'hints_display': 'signs',
  \ 'hints_severity': 'warning',
  \ 'hints_realtime': 1,
  \ 'hints_cache_enabled': 1,
  \ 'hints_cache_ttl': 300,
  \ 'hints_delay': 500,
  \ 'hints_current_line_only': 0,
  \ 'auto_fix_enabled': 1,
  \ 'trailing_whitespace': 1,
  \ 'mixed_indentation': 1,
  \ 'indentation_consistency': 1,
  \ 'multiple_blank_lines': 1,
  \ 'lowercase_keywords': 1,
  \ 'lowercase_functions': 1,
  \ 'keyword_consistency': 1,
  \ 'naming_convention': 0,
  \ 'unclosed_blocks': 1,
  \ 'nesting_depth': 1,
  \ 'line_length': 1,
  \ 'missing_comments': 0,
  \ 'missing_error_handling': 0,
  \ 'deprecated_functions': 1,
  \ 'max_line_length': 100,
  \ 'max_nesting_depth': 5,
  \ 'max_blank_lines': 2,
  \ 'naming_convention_style': 'camelCase',
  \ 'snippets_enabled': 1,
  \ 'snippet_engine': 'luasnip',
  \ 'snippet_smart_expansion': 1,
  \ 'snippet_custom_dir': expand('~/.config/nvim/genero-snippets'),
  \ 'svn_enabled': 1,
  \ 'svn_show_added': 1,
  \ 'svn_show_modified': 1,
  \ 'svn_show_deleted': 1,
  \ 'svn_cache_ttl': 300,
  \ 'svn_auto_update': 1,
  \ 'floating_window_border': 'rounded',
  \ 'floating_window_width': 80,
  \ 'floating_window_height': 20,
  \ 'floating_window_position': 'center',
  \ 'floating_window_title': 'Genero-Tools',
  \ 'popup_auto_close_delay': 5000,
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

### Performance & Timeout Configuration

Control command execution and result handling:

```vim
let g:genero_tools_config.timeout = 10000                        " Command timeout in milliseconds (default: 10000)
let g:genero_tools_config.async_enabled = 1                      " Enable async operations (default: 1)
let g:genero_tools_config.result_limit = 1000                    " Maximum results returned (default: 1000)
let g:genero_tools_config.pagination_size = 50                   " Results per page (default: 50)
```

**Timeout Behavior:**
- Commands that exceed the timeout are cancelled and return an error
- Increase timeout for very large codebases (6M+ LOC)
- Async mode prevents blocking the editor during long operations

**Result Handling:**
- `result_limit` caps the total number of results returned
- `pagination_size` controls how many results are shown per page
- Useful for managing memory and performance with large result sets

### Cache Configuration

Configure result caching for performance optimization:

```vim
let g:genero_tools_config.cache_enabled = 1                      " Enable/disable result caching (default: 1)
let g:genero_tools_config.cache_ttl = 3600                       " Cache time-to-live in seconds (default: 3600)
let g:genero_tools_config.cache_max_size = 500                   " Maximum cache entries (default: 500)
```

**Cache Features:**
- Caches function lookups, module listings, and other query results
- Automatic expiration based on TTL (time-to-live)
- LRU (Least Recently Used) eviction when cache is full
- Improves performance for repeated queries
- Use `:GeneroClearCache` to manually clear cache

**Cache Tuning:**
- Increase `cache_max_size` for large codebases with many queries
- Increase `cache_ttl` to keep results longer (useful for stable codebases)
- Disable caching if results change frequently during development

### Compiler Configuration

```vim
let g:genero_tools_config.compiler_enabled = 1                   " Enable compiler integration
let g:genero_tools_config.compiler_command = 'fglcomp'            " Compiler command for .4gl/.m3/.m4 files
let g:genero_tools_config.compiler_args = ['-M', '-W', 'all']    " Arguments for fglcomp
let g:genero_tools_config.compiler_form_command = 'fglform'       " Compiler command for .per files
let g:genero_tools_config.compiler_form_args = ['-M', '-W', 'all'] " Arguments for fglform
let g:genero_tools_config.compiler_version = 'auto'              " Version: 'auto', '3.10', '3.20', etc.
let g:genero_tools_config.compiler_source_dir = '.'              " Source directory for compilation
let g:genero_tools_config.compiler_show_warnings = 1             " Display warnings in quickfix
let g:genero_tools_config.compiler_show_errors = 1               " Display errors in quickfix
let g:genero_tools_config.compiler_highlight_unused = 1          " Highlight unused variables
let g:genero_tools_config.compiler_sign_column = 1               " Show signs in sign column
let g:genero_tools_config.compiler_autocompile = 1               " Autocompile on file save
let g:genero_tools_config.compiler_autocompile_delay = 1000      " Delay before autocompile (ms)
let g:genero_tools_config.compiler_inline_diagnostics = 1        " Show error/warning on cursor line (Neovim)
let g:genero_tools_config.compiler_type_info = 1                 " Show function signature on hover (Neovim)
```

**Supported File Types:**
- `.4gl`, `.m3`, `.m4` - Compiled with `fglcomp` (default compiler)
- `.per` - Form files compiled with `fglform` (auto-detected)

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
- **Mixed project support** - Handles projects with both .4gl and .per files

### Snippet Configuration (Neovim only)

For Neovim users with LuaSnip installed, configure code snippets:

```vim
let g:genero_tools_config.snippets_enabled = 1                   " Enable/disable snippets
let g:genero_tools_config.snippet_engine = 'luasnip'             " Snippet engine (luasnip, vim-snipmate, vim-vsnip)
let g:genero_tools_config.snippet_smart_expansion = 1            " Enable async parameter population
let g:genero_tools_config.snippet_custom_dir = expand('~/.config/nvim/genero-snippets') " Custom snippet directory
let g:genero_tools_config.keybindings_enabled = 1                " Enable/disable default keybindings
```

### Floating Window Configuration (Neovim only)

For Neovim users, customize floating window appearance and behavior:

```vim
let g:genero_tools_config.floating_window_border = 'rounded'     " Border style: 'rounded', 'solid', 'shadow', 'none'
let g:genero_tools_config.floating_window_width = 80             " Window width in columns
let g:genero_tools_config.floating_window_height = 20            " Window height in lines
let g:genero_tools_config.floating_window_position = 'center'    " Position: 'center', 'top', 'bottom', 'left', 'right'
let g:genero_tools_config.floating_window_title = 'Genero-Tools' " Window title (empty string to hide)
let g:genero_tools_config.popup_auto_close_delay = 5000          " Auto-close delay in ms (0 = manual close only)
```

See [Floating Window Configuration Guide](docs/FLOATING_WINDOW_CONFIGURATION.md) for detailed options and examples.

### Startup Configuration

Control plugin startup behavior:

```vim
let g:genero_tools_config.startup_messages = 'silent'            " Startup messages: 'silent', 'normal', 'verbose' (default: 'silent')
let g:genero_tools_config.debug_mode = 0                         " Debug mode: 0 = off, 1 = on (default: 0)
let g:genero_tools_config.lua_enabled = 1                        " Enable Lua layer (Neovim only, auto-detected)
```

**Startup Message Modes:**
- `'silent'` - No startup messages (default, clean startup)
- `'normal'` - Standard startup messages
- `'verbose'` - Detailed startup messages for debugging

**Debug Mode:**
- `0` (default) - Debug logging disabled
- `1` - Enable debug logging for troubleshooting
  - Logs are written to debug stream (Neovim only)
  - Use `:GeneroDebugStreamToggle` to view logs
  - Useful for diagnosing configuration and command execution issues

### Code Hints Configuration

Configure code quality hints detection and display:

```vim
let g:genero_tools_config.hints_enabled = 1                      " Enable/disable all hints
let g:genero_tools_config.hints_display = 'signs'                " Display mode: 'signs', 'virtual_text', 'both'
let g:genero_tools_config.hints_severity = 'warning'             " Severity level: 'info', 'warning', 'style'
let g:genero_tools_config.hints_realtime = 1                     " Enable real-time detection
let g:genero_tools_config.hints_cache_enabled = 1                " Enable hint caching
let g:genero_tools_config.hints_cache_ttl = 300                  " Cache TTL in seconds
let g:genero_tools_config.hints_delay = 500                      " Debounce delay in milliseconds
let g:genero_tools_config.hints_current_line_only = 0            " Only show virtual text on cursor line
let g:genero_tools_config.auto_fix_enabled = 1                   " Enable auto-fix suggestions

" Individual hint checks (1 = enabled, 0 = disabled)
let g:genero_tools_config.trailing_whitespace = 1                " Detect trailing whitespace
let g:genero_tools_config.mixed_indentation = 1                  " Detect mixed tabs/spaces
let g:genero_tools_config.indentation_consistency = 1            " Detect inconsistent indentation
let g:genero_tools_config.multiple_blank_lines = 1               " Detect excessive blank lines
let g:genero_tools_config.lowercase_keywords = 1                 " Detect lowercase keywords
let g:genero_tools_config.lowercase_functions = 1                " Detect lowercase functions
let g:genero_tools_config.keyword_consistency = 1                " Detect inconsistent casing
let g:genero_tools_config.naming_convention = 0                  " Detect naming violations
let g:genero_tools_config.unclosed_blocks = 1                    " Detect unclosed blocks
let g:genero_tools_config.nesting_depth = 1                      " Detect excessive nesting
let g:genero_tools_config.line_length = 1                        " Detect long lines
let g:genero_tools_config.missing_comments = 0                   " Detect missing comments
let g:genero_tools_config.missing_error_handling = 0             " Detect missing error handling
let g:genero_tools_config.deprecated_functions = 1               " Detect deprecated functions

" Threshold options
let g:genero_tools_config.max_line_length = 100                  " Maximum line length
let g:genero_tools_config.max_nesting_depth = 5                  " Maximum nesting depth
let g:genero_tools_config.max_blank_lines = 2                    " Maximum consecutive blank lines
let g:genero_tools_config.naming_convention_style = 'camelCase'  " Naming style: 'camelCase', 'snake_case'
```

**Hints Features:**
- Real-time code quality analysis with configurable debounce delay
- Multiple display modes: sign column, virtual text (Neovim), or both
- Severity levels for visual distinction (info, warning, style)
- Per-file and project-wide configuration support via .genero-hints
- Auto-fix suggestions for common issues
- Caching for performance optimization
- See [Code Hints Documentation](docs/HINTS.md) for complete details

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
let g:genero_tools_config.display_mode = 'popup'                 " Use popup windows for results
```

**Lua Layer Features** (Neovim 0.5+ only):
- **Async Operations** - Non-blocking command execution with progress indicators
- **Floating Windows** - Rich UI for results with better formatting
- **Better Performance** - Optimized for large codebases
- **UI Components** - Notifications, progress bars, popup menus

The Lua layer is optional and gracefully falls back to VimScript implementations if unavailable. All core functionality works in both Vim and Neovim without the Lua layer.

### Error Handling

All error messages follow a consistent format: `[MODULE] Error description`

**Error Message Examples:**
- `[config] timeout must be positive, using default 10000`
- `[command] Function not found: myFunc`
- `[cache] Cache is full, evicting oldest entry`

**Error Display:**
- Errors are displayed with red highlighting
- Warnings are displayed with yellow highlighting
- Debug messages are logged to debug stream (Neovim only)

**Error Functions:**
- `genero_tools#error#format(module, message)` - Format error message
- `genero_tools#error#echo(module, message)` - Echo error message
- `genero_tools#error#warn(module, message)` - Display warning
- `genero_tools#error#error(module, message)` - Display error
- `genero_tools#error#debug(module, message)` - Log debug message
- `genero_tools#error#result(module, message)` - Create error result dictionary

### Large Codebase Guidance

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
- **[Code Hints](docs/HINTS.md)** - Code quality hints and auto-fix
- **[Error Handling](docs/ERROR_HANDLING.md)** - Error handling and troubleshooting

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

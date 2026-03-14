# Vim Genero-Tools Plugin

A vim plugin that integrates with genero-tools to provide code navigation and lookup for large-scale Genero codebases (thousands of files, 6M+ LOC).

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

- Function lookup and search
- Module and file exploration
- Function signatures and metadata
- Intelligent caching with LRU eviction
- Result pagination for large codebases
- Multiple display modes (quickfix, popup, inline, split, echo)
- **Omnifunc autocomplete** - Function and module name completion with signatures
- Full Vim 8.0+ and Neovim 0.4+ compatibility
- Zero configuration changes required between editors

## Keybindings

The default leader key is backslash `\`. All keybindings work in normal mode.

### Default Keybindings

| Keybinding | Action | Example |
|-----------|--------|---------|
| `<leader>gl` | Find function under cursor | Place cursor on `validate_input`, press `\gl` |
| `<leader>gf` | List functions in current file | Press `\gf` to see all functions |
| `<leader>gs` | Get function signature under cursor | Place cursor on `process_data`, press `\gs` |
| `<leader>gm` | Get metadata for current file | Press `\gm` to see author, tickets, dates |

### Usage Examples

**Example 1: Lookup a function definition**
```
1. Open a .4gl file
2. Place cursor on a function name: validate_input
3. Press \gl
4. Results appear in quickfix list (or inline popup, depending on display_mode)
```

**Example 2: Get function signature**
```
1. Open a .4gl file
2. Place cursor on a function name: calculate_total
3. Press \gs
4. Function signature appears (parameters, return types)
```

**Example 3: List all functions in current file**
```
1. Open a .4gl file
2. Press \gf
3. All functions in the file are listed with line numbers
```

**Example 4: Get file metadata**
```
1. Open a .4gl file
2. Press \gm
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

All keybindings are shortcuts for these commands:

```vim
:GeneroLookup [function_name]           " Find function definition
:GeneroListFunctions [file_path]        " List functions in file
:GeneroListModuleFiles [module_name]    " List files in module
:GeneroFunctionSignature [function_name] " Get function signature
:GeneroFileMetadata [file_path]         " Get file metadata
:GeneroConfigShow                       " Display current config
:GeneroClearCache                       " Clear result cache
```

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
3. Press Ctrl+X Ctrl+O to trigger omnifunc completion
4. Select from the list of matching functions/modules
5. Completion shows function signatures in the preview
```

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
  \ 'pagination_size': 50
  \ }
```

For large codebases (6M+ LOC), see [Setup Guide](docs/SETUP_FRESH_VIM.md) for optimized configuration.

## Documentation

- **[Setup Guide](docs/SETUP_FRESH_VIM.md)** - Fresh Vim installation guide
- **[Quick Start](docs/QUICK_START.md)** - User guide with examples
- **[API Integration](docs/API_INTEGRATION.md)** - Complete API reference
- **[Compatibility](docs/COMPATIBILITY.md)** - Vim/Neovim compatibility

## Requirements

- Vim 8.0+ or Neovim 0.4+
- genero-tools CLI installed and in PATH

## License

MIT

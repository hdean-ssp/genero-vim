# Genero-Tools Developer Quick Reference

Fast lookup for commands, keybindings, and features. For detailed info, see [README.md](../README.md).

## Essential Keybindings

All keybindings use `<leader>` (default: `<space>`) in normal mode.

| Binding | Action |
|---------|--------|
| `F5` | Compile current file |
| `Ctrl+,` | Previous error |
| `Ctrl+.` | Next error |
| `Ctrl+Space` | Autocomplete (insert mode) |
| `<leader>gl` | Lookup function under cursor |
| `<leader>gf` | List functions in file |
| `<leader>gs` | Get function signature |
| `<leader>gm` | Get file metadata |
| `<leader>ca` | Enable autocompile |
| `<leader>cd` | Disable autocompile |
| `<leader>cc` | Clear error markers |

**Neovim only:**
| `<leader>gd` | Toggle debug stream |
| `<leader>sl` | List snippets |
| `<leader>sh` | Show snippet help |

## Code Navigation Commands

```vim
:GeneroLookup [name]              " Find function definition
:GeneroListFunctions [file]       " List functions in file
:GeneroListModuleFiles [module]   " List files in module
:GeneroFunctionSignature [name]   " Get function signature
:GeneroFileMetadata [file]        " Get file metadata
```

**Usage:** Commands work with or without arguments. Without args, they use the current file or word under cursor.

## Compiler Commands

```vim
:GeneroCompile [file]             " Compile file or project
:GeneroNextError                  " Jump to next error
:GeneroPrevError                  " Jump to previous error
:GeneroFirstError                 " Jump to first error
:GeneroLastError                  " Jump to last error
:GeneroClearErrors                " Clear error markers
:GeneroAutocompileEnable          " Enable autocompile on save
:GeneroAutocompileDisable         " Disable autocompile on save
:GeneroAutocompileStatus          " Show autocompile status
```

**Features:**
- Real-time error/warning parsing
- Sign column indicators (✕ errors, ⚠ warnings)
- Syntax highlighting (red for errors, yellow for warnings)
- Unused variable detection
- Quickfix integration

## SVN Commands

```vim
:GeneroSVNRefresh                 " Refresh diff markers for current file
:GeneroSVNToggle                  " Toggle diff markers on/off
:GeneroSVNStatus                  " Show SVN status and changes
:GeneroSVNCacheStats              " Show cache statistics
:GeneroSVNCacheClear              " Clear SVN cache
```

**Sign Column Indicators:**
- `+` Added lines
- `~` Modified lines
- `-` Deleted lines

## Snippet Commands (Neovim only)

```vim
:GeneroSnippetList                " List all available snippets
:GeneroSnippetHelp [trigger]      " Show help for snippet
:GeneroSnippet [trigger]          " Expand snippet by trigger
```

**Features:**
- Smart parameter population from function signatures
- Placeholder navigation with Tab/Shift+Tab
- Custom snippet support

## Debug Streaming (Neovim only)

```vim
:GeneroDebugStreamToggle          " Toggle debug stream window
:GeneroDebugStreamSelect          " Select different debug file
:GeneroDebugStreamClear           " Clear debug output
:GeneroDebugStreamStatus          " Show stream status
```

## Utility Commands

```vim
:GeneroClearCache                 " Clear result cache
:GeneroConfigShow                 " Display current configuration
:GeneroCompleteEnable             " Enable autocomplete
:GeneroCompleteDisable            " Disable autocomplete
```

## Display Modes

Change how results are displayed:

```vim
let g:genero_tools_config.display_mode = 'quickfix'  " Quickfix list (default)
let g:genero_tools_config.display_mode = 'inline'    " Popup in command line
let g:genero_tools_config.display_mode = 'split'     " New split window
let g:genero_tools_config.display_mode = 'echo'      " Command line output
let g:genero_tools_config.display_mode = 'popup'     " Floating window (Neovim only)
```

## Essential Configuration

```vim
" Compiler
let g:genero_tools_config.compiler_enabled = 1
let g:genero_tools_config.compiler_autocompile = 1
let g:genero_tools_config.compiler_command = 'fglcomp -M -W all'

" Display
let g:genero_tools_config.display_mode = 'quickfix'
let g:genero_tools_config.keybindings_enabled = 1

" Performance (large codebases)
let g:genero_tools_config.cache_ttl = 3600
let g:genero_tools_config.timeout = 10000
let g:genero_tools_config.result_limit = 1000

" SVN
let g:genero_tools_config.svn_enabled = 1
let g:genero_tools_config.svn_auto_update = 1

" Debugging
let g:genero_tools_config.debug_mode = 0  " Enable for debug logging

" Neovim Lua layer
let g:genero_tools_config.lua_enabled = 1
let g:genero_tools_config.async_enabled = 1
```

## Autocomplete

**Trigger:** `Ctrl+Space` in insert mode

**Features:**
- Function name completion with signatures
- Module name completion
- Partial match support (e.g., "val" → "validate_input")
- Cached results for performance

## which-key Integration

If [which-key](https://github.com/folke/which-key.nvim) is installed, press `<leader>g` to see all keybindings organized by group.

**Groups:**
- `<leader>gl/f/s/m` - Code navigation
- `<leader>gc*` - Compiler commands
- `<leader>ga*` - Cache commands
- `<leader>gv*` - SVN commands
- `<leader>gh` - Help
- `<leader>gC` - Configuration

## Performance Tips

**For large codebases (6M+ LOC):**

1. Increase cache TTL and size:
```vim
let g:genero_tools_config.cache_ttl = 7200
let g:genero_tools_config.cache_max_size = 200
```

2. Use async mode (Neovim):
```vim
let g:genero_tools_config.async_enabled = 1
```

3. Increase timeout for slow systems:
```vim
let g:genero_tools_config.timeout = 15000
```

4. Use specific search terms to reduce result size:
```vim
:GeneroLookup mymodule.m3:myFunction
```

## Error Handling

All error messages follow a consistent format: `[MODULE] Error description`

**Error Display Functions:**
- `genero_tools#error#format(module, message)` - Format error message
- `genero_tools#error#echo(module, message)` - Echo error message
- `genero_tools#error#warn(module, message)` - Display warning (yellow)
- `genero_tools#error#error(module, message)` - Display error (red)
- `genero_tools#error#debug(module, message)` - Log debug message
- `genero_tools#error#result(module, message)` - Create error result dictionary

**Example:**
```vim
call genero_tools#error#warn('config', 'timeout must be positive, using default 10000')
" Displays: [config] timeout must be positive, using default 10000 (yellow)
```

See [Error Handling Documentation](ERROR_HANDLING.md) for complete details.

## Troubleshooting

**Compiler not found:**
```vim
let g:genero_tools_config.compiler_command = '/full/path/to/fglcomp -M -W all'
```

**query.sh not found:**
```vim
let g:genero_tools_config.genero_tools_path = '/full/path/to/query.sh'
```

**Autocompile not working:**
```vim
:GeneroAutocompileStatus
```

**Autocomplete not triggering:**
```vim
:GeneroCompleteEnable
```

**SVN markers not showing:**
```vim
:GeneroSVNRefresh
```

**Enable debug logging:**
```vim
let g:genero_tools_config.debug_mode = 1
:GeneroDebugStreamToggle
```

## Customizing Keybindings

Disable defaults and add custom bindings:

```vim
let g:genero_tools_config.keybindings_enabled = 0

" Custom keybindings
nnoremap <F6> :GeneroCompile<CR>
nnoremap <C-l> :GeneroLookup <C-R><C-W><CR>
nnoremap <leader>n :GeneroNextError<CR>
nnoremap <leader>p :GeneroPrevError<CR>
```

## Documentation

- **[README.md](../README.md)** - Complete feature documentation
- **[QUICK_START.md](QUICK_START.md)** - 5-minute setup guide
- **[SETUP_FRESH_VIM.md](SETUP_FRESH_VIM.md)** - Fresh Vim installation
- **[COMPILER_INTEGRATION.md](COMPILER_INTEGRATION.md)** - Compiler details
- **[SVN_DIFF_MARKERS.md](SVN_DIFF_MARKERS.md)** - SVN integration
- **[SNIPPETS.md](SNIPPETS.md)** - Code snippets (Neovim)
- **[DEBUG_STREAMING.md](DEBUG_STREAMING.md)** - Debug streaming (Neovim)
- **[NEOVIM.md](NEOVIM.md)** - Neovim-specific features

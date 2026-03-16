# Neovim Setup Guide

Get vim-genero-tools running in Neovim with the same functionality as Vim, plus async operations and floating windows.

## Installation

### Using vim-plug

Add to `~/.config/nvim/init.vim`:

```vim
call plug#begin('~/.config/nvim/plugged')
Plug 'hdean-ssp/genero-vim'
call plug#end()
```

Run `:PlugInstall`.

### Using packer.nvim

Add to `~/.config/nvim/init.lua`:

```lua
require('packer').startup(function(use)
  use 'hdean-ssp/genero-vim'
end)
```

Run `:PackerSync`.

### Using lazy.nvim

Add to `~/.config/nvim/init.lua`:

```lua
{ 'hdean-ssp/genero-vim', lazy = false }
```

## Configuration

### Minimal Setup

**init.vim:**
```vim
let g:genero_tools_config = {
  \ 'lua_enabled': v:true,
  \ 'async_enabled': v:true,
  \ 'display_mode': 'floating',
  \ }
```

**init.lua:**
```lua
vim.g.genero_tools_config = {
  lua_enabled = true,
  async_enabled = true,
  display_mode = 'floating',
}
```

### Configure Query Path and Compiler

**init.vim:**
```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': '/path/to/query.sh',
  \ 'compiler_enabled': v:true,
  \ 'compiler_command': 'fglcomp -M -W all',
  \ 'compiler_source_dir': '.',
  \ 'compiler_autocompile': v:true,
  \ 'compiler_autocompile_delay': 1000,
  \ 'lua_enabled': v:true,
  \ 'async_enabled': v:true,
  \ 'display_mode': 'floating',
  \ }
```

**init.lua:**
```lua
vim.g.genero_tools_config = {
  genero_tools_path = '/path/to/query.sh',
  compiler_enabled = true,
  compiler_command = 'fglcomp -M -W all',
  compiler_source_dir = '.',
  compiler_autocompile = true,
  compiler_autocompile_delay = 1000,
  lua_enabled = true,
  async_enabled = true,
  display_mode = 'floating',
}
```

### Configuration Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `genero_tools_path` | string | `'query.sh'` | Path to query.sh (full path if not in PATH) |
| `compiler_enabled` | bool | `false` | Enable compiler integration |
| `compiler_command` | string | `'fglcomp'` | Compiler command (e.g., `'fglcomp -M -W all'`) |
| `compiler_source_dir` | string | `'.'` | Source directory for compilation |
| `compiler_autocompile` | bool | `false` | Auto-compile on file save |
| `compiler_autocompile_delay` | number | `1000` | Delay in ms before auto-compile |
| `compiler_show_warnings` | bool | `true` | Show compiler warnings |
| `compiler_show_errors` | bool | `true` | Show compiler errors |
| `compiler_highlight_unused` | bool | `true` | Highlight unused functions |
| `compiler_sign_column` | bool | `true` | Show error signs in sign column |
| `lua_enabled` | bool | `true` | Enable Lua layer (Neovim only) |
| `async_enabled` | bool | `true` | Enable async operations |
| `display_mode` | string | `'quickfix'` | Display mode: `'floating'`, `'quickfix'`, `'split'`, `'echo'` |
| `cache_enabled` | bool | `true` | Enable result caching |
| `cache_ttl` | number | `3600` | Cache time-to-live in seconds |
| `cache_max_size` | number | `100` | Max cache entries |
| `timeout` | number | `10000` | Query timeout in milliseconds |

### Display Modes

**init.vim:**
```vim
" Floating window (recommended for Neovim)
let g:genero_tools_config.display_mode = 'floating'

" Quickfix list (default, works everywhere)
let g:genero_tools_config.display_mode = 'quickfix'

" Split window
let g:genero_tools_config.display_mode = 'split'

" Command line
let g:genero_tools_config.display_mode = 'echo'
```

**init.lua:**
```lua
-- Floating window (recommended for Neovim)
vim.g.genero_tools_config.display_mode = 'floating'

-- Quickfix list (default, works everywhere)
vim.g.genero_tools_config.display_mode = 'quickfix'

-- Split window
vim.g.genero_tools_config.display_mode = 'split'

-- Command line
vim.g.genero_tools_config.display_mode = 'echo'
```

### Performance (Large Codebases)

```vim
let g:genero_tools_config = {
  \ 'lua_enabled': v:true,
  \ 'async_enabled': v:true,
  \ 'ui_mode': 'floating',
  \ 'cache_enabled': v:true,
  \ 'cache_max_size': 200,
  \ 'timeout': 15000,
  \ }
```

## Verification

After installation:

```vim
:GeneroConfigShow  " Verify configuration
:GeneroLookup myFunction  " Test a command
```

## Usage

All commands work identically to Vim:

```vim
:GeneroLookup myFunction           " Find function
:GeneroListFunctions %             " List functions in file
:GeneroListModuleFiles mymodule    " List files in module
:GeneroFunctionSignature myFunc    " Get signature
:GeneroFileMetadata %              " Get file metadata
:GeneroClearCache                  " Clear cache
```

### Keybindings

Default keybindings (with `\` as leader):

```vim
<leader>gl  " Lookup function under cursor
<leader>gf  " List functions in current file
<leader>gs  " Get function signature
<leader>gm  " Get file metadata
```

To use space as leader:

```vim
let mapleader = " "
```

## Neovim Features

### Async Operations

Commands execute without blocking the editor:

```vim
let g:genero_tools_config.async_enabled = v:true
```

Enabled by default. Makes the plugin responsive on large codebases.

### Floating Windows

Results display in a centered floating window:

```vim
let g:genero_tools_config.ui_mode = 'floating'
```

**Navigation:**
- `j/k` - Move down/up
- `gg/G` - Go to start/end
- `q` or `<Esc>` - Close window

Requires Neovim 0.5+. Use quickfix mode for older versions.

## Troubleshooting

### Plugin not loading

Verify Neovim can find the plugin:

```vim
:echo &runtimepath
```

### Floating windows not working

Check Neovim version:

```vim
:echo nvim_version()
```

If using Neovim < 0.5, switch to quickfix:

```vim
let g:genero_tools_config.display_mode = 'quickfix'
```

### Commands not found

Verify genero-tools is installed:

```bash
which query.sh
```

If not in PATH, configure the full path in **init.vim**:

```vim
let g:genero_tools_config.genero_tools_path = '/path/to/query.sh'
```

Or in **init.lua**:

```lua
vim.g.genero_tools_config.genero_tools_path = '/path/to/query.sh'
```

### Compiler not found

Verify fglcomp is installed:

```bash
which fglcomp
```

If not in PATH, configure the full path in **init.vim**:

```vim
let g:genero_tools_config.compiler_command = '/path/to/fglcomp -M -W all'
```

Or in **init.lua**:

```lua
vim.g.genero_tools_config.compiler_command = '/path/to/fglcomp -M -W all'
```

### Autocompile not working

Verify autocompile is enabled:

```vim
:GeneroConfigShow
```

Check that `compiler_autocompile` is `true`. Enable it in **init.vim**:

```vim
let g:genero_tools_config.compiler_autocompile = v:true
```

Or in **init.lua**:

```lua
vim.g.genero_tools_config.compiler_autocompile = true
```

### Autocomplete not working

Trigger with `<C-x><C-o>` in insert mode, or configure Tab in **init.vim**:

```vim
inoremap <buffer> <Tab> <C-x><C-o>
```

Or in **init.lua**:

```lua
vim.keymap.set('i', '<Tab>', '<C-x><C-o>', { buffer = true })
```

## Feature Comparison

| Feature | Vim | Neovim |
|---------|-----|--------|
| Function lookup | ✅ | ✅ |
| Module exploration | ✅ | ✅ |
| File metadata | ✅ | ✅ |
| Autocomplete | ✅ | ✅ |
| Compiler integration | ✅ | ✅ |
| Caching | ✅ | ✅ |
| Floating windows | ❌ | ✅ |
| Async operations | ❌ | ✅ |

## See Also

- [README.md](../README.md) - Full feature documentation
- [QUICK_START.md](QUICK_START.md) - General quick start
- [API_INTEGRATION.md](API_INTEGRATION.md) - API reference

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
  \ 'ui_mode': 'floating',
  \ }
```

**init.lua:**
```lua
vim.g.genero_tools_config = {
  lua_enabled = true,
  async_enabled = true,
  ui_mode = 'floating',
}
```

### Display Modes

```vim
" Floating window (recommended for Neovim)
let g:genero_tools_config.ui_mode = 'floating'

" Quickfix list (default, works everywhere)
let g:genero_tools_config.ui_mode = 'quickfix'

" Split window
let g:genero_tools_config.ui_mode = 'split'

" Command line
let g:genero_tools_config.ui_mode = 'echo'
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
let g:genero_tools_config.ui_mode = 'quickfix'
```

### Commands not found

Verify genero-tools is installed:

```bash
which query.sh
```

If not in PATH, configure it:

```vim
let g:genero_tools_config.genero_tools_path = '/path/to/query.sh'
```

### Autocomplete not working

Trigger with `<C-x><C-o>` in insert mode, or configure Tab:

```vim
inoremap <buffer> <Tab> <C-x><C-o>
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

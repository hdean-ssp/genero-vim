# Vim Genero-Tools Plugin - Quick Start

## 5-Minute Setup

### 1. Install Plugin

Using vim-plug, add to your `.vimrc`:
```vim
Plug 'hdean-ssp/genero-vim'
```

Then run `:PlugInstall`

### 2. Basic Configuration

Add to your `.vimrc`:
```vim
let g:genero_tools_config = {
  \ 'compiler_enabled': v:true,
  \ 'compiler_autocompile': v:true,
  \ }

autocmd FileType genero,fgl call genero_tools#compiler#autocompile#enable()
```

### 3. Verify Installation

```vim
:GeneroConfigShow
```

## Common Commands

### Code Navigation
```vim
:GeneroLookup myFunction          " Find function
:GeneroListFunctions              " List functions in current file
:GeneroFunctionSignature myFunc   " Show function signature
:GeneroFileMetadata               " Show file metadata
```

### Compiler
```vim
:GeneroCompile                    " Compile current file
:GeneroNextError                  " Jump to next error
:GeneroPrevError                  " Jump to previous error
:GeneroAutocompileEnable          " Enable autocompile
:GeneroAutocompileDisable         " Disable autocompile
```

### Utility
```vim
:GeneroClearCache                 " Clear result cache
:GeneroConfigShow                 " Show configuration
```

## Default Keybindings

| Keybinding | Action |
|-----------|--------|
| `<leader>gl` | Find function under cursor |
| `<leader>gf` | List functions in current file |
| `<leader>gs` | Get function signature under cursor |
| `<leader>gm` | Get file metadata for current file |

## Compiler Features

The plugin automatically compiles files on save with:
```bash
fglcomp -M -W all <file>
```

Features:
- Real-time error/warning display (in quickfix or floating window on Neovim)
- Visual indicators in sign column
- Unused variable highlighting
- Quickfix integration for navigation
- Error markers populated when opening files
- Automatic compilation on save (with configurable delay)

## Configuration

### Essential Options

```vim
let g:genero_tools_config = {
  \ 'compiler_enabled': v:true,
  \ 'compiler_autocompile': v:true,
  \ 'compiler_command': 'fglcomp -M -W all',
  \ 'display_mode': 'quickfix',
  \ 'keybindings_enabled': v:true,
  \ }
```

### For Large Codebases

```vim
let g:genero_tools_config = {
  \ 'cache_ttl': 7200,
  \ 'cache_max_size': 200,
  \ 'timeout': 15000,
  \ 'result_limit': 2000,
  \ 'pagination_size': 100,
  \ }
```

## Troubleshooting

**Compiler not found:**
```vim
let g:genero_tools_config.compiler_command = '/path/to/fglcomp -M -W all'
```

**query.sh not found:**
```vim
let g:genero_tools_config.genero_tools_path = '/path/to/query.sh'
```

**Autocompile not working:**
```vim
:GeneroAutocompileStatus
```

## Next Steps

- **Fresh Install?** See [SETUP_FRESH_VIM.md](SETUP_FRESH_VIM.md)
- **Compiler Details?** See [COMPILER_INTEGRATION.md](COMPILER_INTEGRATION.md)
- **Code Navigation?** See [API_INTEGRATION.md](API_INTEGRATION.md)
- **Neovim Features?** See [NEOVIM.md](NEOVIM.md)

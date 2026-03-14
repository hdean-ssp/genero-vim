# Vim Genero-Tools Plugin - Quick Start

## Installation

1. Install the plugin using your favorite plugin manager (vim-plug, vundle, etc.)
2. Ensure `query.sh` is in your PATH or configure the path in `.vimrc`

## Setup

Before using the plugin, generate the genero-tools databases:

```bash
bash generate_signatures.sh /path/to/codebase
bash generate_modules.sh /path/to/codebase
query.sh create-dbs
query.sh find-function test_function
```

## Basic Usage

### Find a Function
```vim
:GeneroLookup myFunction
<leader>gl  " Place cursor on function name
```

### List Functions in Current File
```vim
:GeneroListFunctions
<leader>gf
```

### Get Function Signature
```vim
:GeneroFunctionSignature myFunction
<leader>gs
```

### List Functions in a Module
```vim
:GeneroListModuleFiles core
```

### Get File Metadata
```vim
:GeneroFileMetadata ./src/utils.4gl
<leader>gm
```

### Clear Cache & Show Config
```vim
:GeneroClearCache
:GeneroConfigShow
```

## Configuration

```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': 'query.sh',
  \ 'cache_enabled': v:true,
  \ 'cache_ttl': 3600,
  \ 'display_mode': 'quickfix',
  \ 'keybindings_enabled': v:true,
  \ 'timeout': 10000,
  \ 'async_enabled': v:true
  \ }
```

## Display Modes

```vim
let g:genero_tools_config.display_mode = 'quickfix'  " Default
let g:genero_tools_config.display_mode = 'popup'     " Neovim only
let g:genero_tools_config.display_mode = 'split'
let g:genero_tools_config.display_mode = 'echo'
```

## Keybindings

| Keybinding | Action |
|-----------|--------|
| `<leader>gl` | Find function under cursor |
| `<leader>gf` | List functions in current file |
| `<leader>gs` | Get function signature |
| `<leader>gm` | Get file metadata |

## Troubleshooting

**query.sh not found:**
```vim
let g:genero_tools_config.genero_tools_path = '/path/to/query.sh'
```

**Slow queries:**
```vim
let g:genero_tools_config.cache_enabled = v:true
let g:genero_tools_config.timeout = 15000
```

**Results not updating:**
```vim
:GeneroClearCache
```

## Next Steps

- Read [API_INTEGRATION.md](API_INTEGRATION.md) for detailed API documentation
- Check [COMPATIBILITY.md](COMPATIBILITY.md) for Vim/Neovim compatibility
- Review genero-tools API in `/genero-tools-api/api/`

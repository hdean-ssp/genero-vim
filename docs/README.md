# Vim Genero-Tools Plugin Documentation

## Quick Navigation

- **[Getting Started](QUICK_START.md)** - User-friendly quick start guide
- **[API Integration](API_INTEGRATION.md)** - Complete API integration guide
- **[Compatibility](COMPATIBILITY.md)** - Detailed compatibility information

## Overview

The vim-genero-tools plugin integrates with genero-tools to provide code navigation and lookup for large-scale Genero codebases (thousands of files, 6M+ LOC).

### Key Features

- Function lookup and search
- Module and file exploration
- Function signatures and metadata
- Intelligent caching with LRU eviction
- Result pagination for large codebases
- Multiple display modes (quickfix, popup, split, echo)
- Full Vim 8.0+ and Neovim 0.4+ compatibility
- Zero configuration changes required

### Installation

Using vim-plug:
```vim
Plug 'your-username/vim-genero-tools'
```

### Quick Start

```vim
:GeneroLookup myFunction
<leader>gl  " Lookup function under cursor
<leader>gf  " List functions in current file
<leader>gs  " Get function signature
<leader>gm  " Get file metadata

" Compiler commands
:GeneroCompile              " Compile current file
:GeneroClearErrors          " Clear error markers
:GeneroNextError            " Jump to next error
:GeneroPrevError            " Jump to previous error
```

## Documentation Files

| File | Purpose |
|------|---------|
| QUICK_START.md | User-friendly quick start guide with examples |
| API_INTEGRATION.md | Complete API integration and command reference |
| COMPATIBILITY.md | Detailed compatibility information for Vim and Neovim |

## Setup

Before using the plugin, generate the genero-tools databases:

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
  \ 'display_mode': 'quickfix'
  \ }
```

## Support

- Check the documentation files for detailed information
- Review genero-tools API documentation in `/genero-tools-api/api/`
- All features work identically in Vim and Neovim

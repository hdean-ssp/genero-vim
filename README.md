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
Plug 'your-username/vim-genero-tools'
```

## Features

- Function lookup and search
- Module and file exploration
- Function signatures and metadata
- Intelligent caching with LRU eviction
- Result pagination for large codebases
- Multiple display modes (quickfix, popup, split, echo)
- Full Vim 8.0+ and Neovim 0.4+ compatibility
- Zero configuration changes required

## Documentation

- **[Quick Start](docs/QUICK_START.md)** - User guide with examples
- **[API Integration](docs/API_INTEGRATION.md)** - Complete API reference
- **[Compatibility](docs/COMPATIBILITY.md)** - Vim/Neovim compatibility

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
  \ 'display_mode': 'quickfix'
  \ }
```

## Requirements

- Vim 8.0+ or Neovim 0.4+
- genero-tools CLI installed and in PATH

## License

MIT

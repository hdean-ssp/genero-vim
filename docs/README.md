# Genero-Tools Documentation

Welcome to the genero-tools plugin documentation. This guide will help you get started and understand all available features.

## Getting Started

- **[QUICK_START.md](QUICK_START.md)** - Get up and running in 5 minutes
- **[SETUP_FRESH_VIM.md](SETUP_FRESH_VIM.md)** - Fresh Vim/Neovim installation guide

## User Guides

### Core Features

- **[COMPILER_INTEGRATION.md](COMPILER_INTEGRATION.md)** - Compiler integration, autocompile, error display
- **[API_INTEGRATION.md](API_INTEGRATION.md)** - Using genero-tools API for code navigation
- **[COMPATIBILITY.md](COMPATIBILITY.md)** - Vim/Neovim compatibility information

### Platform-Specific

- **[NEOVIM.md](NEOVIM.md)** - Neovim-specific features and setup

## Feature Overview

### Compiler Integration

The plugin provides real-time compilation feedback:
- Automatic compilation on file save
- Error and warning display in quickfix
- Visual indicators (signs) in sign column
- Unused variable highlighting
- Configurable compiler command and options

**See:** [COMPILER_INTEGRATION.md](COMPILER_INTEGRATION.md)

### Code Navigation

Navigate your Genero codebase efficiently:
- Find functions by name or pattern
- List functions in files and modules
- View function signatures
- Get file metadata and references

**See:** [API_INTEGRATION.md](API_INTEGRATION.md)

### Lua Layer (Neovim)

Enhanced functionality for Neovim users:
- Async operations
- Better UI integration
- LSP-ready architecture

**See:** [NEOVIM.md](NEOVIM.md)

## Configuration

All features are configured through `g:genero_tools_config`:

```vim
let g:genero_tools_config = {
  \ 'compiler_enabled': v:true,
  \ 'compiler_autocompile': v:true,
  \ 'compiler_highlight_unused': v:true,
  \ }
```

See individual feature guides for all available options.

## Troubleshooting

### Common Issues

**Compiler not found:**
```vim
let g:genero_tools_config.compiler_command = '/path/to/fglcomp'
```

**Autocompile not working:**
```vim
:GeneroAutocompileStatus
```

**No signs showing:**
```vim
let g:genero_tools_config.compiler_sign_column = v:true
```

See feature-specific guides for detailed troubleshooting.

## Commands Reference

### Compiler Commands

```vim
:GeneroCompile [file]              " Compile file
:GeneroAutocompileEnable           " Enable autocompile
:GeneroAutocompileDisable          " Disable autocompile
:GeneroAutocompileStatus           " Show autocompile status
:GeneroNextError                   " Jump to next error
:GeneroPrevError                   " Jump to previous error
:GeneroClearErrors                 " Clear error markers
```

### Navigation Commands

```vim
:GeneroLookup [function]           " Find function
:GeneroListFunctions [file]        " List functions in file
:GeneroFunctionSignature [func]    " Show function signature
:GeneroFileMetadata [file]         " Show file metadata
```

### Utility Commands

```vim
:GeneroClearCache                  " Clear cache
:GeneroConfigShow                  " Show configuration
:GeneroCompleteEnable              " Enable completion
:GeneroCompleteDisable             " Disable completion
```

## Development

For developers working on the plugin:

- **[.kiro/steering/COMPILER_DEVELOPMENT.md](../.kiro/steering/COMPILER_DEVELOPMENT.md)** - Compiler module architecture and development guide
- **[.kiro/steering/vimscript-conventions.md](../.kiro/steering/vimscript-conventions.md)** - Code style and conventions
- **[.kiro/steering/error-handling-patterns.md](../.kiro/steering/error-handling-patterns.md)** - Error handling patterns
- **[.kiro/steering/lua-layer-architecture.md](../.kiro/steering/lua-layer-architecture.md)** - Lua layer design

## Roadmap

Future enhancements planned:

- **Dead Code Detection** - Find unused functions
- **Dependency Analysis** - Show function call chains
- **Reference Lookup** - Find files modified for tickets
- **Module Dependencies** - Visualize module relationships

See [QUICK_ENHANCEMENTS_ROADMAP.md](../QUICK_ENHANCEMENTS_ROADMAP.md) for details.

## Support

### Getting Help

1. Check the relevant feature guide
2. Review troubleshooting section
3. Check plugin configuration with `:GeneroConfigShow`
4. Enable verbose output with `:set verbose=9`

### Reporting Issues

When reporting issues, include:
- Vim/Neovim version
- Plugin version
- Configuration settings
- Steps to reproduce
- Error messages

## License

See [LICENSE](../LICENSE) for license information.

## Quick Links

- **User Guides:** [COMPILER_INTEGRATION.md](COMPILER_INTEGRATION.md), [API_INTEGRATION.md](API_INTEGRATION.md)
- **Setup:** [QUICK_START.md](QUICK_START.md), [SETUP_FRESH_VIM.md](SETUP_FRESH_VIM.md)
- **Development:** [.kiro/steering/COMPILER_DEVELOPMENT.md](../.kiro/steering/COMPILER_DEVELOPMENT.md)
- **Roadmap:** [QUICK_ENHANCEMENTS_ROADMAP.md](../QUICK_ENHANCEMENTS_ROADMAP.md)

# Genero-Tools Documentation

Welcome to the genero-tools plugin documentation. This guide will help you get started and understand all available features.

## Getting Started

- **[QUICK_START.md](QUICK_START.md)** - Get up and running in 5 minutes (start here)
- **[SETUP_FRESH_VIM.md](SETUP_FRESH_VIM.md)** - Detailed fresh Vim/Neovim installation guide

## User Guides

- **[COMPILER_INTEGRATION.md](COMPILER_INTEGRATION.md)** - Compiler integration, autocompile, error display
- **[API_INTEGRATION.md](API_INTEGRATION.md)** - Code navigation and lookup functionality
- **[AUTOCOMPLETE.md](AUTOCOMPLETE.md)** - Code completion and auto-completion on pause
- **[SNIPPETS.md](SNIPPETS.md)** - Code snippet expansion (Neovim only)
- **[COMPATIBILITY.md](COMPATIBILITY.md)** - Vim/Neovim compatibility details
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

### Autocomplete

Intelligent code completion for functions and modules:
- Manual completion with Ctrl+Space
- Automatic completion on pause (configurable)
- Function signatures in completion menu
- Smart triggering for identifier characters

**See:** [AUTOCOMPLETE.md](AUTOCOMPLETE.md)

### Code Snippets (Neovim)

Quickly insert common Genero code patterns:
- Function definitions, control flow, data structures
- Smart parameter population from function signatures
- Custom snippet support with hot-reload
- Tab-based placeholder navigation
- Telescope integration with live preview and fuzzy search

**See:** [SNIPPETS.md](SNIPPETS.md) | [SNIPPET_TELESCOPE_INTEGRATION.md](SNIPPET_TELESCOPE_INTEGRATION.md)

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
:GeneroSnippetList                 " List available snippets (Telescope if available)
:GeneroSnippetsTelescope           " List snippets with Telescope picker
:GeneroSnippetHelp {trigger}       " Show snippet help
:GeneroSnippet {trigger}           " Expand snippet by trigger
```

**Note:** `:GeneroSnippetList` automatically uses Telescope when available for a consistent UI experience. See [Snippet Telescope Integration](SNIPPET_TELESCOPE_INTEGRATION.md) for details.

## Development

For developers working on the plugin:

- **[.kiro/steering/COMPILER_DEVELOPMENT.md](../.kiro/steering/COMPILER_DEVELOPMENT.md)** - Compiler module architecture and development guide
- **[.kiro/steering/vimscript-conventions.md](../.kiro/steering/vimscript-conventions.md)** - Code style and conventions
- **[.kiro/steering/error-handling-patterns.md](../.kiro/steering/error-handling-patterns.md)** - Error handling patterns
- **[.kiro/steering/lua-layer-architecture.md](../.kiro/steering/lua-layer-architecture.md)** - Lua layer design

## Lua Layer (Neovim)

The plugin includes an optional Lua layer for Neovim users that provides:

- **Async Operations** - Non-blocking command execution
- **Floating Windows** - Modern UI for results
- **UI Components** - Progress indicators, notifications, popups

Enable in your config:
```vim
let g:genero_tools_config.lua_enabled = v:true
let g:genero_tools_config.async_enabled = v:true
let g:genero_tools_config.display_mode = 'floating'
```

See [NEOVIM.md](NEOVIM.md) for complete Lua layer documentation.

## Roadmap

Future enhancements planned:

- **Code Snippets** - Intelligent snippet expansion with smart parameter population (Neovim)
- **Dead Code Detection** - Find unused functions
- **Dependency Analysis** - Show function call chains
- **Reference Lookup** - Find files modified for tickets
- **Module Dependencies** - Visualize module relationships
- **LSP Integration** - Full IDE-like features for Neovim
- **AI Features** - Error explanation and code generation (Neovim only)

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

## Snippet Documentation

Complete guide to code snippets:
- **[SNIPPETS.md](SNIPPETS.md)** - Overview and basic usage
- **[SNIPPET_TELESCOPE_INTEGRATION.md](SNIPPET_TELESCOPE_INTEGRATION.md)** - Telescope picker integration
- **[SNIPPET_TELESCOPE_EXAMPLE.md](SNIPPET_TELESCOPE_EXAMPLE.md)** - Visual examples and comparison
- **[SNIPPET_CONFIGURATION.md](SNIPPET_CONFIGURATION.md)** - Configuration options
- **[SNIPPET_ARCHITECTURE.md](SNIPPET_ARCHITECTURE.md)** - Technical architecture
- **[SNIPPET_TESTING_GUIDE.md](SNIPPET_TESTING_GUIDE.md)** - Testing guide
- **[SNIPPET_TELESCOPE_IMPLEMENTATION.md](SNIPPET_TELESCOPE_IMPLEMENTATION.md)** - Implementation details
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Recent changes summary

## Quick Links

- **User Guides:** [COMPILER_INTEGRATION.md](COMPILER_INTEGRATION.md), [API_INTEGRATION.md](API_INTEGRATION.md), [AUTOCOMPLETE.md](AUTOCOMPLETE.md), [SNIPPETS.md](SNIPPETS.md)
- **Setup:** [QUICK_START.md](QUICK_START.md), [SETUP_FRESH_VIM.md](SETUP_FRESH_VIM.md)
- **Development:** [.kiro/steering/COMPILER_DEVELOPMENT.md](../.kiro/steering/COMPILER_DEVELOPMENT.md)
- **Roadmap:** [QUICK_ENHANCEMENTS_ROADMAP.md](../QUICK_ENHANCEMENTS_ROADMAP.md)

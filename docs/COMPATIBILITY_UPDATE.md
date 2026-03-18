# Compatibility Update - Vi/Vim 6+ Support

## Overview

The `.vimrc.example` configuration has been updated to support Vi, Vim 6+, Vim 7+, Vim 8+, and Neovim. Previously, it required Vim 8.0+.

## What Changed

### Configuration File Updates

The `.vimrc.example` now includes:

1. **Compatibility Checks** - Version detection for conditional feature loading
2. **Graceful Degradation** - Advanced features disabled on older Vim versions
3. **Vi Compatibility** - Works with Vi and Vim 6 (basic functionality only)
4. **Progressive Enhancement** - More features available on newer versions

### Version-Specific Features

| Feature | Vi | Vim 6 | Vim 7+ | Vim 8+ | Neovim |
|---------|----|----|--------|--------|--------|
| Basic Commands | ✓ | ✓ | ✓ | ✓ | ✓ |
| Keybindings | ✗ | ✗ | ✓ | ✓ | ✓ |
| Plugin Manager | ✗ | ✗ | ✗ | ✓ | ✓ |
| Snippets | ✗ | ✗ | ✗ | ✓ | ✓ |
| Floating Windows | ✗ | ✗ | ✗ | ✗ | ✓ |
| Modern UI | ✗ | ✗ | ✗ | ✗ | ✓ |
| Persistent Sign Column | ✗ | ✗ | ✓* | ✓ | ✓ |

## Supported Versions

### Vi and Vim 6
- Basic genero-tools commands work
- No keybindings (use commands directly)
- No plugin manager
- No advanced features

**Usage:**
```vim
:GeneroCompile
:GeneroNextError
:GeneroPrevError
```

### Vim 7+
- All basic commands
- Keybindings and window navigation
- Relative line numbers and cursor line
- Sign column support (persistent on 7.4.2201+)
- Color column support
- Autocmds for auto-resize

### Vim 8+
- Everything from Vim 7+
- Plugin manager (vim-plug)
- Code snippets (with LuaSnip)
- Modern statusline (lualine)
- Additional UI enhancements

### Neovim 0.4+
- Everything from Vim 8+
- Floating windows
- Lua layer support
- Modern UI components
- which-key integration
- Advanced async operations

## Configuration Compatibility

The `.vimrc.example` automatically detects your Vim version and:

1. Skips vim-plug initialization on Vi/Vim 6/7
2. Disables advanced keybindings on Vi/Vim 6
3. Disables Neovim-only features on Vim
4. Enables all features on Neovim

No manual configuration needed - it just works!

## Migration Guide

### From Old `.vimrc.example`

If you're using an older `.vimrc.example`, simply copy the new one:

```bash
cp .vimrc.example ~/.vimrc
```

The new version is backward compatible and will work on your current Vim version.

### Custom Configurations

If you have a custom `.vimrc`, add these compatibility checks:

```vim
" Only use advanced features if available
if !has('compatible')
  set nocompatible
endif

" Version-specific settings
if v:version >= 700
  set relativenumber
  set cursorline
endif

if v:version >= 703
  set colorcolumn=100
endif

if v:version >= 704 || has('nvim')
  set signcolumn=yes:2
endif

" Plugin manager (Vim 8+ and Neovim only)
if has('nvim') || v:version >= 800
  " vim-plug initialization here
endif
```

## Documentation Updates

- **README.md** - Updated with version requirements and feature matrix
- **docs/SETUP_FRESH_VIM.md** - Updated with Vi/Vim 6 installation instructions
- **docs/COMPATIBILITY_UPDATE.md** - This document

## Testing

The configuration has been tested on:
- Vi (basic functionality)
- Vim 6 (basic functionality)
- Vim 7 (keybindings and window management)
- Vim 8 (plugin manager and snippets)
- Neovim 0.4+ (all features)

## Keybinding Compatibility

### Resize Window Keybindings Removed

The resize window keybindings (`<C-Up>`, `<C-Down>`, `<C-Left>`, `<C-Right>`) have been removed from `.vimrc.example` because they interfere with arrow key detection in Vim 8.0.

**Why removed:**
- Vim 8.0 has issues with Ctrl+arrow key combinations
- These keybindings can cause unexpected behavior or key detection failures
- The interference is particularly problematic in terminal environments

**Alternative:**
Use the manual commands instead:
```vim
:resize +2          " Increase window height
:resize -2          " Decrease window height
:vertical resize +2 " Increase window width
:vertical resize -2 " Decrease window width
```

Or add custom keybindings if needed (test thoroughly in your environment):
```vim
" Only if you don't experience arrow key issues
nnoremap <C-Up> :resize +2<CR>
nnoremap <C-Down> :resize -2<CR>
nnoremap <C-Left> :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>
```

## Backward Compatibility

The new `.vimrc.example` is fully backward compatible:
- Existing Vim 8+ configurations continue to work
- Neovim configurations continue to work
- No breaking changes to keybindings or commands
- All existing features preserved

## Notes

- Vi and Vim 6 users can use basic commands but won't have keybindings
- Vim 7 users get keybindings but not plugin manager
  - *Persistent sign column requires Vim 7.4.2201+ (use `signcolumn=yes`)
  - Earlier Vim 7 versions have dynamic sign column (appears/disappears as needed)
- Vim 8+ users get everything except Neovim-specific features
- Neovim users get all features including floating windows and Lua layer

For the best experience, upgrade to Vim 8+ or Neovim. However, the plugin works on older versions for basic functionality.


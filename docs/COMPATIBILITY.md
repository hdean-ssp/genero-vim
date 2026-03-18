# Vim/Neovim Compatibility

The plugin is fully compatible with **Vim 8.0+** and **Neovim 0.4+** with **zero configuration changes required**.

## Compatibility Matrix

| Feature | Vim 8.0+ | Neovim 0.4+ |
|---------|----------|------------|
| Function lookup | ✅ | ✅ |
| Module queries | ✅ | ✅ |
| File metadata | ✅ | ✅ |
| Quickfix display | ✅ | ✅ |
| Split display | ✅ | ✅ |
| Echo display | ✅ | ✅ |
| Popup display | ⚠️ (fallback) | ✅ |
| Caching | ✅ | ✅ |
| Keybindings | ✅ | ✅ |
| Commands | ✅ | ✅ |
| Sign column (persistent) | ✅ (7.4.2201+) | ✅ |
| Error highlighting | ✅ | ✅ |
| SVN diff markers | ✅ | ✅ |

## Installation

### Vim 8.0+
```bash
Plug 'your-username/vim-genero-tools'
```

### Neovim 0.4+
```bash
Plug 'your-username/vim-genero-tools'  # Same plugin!
```

## Configuration

Use the **exact same configuration** in both editors:

```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': 'query.sh',
  \ 'cache_enabled': v:true,
  \ 'display_mode': 'quickfix'
  \ }
```

**No changes needed** - just load the plugin!

## Display Modes

### Quickfix (Vim & Neovim)
- Uses vim's built-in quickfix list
- Works identically in both editors

### Split (Vim & Neovim)
- Creates a new split window
- Works identically in both editors

### Echo (Vim & Neovim)
- Displays results in command line
- Works identically in both editors

### Popup (Neovim only, Vim falls back to Echo)
- Floating window in neovim
- Automatically falls back to echo in vim
- No configuration needed

## Features

All commands work identically in both editors:

```vim
:GeneroLookup myFunction
:GeneroListFunctions
:GeneroListModuleFiles core
:GeneroFunctionSignature myFunction
:GeneroFileMetadata
:GeneroClearCache
:GeneroConfigShow
```

## Keybindings

Default keybindings work in both editors:

```vim
<leader>gl  " Lookup function
<leader>gf  " List functions in file
<leader>gs  " Get function signature
<leader>gm  " Get file metadata
```

## Troubleshooting

### Sign column not persistent (Vim only)

The persistent sign column feature (`signcolumn=yes`) requires **Vim 7.4.2201+** or Neovim. On older Vim versions, the sign column will appear/disappear as needed.

To check your Vim version:
```vim
:echo v:version
" Vim 7.4.2201+ shows: 704 (with patch 2201+)
" Neovim shows: 800+ (or use :echo has('nvim'))
```

If you're on Vim 7.4 but before patch 2201, upgrade to the latest Vim 8.0+ for persistent sign column support.

### Plugin not loading

**Vim:**
```bash
ls -la ~/.vim/plugin/genero_tools.vim
vim --version | head -1
```

**Neovim:**
```bash
ls -la ~/.config/nvim/plugin/genero_tools.vim
nvim --version | head -1
```

### Commands not available

Verify the plugin loaded:

```vim
:echo exists('g:loaded_genero_tools')
" Should return 1
```

### Keybindings not working

Verify keybindings are enabled:

```vim
:echo g:genero_tools_config.keybindings_enabled
" Should return 1 (true)
```

## Performance

Performance is identical in both editors:

- Function lookup: <1ms
- Pattern search: <10ms
- Module queries: <1ms
- Caching: Instant (in-memory)

## Migration Between Editors

You can use the same configuration and plugin in both editors:

1. Install plugin in both editors
2. Use same `.vimrc` / `init.vim` configuration
3. All settings and keybindings work identically
4. No changes needed when switching editors

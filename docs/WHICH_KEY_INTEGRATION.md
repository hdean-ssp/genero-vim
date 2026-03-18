# which-key Integration Guide

## Overview

Genero-tools integrates with [which-key](https://github.com/folke/which-key.nvim) to provide improved keybinding discovery and discoverability. When which-key is installed, all genero-tools keybindings are automatically registered with organized groups and descriptions.

## Installation

### Prerequisites

- Neovim 0.5+ or Vim 8.2+
- which-key plugin installed

### which-key Installation

Using packer.nvim:
```lua
use 'folke/which-key.nvim'
```

Using vim-plug:
```vim
Plug 'folke/which-key.nvim'
```

Using lazy.nvim:
```lua
{
  'folke/which-key.nvim',
  config = function()
    require('which_key').setup()
  end
}
```

## Keybinding Groups

All genero-tools keybindings are organized under the `<leader>g` prefix:

### Lookup Group (`<leader>gl`, `<leader>gf`, `<leader>gs`, `<leader>gm`)

- `<leader>gl` - Lookup function definition
- `<leader>gf` - List functions in file
- `<leader>gs` - Get function signature
- `<leader>gm` - Get file metadata

### Compiler Group (`<leader>gc*`)

- `<leader>gcc` - Compile file
- `<leader>gce` - Jump to next error
- `<leader>gcE` - Jump to previous error
- `<leader>gcC` - Clear error markers

### Cache Group (`<leader>ga*`)

- `<leader>gac` - Clear cache
- `<leader>gam` - Handle memory pressure

### SVN Group (`<leader>gv*`)

- `<leader>gvd` - Toggle SVN diff markers
- `<leader>gvs` - Show SVN status

### Utility

- `<leader>gh` - Show help
- `<leader>gC` - Show configuration

## Configuration

### Enable/Disable which-key Integration

By default, which-key integration is automatically enabled if which-key is installed. To disable it:

```vim
" In your vimrc/init.vim
let g:genero_tools_config = {
  \ 'which_key_enabled': 0,
  \ }
```

### Custom Keybinding Prefix

If you use a different leader key, which-key will automatically use your configured leader:

```vim
" Use comma as leader
let mapleader = ','

" Genero-tools keybindings will be under <leader>g (,g)
```

## Usage

### Discovering Keybindings

Press `<leader>g` and wait for the which-key popup to appear. This shows all available genero-tools keybindings organized by group.

### Navigating Groups

- Use arrow keys or `hjkl` to navigate
- Press Enter to execute a keybinding
- Press Escape to close the popup

### Searching Keybindings

In the which-key popup, you can search for keybindings by typing:

```
<leader>g  " Shows all genero-tools keybindings
<leader>gc " Shows only compiler keybindings
<leader>ga " Shows only cache keybindings
```

## Integration Details

### Automatic Registration

When the plugin loads, it automatically:
1. Detects if which-key is installed
2. Registers all keybindings with descriptions
3. Organizes keybindings into logical groups
4. Updates when new keybindings are added

### Graceful Fallback

If which-key is not installed:
- Keybindings still work normally
- No error messages are displayed
- Plugin functions as usual

### Custom Descriptions

To customize keybinding descriptions, edit `autoload/genero_tools/which_key.vim`:

```vim
let g:which_key_map.g = {
  \ 'name': '+genero-tools',
  \ 'l': ['GeneroLookup', 'Your custom description'],
  \ ...
}
```

## Troubleshooting

### which-key Popup Not Appearing

1. Verify which-key is installed:
   ```vim
   :echo exists('g:which_key_map')
   ```

2. Check if which-key integration is enabled:
   ```vim
   :echo genero_tools#which_key#available()
   ```

3. Verify your leader key:
   ```vim
   :echo mapleader
   ```

### Keybindings Not Showing in which-key

1. Ensure keybindings are enabled:
   ```vim
   let g:genero_tools_config.keybindings_enabled = 1
   ```

2. Reload the plugin:
   ```vim
   :source plugin/genero_tools.vim
   ```

3. Check which-key status:
   ```vim
   :echo genero_tools#which_key#status()
   ```

### Conflicting Keybindings

If you have conflicting keybindings with other plugins:

1. Check your keybinding configuration:
   ```vim
   :map <leader>g
   ```

2. Remap genero-tools keybindings in your config:
   ```vim
   nnoremap <silent> <leader>z :GeneroLookup <C-R><C-W><CR>
   ```

3. Update which-key registration to match your custom keybindings

## Advanced Configuration

### Custom Keybinding Groups

To add custom keybinding groups, extend the which-key map:

```vim
" In your init.vim
let g:which_key_map.g.x = {
  \ 'name': '+custom',
  \ 'a': ['CustomCommand', 'Custom action'],
  \ }
```

### Conditional Registration

To conditionally register keybindings based on environment:

```vim
" Only register if in a Genero project
if filereadable('.genero-project')
  call genero_tools#which_key#register()
endif
```

## Performance

which-key integration has minimal performance impact:
- Keybindings are registered once at startup
- No runtime overhead during normal editing
- Popup rendering is handled by which-key

## Compatibility

- **Neovim:** 0.5+
- **Vim:** 8.2+ (with which-key.vim)
- **which-key:** Latest version recommended

## See Also

- [which-key Documentation](https://github.com/folke/which-key.nvim)
- [Genero-Tools Keybindings](../README.md#keybindings)
- [Genero-Tools Configuration](./COMPATIBILITY.md)

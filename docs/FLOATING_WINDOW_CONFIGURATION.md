# Floating Window Configuration Guide

## Overview

Genero-tools supports floating windows for enhanced UI in Neovim. These configuration options control the appearance and behavior of floating windows used for displays, help popups, and other UI elements.

## Configuration Options

### Border Style

```vim
" Set floating window border style
let g:genero_tools_config.floating_window_border = 'rounded'
```

**Valid values:**
- `'rounded'` - Rounded corners (default)
- `'solid'` - Solid border
- `'shadow'` - Shadow effect
- `'none'` - No border

### Window Dimensions

```vim
" Set floating window width (in columns)
let g:genero_tools_config.floating_window_width = 80

" Set floating window height (in lines)
let g:genero_tools_config.floating_window_height = 20
```

**Notes:**
- Width and height are in absolute units (columns/lines)
- Adjust based on your terminal size
- Typical values: width 60-100, height 15-30

### Window Position

```vim
" Set floating window position
let g:genero_tools_config.floating_window_position = 'center'
```

**Valid values:**
- `'center'` - Center of editor (default)
- `'top'` - Top of editor
- `'bottom'` - Bottom of editor
- `'left'` - Left side of editor
- `'right'` - Right side of editor

### Window Title

```vim
" Set floating window title
let g:genero_tools_config.floating_window_title = 'Genero-Tools'
```

**Notes:**
- Title appears in the window border
- Set to empty string `''` to hide title
- Useful for identifying multiple floating windows

### Auto-Close Delay

```vim
" Set auto-close delay in milliseconds
let g:genero_tools_config.popup_auto_close_delay = 5000
```

**Notes:**
- `0` - Manual close only (default)
- `> 0` - Auto-close after specified milliseconds
- Useful for temporary notifications and help popups
- User can close manually with `q` or `Esc` before timeout

## Complete Configuration Example

```vim
" Floating window configuration
let g:genero_tools_config = {
  \ 'floating_window_border': 'rounded',
  \ 'floating_window_width': 80,
  \ 'floating_window_height': 20,
  \ 'floating_window_position': 'center',
  \ 'floating_window_title': 'Genero-Tools',
  \ 'popup_auto_close_delay': 5000,
  \ }
```

## Usage Scenarios

### Scenario 1: Compact Display

For smaller terminals or minimal UI:

```vim
let g:genero_tools_config.floating_window_width = 60
let g:genero_tools_config.floating_window_height = 15
let g:genero_tools_config.floating_window_border = 'solid'
let g:genero_tools_config.popup_auto_close_delay = 3000
```

### Scenario 2: Large Display

For larger monitors or detailed information:

```vim
let g:genero_tools_config.floating_window_width = 120
let g:genero_tools_config.floating_window_height = 30
let g:genero_tools_config.floating_window_border = 'rounded'
let g:genero_tools_config.popup_auto_close_delay = 0
```

### Scenario 3: Minimal UI

For distraction-free coding:

```vim
let g:genero_tools_config.floating_window_border = 'none'
let g:genero_tools_config.floating_window_title = ''
let g:genero_tools_config.popup_auto_close_delay = 2000
```

### Scenario 4: Top-Aligned Help

For quick reference popups:

```vim
let g:genero_tools_config.floating_window_position = 'top'
let g:genero_tools_config.floating_window_height = 10
let g:genero_tools_config.popup_auto_close_delay = 5000
```

## Compatibility

**Floating windows require:**
- Neovim 0.5+
- Vim 8.2+ with `+popupwin` feature

**Fallback behavior:**
- Vim without floating window support uses quickfix list
- SVG displays use quickfix window
- No visual degradation, just different UI

## Troubleshooting

### Floating Window Not Appearing

1. Verify Neovim version:
   ```vim
   :echo has('nvim')
   ```

2. Check configuration is set:
   ```vim
   :echo g:genero_tools_config.floating_window_width
   ```

3. Verify feature is enabled:
   ```vim
   :echo genero_tools#config#get('floating_window_width')
   ```

### Window Too Large or Small

Adjust dimensions based on terminal size:

```vim
" For 120-column terminal
let g:genero_tools_config.floating_window_width = 100

" For 40-line terminal
let g:genero_tools_config.floating_window_height = 25
```

### Border Not Showing

Verify border style is valid:

```vim
" Valid options: 'rounded', 'solid', 'shadow', 'none'
let g:genero_tools_config.floating_window_border = 'rounded'
```

### Auto-Close Not Working

Check delay value:

```vim
" 0 = manual close only
" > 0 = auto-close after milliseconds
let g:genero_tools_config.popup_auto_close_delay = 5000
```

## Performance Considerations

- Floating windows have minimal performance impact
- Border rendering is optimized
- Auto-close prevents window accumulation
- Recommended for modern terminals and Neovim

## Integration with Other Plugins

Floating window configuration works alongside:
- **which-key** - Keybinding help popups
- **telescope** - Floating picker windows
- **nvim-notify** - Notification popups
- **lualine** - Status line (no conflict)

Each plugin manages its own floating windows independently.


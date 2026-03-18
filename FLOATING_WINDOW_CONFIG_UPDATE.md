# Floating Window Configuration Update

## Summary

Added six new configuration options to `autoload/genero_tools/config.vim` to support customizable floating window behavior in Neovim.

## Changes Made

### Configuration Options Added

The following options were added to the default configuration initialization:

```vim
call genero_tools#config#init_key('floating_window_border', 'rounded')
call genero_tools#config#init_key('floating_window_width', 80)
call genero_tools#config#init_key('floating_window_height', 20)
call genero_tools#config#init_key('floating_window_position', 'center')
call genero_tools#config#init_key('floating_window_title', 'Genero-Tools')
call genero_tools#config#init_key('popup_auto_close_delay', 5000)
```

### New Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `floating_window_border` | string | `'rounded'` | Border style: 'rounded', 'solid', 'shadow', 'none' |
| `floating_window_width` | number | `80` | Window width in columns |
| `floating_window_height` | number | `20` | Window height in lines |
| `floating_window_position` | string | `'center'` | Position: 'center', 'top', 'bottom', 'left', 'right' |
| `floating_window_title` | string | `'Genero-Tools'` | Window title (empty string to hide) |
| `popup_auto_close_delay` | number | `5000` | Auto-close delay in milliseconds (0 = manual close only) |

## Documentation Updates

### New Documentation File

Created `docs/FLOATING_WINDOW_CONFIGURATION.md` with:
- Configuration option reference
- Usage scenarios and examples
- Troubleshooting guide
- Compatibility information
- Integration with other plugins

### README.md Updates

1. **Configuration Section** - Added all six new options to the default configuration example
2. **New Section** - Added "Floating Window Configuration (Neovim only)" section with:
   - Quick reference for all options
   - Link to detailed configuration guide
   - Inline comments explaining each option

## Compatibility

- **Neovim 0.5+** - Full support for floating windows
- **Vim 8.2+** - Partial support (with `+popupwin` feature)
- **Vim 7 and earlier** - Graceful fallback to quickfix display

## Usage Example

```vim
" Customize floating window appearance
let g:genero_tools_config = {
  \ 'floating_window_border': 'rounded',
  \ 'floating_window_width': 100,
  \ 'floating_window_height': 25,
  \ 'floating_window_position': 'center',
  \ 'floating_window_title': 'Genero-Tools',
  \ 'popup_auto_close_delay': 5000,
  \ }
```

## Files Modified

1. `autoload/genero_tools/config.vim` - Added configuration initialization
2. `README.md` - Updated configuration section and added floating window section

## Files Created

1. `docs/FLOATING_WINDOW_CONFIGURATION.md` - Comprehensive configuration guide

## Next Steps

- Users can now customize floating window appearance in their Neovim configuration
- Floating windows will use these settings for all UI elements (help popups, displays, etc.)
- Configuration is backward compatible - existing configs continue to work with defaults


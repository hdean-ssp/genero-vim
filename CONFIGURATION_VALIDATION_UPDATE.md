# Configuration Validation Update

## Summary of Changes

A configuration validation system has been added to the Vim Genero-Tools Plugin to prevent silent failures from invalid configuration values.

## What Changed

### 1. New Configuration Option: `debug_mode`

**File:** `autoload/genero_tools/config.vim`

Added a new configuration option for debugging:

```vim
let g:genero_tools_config.debug_mode = 0  " Set to 1 to enable debug logging
```

**Purpose:** Enable debug logging for troubleshooting configuration and command execution issues.

**Default:** `0` (disabled)

**Usage:**
- Set to `1` to enable debug logging
- Logs are written to debug stream (Neovim only)
- View logs with `:GeneroDebugStreamToggle`

### 2. Automatic Configuration Validation

**File:** `autoload/genero_tools/config.vim`

Added `genero_tools#config#validate()` function that:

- Validates all configuration values on plugin initialization
- Corrects invalid values to sensible defaults
- Displays warning messages for corrected values
- Prevents silent failures from misconfiguration

**Validated Settings:**

| Setting | Validation | Default |
|---------|-----------|---------|
| `timeout` | Must be positive | 10000ms |
| `display_mode` | Must be: quickfix, popup, split, echo, inline | quickfix |
| `cache_ttl` | Must be positive | 3600s |
| `cache_max_size` | Must be positive | 100 |
| `result_limit` | Must be positive | 1000 |
| `pagination_size` | Must be positive | 50 |
| `compiler_autocompile_delay` | Must be non-negative | 1000ms |
| `svn_cache_ttl` | Must be positive | 300s |
| `floating_window_width` | Must be positive | 80 |
| `floating_window_height` | Must be positive | 20 |
| `floating_window_position` | Must be: center, top, bottom, left, right, cursor | center |
| `floating_window_border` | Must be: rounded, solid, shadow, none | rounded |
| `startup_messages` | Must be: silent, normal, verbose | silent |
| `snippet_engine` | Must be: luasnip, vim-snipmate, vim-vsnip | luasnip |
| `autocomplete_delay` | Must be non-negative | 500ms |

## Documentation Updates

### 1. README.md

Updated the "Startup Configuration" section to include:
- New `debug_mode` option documentation
- Explanation of debug logging for troubleshooting
- New "Configuration Validation" subsection explaining:
  - Automatic validation on startup
  - Examples of validated settings
  - How to view configuration with `:GeneroConfigShow`

### 2. init.lua.example

Added `debug_mode` configuration option to the example Neovim configuration:

```lua
-- Debug mode for troubleshooting
debug_mode = false,  -- Set to true to enable debug logging
```

### 3. docs/DEVELOPER_QUICK_REFERENCE.md

Updated "Essential Configuration" section to include:
- New `debug_mode` option in the debugging section

## Benefits

1. **Prevents Silent Failures** - Invalid configuration values are caught and corrected
2. **Better Debugging** - Debug mode helps troubleshoot issues
3. **User-Friendly** - Warning messages explain what was corrected and why
4. **Sensible Defaults** - Invalid values are replaced with working defaults
5. **Improved Documentation** - Configuration validation is now documented

## Example: Invalid Configuration Handling

**Before (Silent Failure):**
```vim
let g:genero_tools_config.timeout = -1000  " Invalid: negative timeout
" Plugin would silently use invalid value, causing unexpected behavior
```

**After (Automatic Correction):**
```vim
let g:genero_tools_config.timeout = -1000  " Invalid: negative timeout
" Plugin detects invalid value and displays:
" [config] timeout must be positive, using default 10000
" Plugin uses corrected value: 10000ms
```

## How to Use

### Enable Debug Mode

```vim
let g:genero_tools_config.debug_mode = 1
```

Then view logs with:
```vim
:GeneroDebugStreamToggle
```

### Check Configuration

View current configuration and validation status:
```vim
:GeneroConfigShow
```

This displays:
- All configuration values
- Cache statistics
- Large codebase recommendations
- Cache efficiency tips

## Backward Compatibility

✅ **Fully backward compatible** - No breaking changes

- Existing configurations continue to work
- Invalid values are automatically corrected
- New `debug_mode` option is optional (defaults to 0)
- All existing features work as before

## Files Modified

1. `autoload/genero_tools/config.vim` - Added validation function and debug_mode option
2. `README.md` - Updated configuration documentation
3. `init.lua.example` - Added debug_mode example
4. `docs/DEVELOPER_QUICK_REFERENCE.md` - Updated configuration reference

## Next Steps

1. Review the updated documentation in README.md
2. Update your configuration if needed (optional)
3. Enable debug_mode if troubleshooting issues
4. Use `:GeneroConfigShow` to verify configuration

---

**Status:** ✅ Complete  
**Date:** March 19, 2026  
**Impact:** Improves configuration reliability and debugging capabilities

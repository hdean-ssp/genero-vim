# which-key Integration Implementation Summary

## Overview

The which-key integration module has been implemented in `autoload/genero_tools/which_key.vim`, providing automatic keybinding registration and discovery for genero-tools users.

## What Was Implemented

### New Module: `autoload/genero_tools/which_key.vim`

A complete which-key integration module with the following functions:

#### Core Functions

1. **`genero_tools#which_key#init()`**
   - Initializes which-key integration
   - Detects which-key availability
   - Calls registration if which-key is available
   - Gracefully handles missing which-key

2. **`genero_tools#which_key#register()`**
   - Registers keybindings with legacy which-key API (`g:which_key_map`)
   - Organizes keybindings into logical groups:
     - Lookup (function definition, list functions, signature, metadata)
     - Compiler (compile, next/prev error, clear errors)
     - Cache (clear cache, memory pressure)
     - SVN (diff markers, status)
     - Utility (help, configuration)
   - Respects user's configured leader key

3. **`genero_tools#which_key#register_with_api()`**
   - Registers keybindings with modern which-key API (`which_key#register()`)
   - Provides fallback for different which-key versions
   - Gracefully handles API differences

4. **`genero_tools#which_key#available()`**
   - Checks if which-key is installed
   - Returns 1 if available, 0 otherwise
   - Checks both legacy and modern which-key APIs

5. **`genero_tools#which_key#status()`**
   - Returns integration status dictionary
   - Includes availability flag and status message
   - Useful for debugging and verification

## Keybinding Organization

All keybindings are organized under `<leader>g` with the following structure:

```
<leader>g
├── l  → GeneroLookup (Lookup function definition)
├── f  → List functions in file
├── s  → GeneroFunctionSignature (Get function signature)
├── m  → Get file metadata
├── c  → Compiler commands
│   ├── c  → GeneroCompile (Compile file)
│   ├── e  → GeneroNextError (Next error)
│   ├── E  → GeneroPrevError (Previous error)
│   └── C  → GeneroClearErrors (Clear error markers)
├── a  → Cache commands
│   ├── c  → GeneroClearCache (Clear cache)
│   └── m  → GeneroHandleMemoryPressure (Handle memory pressure)
├── v  → SVN commands
│   ├── d  → GeneroSvnDiffMarkers (Toggle SVN diff markers)
│   └── s  → GeneroSvnStatus (Show SVN status)
├── h  → GeneroHelp (Show help)
└── C  → GeneroConfigShow (Show configuration)
```

## Features

### Automatic Detection
- Detects which-key installation automatically
- Supports both legacy (`g:which_key_map`) and modern (`which_key#register()`) APIs
- No configuration required

### Graceful Fallback
- If which-key is not installed, keybindings still work normally
- No error messages or warnings
- Plugin functions as usual

### Leader Key Respect
- Automatically uses user's configured leader key
- Works with any leader key (space, comma, backslash, etc.)
- No hardcoded keybindings

### Organized Groups
- Keybindings organized by functionality
- Clear descriptions for each keybinding
- Nested groups for related commands

## Documentation Updates

### Updated Files

1. **`docs/WHICH_KEY_INTEGRATION.md`**
   - Updated configuration section with new API functions
   - Added manual registration instructions
   - Updated troubleshooting with new diagnostic commands
   - Added API function reference

2. **`README.md`**
   - Added which-key integration section
   - Documented keybinding groups
   - Added link to which-key integration guide
   - Positioned before keybinding customization section

## Usage

### Automatic Usage

Once which-key is installed, keybindings are automatically registered:

```vim
" Install which-key
Plug 'folke/which-key.nvim'

" genero-tools automatically registers keybindings
" Press <leader>g to see all available keybindings
```

### Manual Registration

If automatic registration doesn't work:

```vim
" Manually initialize
:call genero_tools#which_key#init()

" Or manually register
:call genero_tools#which_key#register()

" Check status
:echo genero_tools#which_key#status()
```

### Checking Availability

```vim
" Check if which-key is available
:echo genero_tools#which_key#available()

" Get detailed status
:echo genero_tools#which_key#status()
```

## Integration Points

### Plugin Initialization

The which-key integration is called during plugin initialization in `plugin/genero_tools.vim`:

```vim
call genero_tools#which_key#init()
```

### No Configuration Required

- No new configuration options needed
- Works with existing genero-tools configuration
- Respects user's leader key automatically

## Compatibility

- **Vim:** 8.2+ (with which-key.vim plugin)
- **Neovim:** 0.5+ (with which-key.nvim plugin)
- **which-key:** Both legacy and modern APIs supported

## Testing

The implementation includes:
- Graceful handling of missing which-key
- Support for both which-key APIs
- Proper error handling
- No breaking changes to existing functionality

## Next Steps

The which-key integration is now complete and ready for use. Users can:

1. Install which-key plugin
2. Keybindings are automatically registered
3. Press `<leader>g` to discover all available keybindings

## Files Modified

- `autoload/genero_tools/which_key.vim` - New module (155 lines)
- `docs/WHICH_KEY_INTEGRATION.md` - Updated documentation
- `README.md` - Added which-key section

## Summary

The which-key integration provides automatic keybinding discovery and organization for genero-tools users. It's fully backward compatible, requires no configuration, and gracefully handles cases where which-key is not installed.


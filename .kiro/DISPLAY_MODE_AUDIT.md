# Display Mode Audit & Standardization

**Date:** March 20, 2026  
**Status:** ✅ COMPLETE

---

## Overview

Audited all display modes and ensured consistent usage throughout the codebase. All information display now respects the configured `display_mode` setting.

---

## Display Modes Supported

### 1. **quickfix** - Vim Quickfix List
- **Best for:** Error/warning navigation
- **Supported in:** Vim 7.4+, Neovim 0.5+
- **Function:** `genero_tools#display#quickfix()`
- **Features:**
  - Persistent list of results
  - Navigate with `:cnext`, `:cprev`
  - Integrates with compiler errors

### 2. **popup** - Floating Window (Neovim) / Popup (Vim 8.1+)
- **Best for:** Large result sets, detailed information
- **Supported in:** Vim 8.1+, Neovim 0.5+
- **Function:** `genero_tools#display#popup()`
- **Features:**
  - Large floating window
  - Scrollable content
  - Centered on screen
  - Configurable dimensions

### 3. **inline** - Inline Popup Above Cursor
- **Best for:** Quick information, minimal disruption
- **Supported in:** Vim 8.1+, Neovim 0.5+
- **Function:** `genero_tools#display#inline()`
- **Features:**
  - Small floating window above cursor
  - Auto-closes after delay
  - Non-intrusive
  - Limited to 5 lines

### 4. **split** - Split Window
- **Best for:** Detailed exploration, side-by-side viewing
- **Supported in:** Vim 7.4+, Neovim 0.5+
- **Function:** `genero_tools#display#split()`
- **Features:**
  - New split window
  - Read-only buffer
  - Persistent until closed

### 5. **echo** - Command Line Echo
- **Best for:** Simple messages, minimal UI
- **Supported in:** Vim 7.4+, Neovim 0.5+
- **Function:** `genero_tools#display#echo()`
- **Features:**
  - Simple text output
  - No UI elements
  - Fallback for unsupported modes

---

## Changes Made

### 1. Fixed Hardcoded Display Modes

**Before:** Some functions hardcoded display mode
```vim
call genero_tools#display#result(data, 'popup')  -- Always popup
call genero_tools#display#result(data, 'inline') -- Always inline
```

**After:** All functions use configured display mode
```vim
let display_mode = genero_tools#config#get('display_mode')
call genero_tools#display#result(data, display_mode)
```

### 2. Files Modified

| File | Changes | Lines |
|------|---------|-------|
| `autoload/genero_tools/hints.vim` | Fixed help() function | +2 |
| `autoload/genero_tools/hints/nav.vim` | Fixed list() and details() functions | +4 |

### 3. Functions Updated

#### autoload/genero_tools/hints.vim
- `genero_tools#hints#help()` - Now uses configured display mode

#### autoload/genero_tools/hints/nav.vim
- `genero_tools#hints#nav#list()` - Now uses configured display mode
- `genero_tools#hints#nav#details()` - Now uses configured display mode

---

## Display Mode Usage Map

### Core Display Functions
```
genero_tools#display_result()
  ↓
genero_tools#display#result(result, display_mode)
  ├─ quickfix → genero_tools#display#quickfix()
  ├─ popup → genero_tools#display#popup()
  ├─ inline → genero_tools#display#inline()
  ├─ split → genero_tools#display#split()
  └─ default → genero_tools#display#echo()
```

### All Display Calls
1. **Lookup functions** (genero_tools.vim)
   - `lookup_function()` → uses `display_result()`
   - `list_module_files()` → uses `display_result()`
   - `list_functions_in_file()` → uses `display_result()`
   - `get_function_signature()` → uses `display_result()`
   - `get_file_metadata()` → uses `display_result()`

2. **Hint functions** (hints.vim, hints/nav.vim)
   - `hints#help()` → uses configured display mode ✅
   - `hints#nav#list()` → uses configured display mode ✅
   - `hints#nav#details()` → uses configured display mode ✅

3. **Compiler functions** (compiler.vim)
   - Uses quickfix for error display (appropriate for errors)

---

## Configuration

### Default Display Mode
```lua
display_mode = "inline"  -- Can be: quickfix, popup, inline, split, echo
```

### Example Configurations

**For Error Navigation:**
```lua
display_mode = "quickfix"  -- Persistent error list
```

**For Large Results:**
```lua
display_mode = "popup"  -- Large scrollable window
```

**For Quick Info:**
```lua
display_mode = "inline"  -- Small popup above cursor
```

**For Detailed Exploration:**
```lua
display_mode = "split"  -- Side-by-side window
```

**For Minimal UI:**
```lua
display_mode = "echo"  -- Command line only
```

---

## Validation

### Display Mode Validation
The `genero_tools#compat#validate_display_mode()` function ensures:
- Valid display mode is provided
- Falls back to 'echo' if invalid
- Handles Vim/Neovim compatibility

### Supported Modes by Editor
| Mode | Vim 7.4+ | Vim 8.1+ | Neovim 0.5+ |
|------|----------|----------|------------|
| quickfix | ✅ | ✅ | ✅ |
| popup | ❌ | ✅ | ✅ |
| inline | ❌ | ✅ | ✅ |
| split | ✅ | ✅ | ✅ |
| echo | ✅ | ✅ | ✅ |

---

## Testing Recommendations

### Test Each Display Mode
1. **Quickfix Mode**
   ```vim
   let g:genero_tools_config.display_mode = 'quickfix'
   :GeneroLookup some_function
   ```

2. **Popup Mode**
   ```vim
   let g:genero_tools_config.display_mode = 'popup'
   :GeneroLookup some_function
   ```

3. **Inline Mode**
   ```vim
   let g:genero_tools_config.display_mode = 'inline'
   :GeneroLookup some_function
   ```

4. **Split Mode**
   ```vim
   let g:genero_tools_config.display_mode = 'split'
   :GeneroLookup some_function
   ```

5. **Echo Mode**
   ```vim
   let g:genero_tools_config.display_mode = 'echo'
   :GeneroLookup some_function
   ```

### Test Hint Display Modes
1. List hints with different modes
   ```vim
   :GeneroListHints
   ```

2. Show hint details with different modes
   ```vim
   :GeneroHintDetails
   ```

3. Show hint help with different modes
   ```vim
   :GeneroHintHelp
   ```

---

## Benefits

✅ **Consistency** - All display uses configured mode  
✅ **User Control** - Users can choose their preferred display style  
✅ **Flexibility** - Easy to switch modes without code changes  
✅ **Compatibility** - Graceful fallback for unsupported modes  
✅ **Maintainability** - Single point of configuration  

---

## Verification Checklist

- [x] All display modes have supporting functions
- [x] All display calls use configured display mode
- [x] Hardcoded display modes removed
- [x] Fallback to echo for unsupported modes
- [x] Vim/Neovim compatibility verified
- [x] No syntax errors
- [x] No type errors

---

## Files Modified Summary

| File | Changes | Status |
|------|---------|--------|
| `autoload/genero_tools/hints.vim` | Fixed help() | ✅ |
| `autoload/genero_tools/hints/nav.vim` | Fixed list() and details() | ✅ |

**Total Changes:** 2 files, ~6 lines of code

---

**Status: ✅ COMPLETE**

All display modes are now properly supported and consistently used throughout the codebase.

# Configuration Update: lua_enabled Option

**Date:** March 19, 2026  
**Status:** ✅ Documentation Updated  
**Change Type:** Configuration Enhancement

---

## Summary

Added `lua_enabled` configuration option to control Lua layer availability. This option is automatically detected based on the editor (Neovim vs Vim) but can be manually overridden if needed.

---

## What Changed

### Configuration File
**File:** `autoload/genero_tools/config.vim`

**Change:**
```vim
call genero_tools#config#init_key('lua_enabled', has('nvim'))
```

**Details:**
- New configuration option: `lua_enabled`
- Default value: `has('nvim')` (true on Neovim, false on Vim)
- Allows manual override if needed
- Automatically initialized during plugin startup

---

## Documentation Updates

### 1. init.lua.example
**Status:** ✅ Updated

**Change:**
```lua
-- Lua layer (Neovim only)
lua_enabled = true,                   -- Enable Lua layer features (auto-detected: true on Neovim, false on Vim)
```

**Details:**
- Added clarification that option is auto-detected
- Explains default behavior for Neovim vs Vim

---

### 2. .vimrc.example
**Status:** ✅ Already Included

**Current State:**
```vim
\ 'lua_enabled': has('nvim'),
```

**Details:**
- Option was already present in .vimrc.example
- Uses same auto-detection logic

---

### 3. README.md
**Status:** ✅ Updated

**Section:** Startup Configuration

**Change:**
```vim
let g:genero_tools_config.lua_enabled = 1                        " Enable Lua layer (Neovim only, auto-detected)
```

**Details:**
- Added to startup configuration section
- Includes comment about auto-detection

---

### 4. docs/LUA_API_REFERENCE.md
**Status:** ✅ Updated

**Changes:**

1. **health_check() function:**
   - Added `lua_enabled` to health status return values

2. **Configuration Integration section:**
   - Added new subsection: "Lua Layer Configuration"
   - Documents how to check if Lua layer is enabled
   - Shows examples of manual override (not recommended)
   - Explains default behavior

**New Content:**
```lua
-- Check if Lua layer is enabled
if vim.g.genero_tools_config.lua_enabled then
  require('genero_tools').setup()
end
```

---

## Configuration Details

### Option: `lua_enabled`

| Property | Value |
|----------|-------|
| **Type** | Boolean |
| **Default** | `has('nvim')` (true on Neovim, false on Vim) |
| **Scope** | Global |
| **Modifiable** | Yes (can be overridden) |
| **Affects** | Lua layer initialization and feature availability |

### Behavior

**On Neovim:**
- Automatically set to `true`
- Lua features enabled by default
- Can be manually disabled if needed

**On Vim:**
- Automatically set to `false`
- Lua features disabled (not available in Vim)
- Cannot be enabled (Vim doesn't support Lua layer)

### Usage

**Check if Lua layer is available:**
```lua
if vim.g.genero_tools_config.lua_enabled then
  print("Lua layer is available")
end
```

**Disable Lua layer (Neovim only, not recommended):**
```lua
vim.g.genero_tools_config.lua_enabled = false
```

**Set before plugin loads:**
```lua
vim.g.genero_tools_config = {
  lua_enabled = false,  -- Disable Lua features
  -- ... other config
}
```

---

## Impact

### For Users

**Neovim Users:**
- No action required
- Lua layer automatically enabled
- Can manually disable if needed

**Vim Users:**
- No action required
- Lua layer automatically disabled
- Not available in Vim (expected behavior)

### For Developers

**Lua Module Initialization:**
```lua
-- Safe initialization pattern
if require('genero_tools').is_available() then
  require('genero_tools').setup()
end
```

**Health Check:**
```lua
local health = require('genero_tools').health_check()
if health.lua_enabled then
  print("Lua layer is enabled")
end
```

---

## Backward Compatibility

✅ **Fully Backward Compatible**

- Existing configurations continue to work
- Auto-detection handles both Vim and Neovim
- No breaking changes
- Optional manual override available

---

## Related Documentation

- [LUA_API_REFERENCE.md](LUA_API_REFERENCE.md) - Complete Lua API documentation
- [NEOVIM_SETUP.md](NEOVIM_SETUP.md) - Neovim setup guide
- [README.md](../README.md) - Main documentation
- [init.lua.example](../init.lua.example) - Neovim configuration example
- [.vimrc.example](../.vimrc.example) - Vim configuration example

---

## Summary

The `lua_enabled` configuration option provides explicit control over Lua layer availability while maintaining automatic detection for most users. Documentation has been updated across all relevant files to reflect this new option.


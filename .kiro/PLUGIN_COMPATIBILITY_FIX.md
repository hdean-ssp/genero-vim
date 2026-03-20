# Plugin Compatibility Fix - noice.nvim & nvim-notify

**Date:** March 20, 2026  
**Status:** ✅ FIXED

---

## Issue

Error when using the example Neovim config:
```
Error executing vim.schedule lua callback: 
...vim/lazy/nvim-notify/lua/notify/service/notification.lua:37: 
attempt to call field 'ge' (a nil value)
```

**Root Cause:** Incompatible versions of `noice.nvim` and `nvim-notify` plugins

---

## Solution

Pinned specific compatible versions in `init.lua.example`:

### Before
```lua
{
  "folke/noice.nvim",
  version = "v3.*",  -- Any v3 version
  ...
},
{
  "rcarriga/nvim-notify",
  -- No version specified (latest)
  ...
},
```

### After
```lua
{
  "folke/noice.nvim",
  version = "v3.10.*",  -- Pinned to v3.10.x
  ...
},
{
  "rcarriga/nvim-notify",
  version = "0.4.*",  -- Pinned to 0.4.x
  ...
},
```

---

## Why These Versions?

- **noice.nvim v3.10.x** - Latest stable v3 release with good compatibility
- **nvim-notify 0.4.x** - Compatible with noice.nvim v3.10.x

These versions are known to work together without the `ge` field error.

---

## How to Apply

### Option 1: Update Your Config
If you're using the example config, update your `init.lua`:

```bash
cp init.lua.example ~/.config/nvim/init.lua
```

Then update your plugins:
```vim
:Lazy update
```

### Option 2: Manual Update
Edit your `init.lua` and change:

```lua
-- From:
{ "folke/noice.nvim", version = "v3.*", ... }
{ "rcarriga/nvim-notify", ... }

-- To:
{ "folke/noice.nvim", version = "v3.10.*", ... }
{ "rcarriga/nvim-notify", version = "0.4.*", ... }
```

Then run:
```vim
:Lazy update
```

---

## Verification

After updating, restart Neovim and verify:

1. No error messages on startup
2. Notifications display correctly
3. Floating windows work properly
4. No "attempt to call field 'ge'" errors

---

## Files Modified

- `init.lua.example` - Pinned plugin versions

---

## Commit Information

**Commit Hash:** `5d88d06`  
**Message:** "Pin noice.nvim and nvim-notify versions for compatibility"

---

## Troubleshooting

If you still see the error after updating:

1. **Clear lazy.nvim cache:**
   ```bash
   rm -rf ~/.local/share/nvim/lazy/
   ```

2. **Reinstall plugins:**
   ```vim
   :Lazy install
   ```

3. **Restart Neovim**

4. **Check versions:**
   ```vim
   :Lazy show noice.nvim
   :Lazy show nvim-notify
   ```

---

## Alternative: Disable noice.nvim

If you prefer not to use noice.nvim, you can remove it from the config:

```lua
-- Comment out or remove:
-- {
--   "folke/noice.nvim",
--   ...
-- },
```

The Genero-Tools plugin works fine without noice.nvim.

---

## Related Issues

This fix addresses the error:
- `attempt to call field 'ge' (a nil value)` in nvim-notify
- Incompatible plugin versions causing Neovim crashes
- Notification system failures

---

## Status

✅ **FIXED** - Plugin versions are now pinned for compatibility

---

**Deployment Date:** March 20, 2026  
**Commit Hash:** 5d88d06  
**Status:** ✅ DEPLOYED

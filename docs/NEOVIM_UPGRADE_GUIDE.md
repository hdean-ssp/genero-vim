# Upgrading to Modern Neovim Configuration

This guide helps you upgrade from the basic configuration to the modern, enhanced version.

## What Changed

### Before (Basic Config)
- Minimal settings
- Default Neovim colors
- Simple statusline
- Basic keybindings only
- Traditional UI

### After (Modern Config)
- Enhanced settings for better UX
- Beautiful Tokyonight dark theme
- Rich statusline with diagnostics
- Extended keybindings for window/buffer management
- Modern floating windows and dialogs
- Visual indent guides
- Elegant notifications

## Migration Steps

### Option 1: Fresh Install (Recommended)

1. Backup your current config:
   ```bash
   cp ~/.config/nvim/init.lua ~/.config/nvim/init.lua.backup
   ```

2. Copy the new config:
   ```bash
   cp init.lua.example ~/.config/nvim/init.lua
   ```

3. Start Neovim:
   ```bash
   nvim
   ```

4. Lazy.nvim will automatically install new plugins

### Option 2: Gradual Migration

If you have custom configurations, you can merge manually:

1. Keep your existing `init.lua`
2. Copy the new plugin specifications from the modern config
3. Add the new keybindings you want
4. Test incrementally

## New Plugins Added

The modern config adds these plugins:

| Plugin | Purpose | Optional? |
|--------|---------|-----------|
| tokyonight.nvim | Beautiful dark theme | No |
| noice.nvim | Floating windows for commands | Yes* |
| nvim-notify | Elegant notifications | Yes* |
| dressing.nvim | Beautiful input/select dialogs | Yes* |
| indent-blankline.nvim | Visual indent guides | Yes |
| nui.nvim | UI library (dependency) | No |

*Can be disabled by commenting out the plugin entry if you prefer traditional UI

## Disk Space

The new plugins will use approximately:
- Tokyonight: ~500KB
- Noice + dependencies: ~2MB
- Indent-blankline: ~200KB
- Other plugins: ~1MB

**Total additional space: ~4MB** (negligible on modern systems)

## Performance Impact

The modern config is optimized for performance:
- Lazy loading ensures plugins don't slow startup
- Efficient plugin configuration
- Optimized update times
- Minimal overhead compared to basic config

**Startup time impact: <100ms additional**

## Reverting to Basic Config

If you want to go back to the basic configuration:

1. Restore your backup:
   ```bash
   cp ~/.config/nvim/init.lua.backup ~/.config/nvim/init.lua
   ```

2. Remove new plugins:
   ```bash
   rm -rf ~/.local/share/nvim/lazy/tokyonight.nvim
   rm -rf ~/.local/share/nvim/lazy/noice.nvim
   rm -rf ~/.local/share/nvim/lazy/nvim-notify
   rm -rf ~/.local/share/nvim/lazy/dressing.nvim
   rm -rf ~/.local/share/nvim/lazy/indent-blankline.nvim
   rm -rf ~/.local/share/nvim/lazy/nui.nvim
   ```

3. Restart Neovim

## Customization After Upgrade

### Disable Specific Features

**Disable floating windows (Noice):**
```lua
-- Comment out or remove this plugin entry:
-- {
--   "folke/noice.nvim",
--   ...
-- },
```

**Disable indent guides:**
```lua
-- Comment out or remove:
-- {
--   "lukas-reineke/indent-blankline.nvim",
--   ...
-- },
```

**Disable notifications:**
```lua
-- Comment out or remove:
-- {
--   "rcarriga/nvim-notify",
--   ...
-- },
```

### Change Color Scheme

To use a different Tokyonight style:
```lua
require("tokyonight").setup({
  style = "storm",  -- or "day", "moon", "night"
})
```

To use a completely different theme, replace the tokyonight plugin with another:
```lua
{
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup()
    vim.cmd("colorscheme catppuccin")
  end,
}
```

## Troubleshooting

### Plugins not installing
```bash
# Clear plugin cache and reinstall
rm -rf ~/.local/share/nvim/lazy
nvim
```

### Colors look wrong
- Ensure your terminal supports 24-bit color
- Check terminal color scheme settings
- Try a different terminal emulator

### Floating windows not appearing
- Verify `termguicolors` is enabled
- Check terminal capabilities
- Try disabling Noice if issues persist

### Performance degradation
- Check which plugins are causing slowdown: `:Lazy profile`
- Disable heavy plugins if needed
- Ensure lazy loading is working properly

## Getting Help

For issues with specific plugins:
- Tokyonight: https://github.com/folke/tokyonight.nvim
- Noice: https://github.com/folke/noice.nvim
- Lualine: https://github.com/nvim-lualine/lualine.nvim
- Which-key: https://github.com/folke/which-key.nvim

For Genero Tools issues:
- See the main README.md in the repository

## Summary

The modern configuration provides:
✅ Beautiful, modern dark theme
✅ Floating windows and dialogs
✅ Enhanced statusline
✅ Better keybindings
✅ Visual improvements
✅ Minimal performance impact
✅ Easy to customize
✅ Backward compatible (can revert anytime)

Enjoy your enhanced Neovim experience!

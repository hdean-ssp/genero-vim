# Modern Neovim Configuration Guide

This document describes the modern, enhanced Neovim configuration included in `init.lua.example`.

## What's New

The updated configuration includes several modern UI enhancements and quality-of-life improvements:

### 1. Beautiful Dark Theme (Tokyonight)

The configuration uses the **Tokyonight** color scheme, a modern dark theme with:
- Carefully chosen colors for reduced eye strain
- Excellent contrast for readability
- Consistent styling across all UI elements
- Support for terminal colors

**Customization:**
```lua
require("tokyonight").setup({
  style = "night",  -- Options: "night", "storm", "day", "moon"
  transparent = false,  -- Set to true for transparent background
})
```

### 2. Floating Windows & Modern UI (Noice.nvim)

**Noice.nvim** provides:
- Floating command palette (`:` commands appear in a floating window)
- Beautiful message display
- Improved visual feedback
- Smooth animations

**What you'll see:**
- Command mode opens in a centered floating window
- Messages appear elegantly instead of cluttering the bottom
- Search results display in a modern format

### 3. Enhanced Notifications (nvim-notify)

Notifications now appear as:
- Elegant floating boxes in the top-right corner
- Color-coded by severity (error, warning, info)
- Auto-dismiss after 3 seconds
- Non-intrusive and professional looking

### 4. Beautiful Input/Select Dialogs (Dressing.nvim)

When plugins or commands need user input:
- Input prompts appear in a centered floating window
- Select menus have rounded borders and proper highlighting
- Keyboard navigation is smooth and intuitive

### 5. Indent Guides (indent-blankline)

Visual guides show indentation levels:
- Vertical lines indicate code structure
- Scope highlighting shows current block
- Helps with understanding nested code

### 6. Enhanced Statusline (Lualine)

The statusline now shows:
- Current mode (Normal, Insert, Visual, etc.)
- Filename and modification status
- Diagnostics (errors/warnings count)
- File encoding and format
- Progress and cursor location
- Buffer and tab navigation

### 7. Keybinding Discovery (which-key)

Press `<leader>` (usually Space) to see:
- All available keybindings
- Organized by category
- Descriptions for each binding
- Helpful for learning and discovering features

## New Keybindings

In addition to the original Genero Tools keybindings, the modern config adds:

### Window Navigation
```
Ctrl+h  - Move to left window
Ctrl+j  - Move to bottom window
Ctrl+k  - Move to top window
Ctrl+l  - Move to right window
```

### Buffer Management
```
<leader>bn  - Next buffer
<leader>bp  - Previous buffer
<leader>bd  - Delete current buffer
```

### Window Resizing
```
Ctrl+Up     - Increase window height
Ctrl+Down   - Decrease window height
Ctrl+Left   - Decrease window width
Ctrl+Right  - Increase window width
```

### Other
```
<Esc>       - Clear search highlighting
<leader>    - Show all available keybindings
```

## UI Improvements

### Cursor Line
The current line is highlighted with a subtle background, making it easier to track your position.

### Color Column
A vertical line at column 100 helps maintain line length standards.

### Sign Column
Always visible (2 characters wide) for error markers and other signs.

### Better Splits
- New splits open below and to the right (more intuitive)
- Windows auto-resize when terminal is resized
- Smooth navigation between splits

## Performance Optimizations

The configuration includes:
- Optimized update time (250ms) for better responsiveness
- Proper timeout settings for keybindings
- Efficient plugin loading with lazy.nvim

## Customization Examples

### Change Theme Style
```lua
-- In the tokyonight setup, change style to:
style = "storm",  -- Darker variant
-- or
style = "day",    -- Light theme
```

### Disable Floating Windows
If you prefer traditional UI, comment out the noice.nvim plugin:
```lua
-- {
--   "folke/noice.nvim",
--   ...
-- },
```

### Add Custom Keybindings
Add after the existing keybindings section:
```lua
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>xx", ":YourCommand<CR>", opts)
```

### Customize Statusline
Modify the lualine sections to show/hide components:
```lua
sections = {
  lualine_a = { "mode" },
  lualine_b = { "filename" },
  -- Remove or add components as needed
},
```

## Troubleshooting

### Floating windows not appearing
- Ensure `termguicolors` is enabled (it is by default)
- Check that your terminal supports 24-bit color
- Try disabling Noice if issues persist

### Colors look wrong
- Verify your terminal supports true color (24-bit)
- Try a different terminal emulator
- Check terminal color scheme settings

### Performance issues
- Disable indent-blankline if it causes lag
- Reduce `updatetime` if responsiveness is poor
- Check for conflicting plugins

### Keybindings not working
- Ensure `timeoutlen` is set appropriately (300ms default)
- Check for conflicting keybindings
- Use `:map` to see all current mappings

## Next Steps

1. Copy `init.lua.example` to `~/.config/nvim/init.lua`
2. Start Neovim: `nvim`
3. Lazy.nvim will automatically install all plugins
4. Press `<leader>` to discover keybindings
5. Open a `.4gl` or `.fgl` file and start coding

## Additional Resources

- [Tokyonight Documentation](https://github.com/folke/tokyonight.nvim)
- [Noice.nvim Documentation](https://github.com/folke/noice.nvim)
- [Lualine Documentation](https://github.com/nvim-lualine/lualine.nvim)
- [Which-key Documentation](https://github.com/folke/which-key.nvim)
- [Neovim Documentation](https://neovim.io/doc/user/)


## Display Mode Configuration

The default display mode for query results is now **`inline`**, which shows results in a modern floating window above the cursor. This provides a non-intrusive way to view query results without disrupting your workflow.

### Available Display Modes

```lua
display_mode = "inline",  -- Floating window above cursor (default, modern)
-- Other options:
-- display_mode = "popup",    -- Large floating window (Neovim only)
-- display_mode = "split",    -- New split window
-- display_mode = "quickfix", -- Quickfix list (traditional)
-- display_mode = "echo",     -- Command line output
```

### Display Mode Comparison

| Mode | Appearance | Best For | Notes |
|------|-----------|----------|-------|
| `inline` | Floating window above cursor | Quick lookups | Non-intrusive, auto-closes |
| `popup` | Large centered floating window | Detailed results | Neovim only |
| `split` | New split window | Extended browsing | Persistent, can resize |
| `quickfix` | Quickfix list | Navigation | Traditional, integrates with `:cn`, `:cp` |
| `echo` | Command line | Minimal output | Simple text display |

### Customizing Display Mode

To change the display mode, edit your `init.lua`:

```lua
vim.g.genero_tools_config = {
  -- ... other config ...
  display_mode = "popup",  -- Change to your preferred mode
}
```

# Lualine Integration for Genero-Tools

This document describes the lualine statusline integration for displaying compiler diagnostics (errors and warnings) in Neovim.

## Overview

The genero-tools lualine integration provides a custom statusline component that displays real-time error and warning counts from the compiler. This component reads from the `genero_compiler` sign group and formats the counts for display in the statusline.

## Features

- **Real-time Updates**: Displays current error/warning counts as you compile
- **Color Coding**: 
  - Errors shown with dark red background (subtle but visible)
  - Warnings shown with dark orange background (distinct from errors)
- **Compact Display**: Shows counts as `E#` and `W#` (e.g., `E2 W1`)
- **Zero-overhead**: Only displays when counts > 0

## Setup

### Basic Configuration

Add the lualine integration to your `init.lua`:

```lua
local lualine_genero = require("genero_tools.lualine")

require("lualine").setup({
  sections = {
    lualine_c = { "diagnostics", lualine_genero.diagnostics },
    -- ... other sections
  },
})
```

### Complete Example

See `init.lua.example` for a full working configuration with lualine and genero-tools.

## Component Details

### `diagnostics()`

The main component function that returns a formatted string of error/warning counts.

**Returns**: String in format `E# W#` or empty string if no diagnostics

**Example Output**:
- `E2 W1` - 2 errors, 1 warning
- `E5` - 5 errors, no warnings
- `W3` - 3 warnings, no errors
- `` (empty) - No errors or warnings

## How It Works

1. **Sign Detection**: Reads signs from the `genero_compiler` group in the current buffer
2. **Counting**: Counts signs named `GeneroCompilerError` and `GeneroCompilerWarning`
3. **Formatting**: Formats counts as `E#` (red) and `W#` (yellow)
4. **Display**: Lualine renders the component in the statusline

## Integration with Compiler

The lualine component automatically integrates with:

- **Autocompile**: Updates when autocompile runs
- **Manual Compile**: Updates when you run `:GeneroCompile`
- **Error Navigation**: Works with `:GeneroNextError` and `:GeneroPrevError`

## Customization

### Change Highlight Colors

To customize the highlight colors, edit `lua/genero_tools/lualine.lua`:

```lua
-- Example: Use different colors
function M.setup_highlights()
  vim.api.nvim_set_hl(0, 'GeneroLualineError', {
    bg = '#8b0000',  -- Dark red (default)
    fg = '#ffffff',
    bold = true,
  })
  
  vim.api.nvim_set_hl(0, 'GeneroLualineWarning', {
    bg = '#cc6600',  -- Dark orange (default)
    fg = '#ffffff',
    bold = true,
  })
end
```

Available color options:
- **Error colors**: `#8b0000` (dark red), `#dc143c` (crimson), `#a52a2a` (brown)
- **Warning colors**: `#cc6600` (dark orange), `#ff8c00` (dark orange alt), `#daa520` (goldenrod)

### Change Statusline Position

Move the component to a different section in lualine config:

```lua
sections = {
  lualine_a = { "mode" },
  lualine_b = { "filename", "modified" },
  lualine_c = { "diagnostics" },
  lualine_x = { lualine_genero.diagnostics, "encoding", "fileformat" },  -- Moved here
  lualine_y = { "progress" },
  lualine_z = { "location" },
}
```

### Combine with Other Diagnostics

If you use other LSP diagnostics, you can display both:

```lua
sections = {
  lualine_c = { 
    "diagnostics",           -- LSP diagnostics
    lualine_genero.diagnostics  -- Genero compiler diagnostics
  },
}
```

## Troubleshooting

### Component Not Showing

1. Verify lualine is installed and configured
2. Check that genero-tools is loaded: `:echo exists('g:loaded_genero_tools')`
3. Verify compiler signs are being placed: `:sign place buffer=` (current buffer number)
4. Check lualine refresh rate in config (default: 1000ms)

### Counts Not Updating

1. Ensure autocompile is enabled: `:GeneroAutocompileStatus`
2. Check compiler is working: `:GeneroCompile`
3. Verify signs are placed: `:sign place buffer=` (current buffer number)
4. Increase lualine refresh rate if needed:
   ```lua
   refresh = {
     statusline = 500,  -- Faster updates
   }
   ```

### Wrong Highlight Colors

The component uses custom highlight groups:
- `GeneroLualineError` - For error count (dark red background by default)
- `GeneroLualineWarning` - For warning count (dark orange background by default)

Customize in `lua/genero_tools/lualine.lua`:

```lua
function M.setup_highlights()
  vim.api.nvim_set_hl(0, 'GeneroLualineError', {
    bg = '#8b0000',  -- Change this color
    fg = '#ffffff',
    bold = true,
  })
  vim.api.nvim_set_hl(0, 'GeneroLualineWarning', {
    bg = '#cc6600',  -- Change this color
    fg = '#ffffff',
    bold = true,
  })
end
```

## Performance

The lualine component is optimized for performance:

- Uses `pcall` to safely handle missing signs API
- Only counts signs in current buffer
- Minimal string formatting
- No external dependencies

## See Also

- [Compiler Integration](COMPILER_INTEGRATION.md)
- [Sign Column Implementation](SIGN_COLUMN_IMPLEMENTATION.md)
- [Unified Signs Quick Reference](UNIFIED_SIGNS_QUICK_REFERENCE.md)

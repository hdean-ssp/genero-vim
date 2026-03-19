# Neovim 0.9.5 Setup for Genero Development

This guide helps you set up Neovim 0.9.5 with the genero-tools plugin for Genero development with a modern, beautiful UI.

## Prerequisites

- Neovim 0.9.5 (exactly this version due to environment constraints)
- Git (for lazy.nvim plugin manager)
- fglcomp compiler in your PATH
- BRODIR environment variable set (for query.sh path)

## Installation

### 1. Set up Neovim configuration

Copy the example configuration to your Neovim config directory:

```bash
mkdir -p ~/.config/nvim
cp init.lua.example ~/.config/nvim/init.lua
```

The genero-tools configuration is embedded in `init.lua` and will work out of the box.

### 2. Update paths in init.lua (optional)

The genero-vim plugin will be automatically cloned to `~/.local/share/nvim/lazy/genero-tools/` by lazy.nvim.

If you prefer to use a local development copy instead, update the plugin spec in `~/.config/nvim/init.lua`:

```lua
{
  dir = vim.fn.expand("~/path/to/your/genero-vim"),  -- Use local directory
  name = "genero-tools",
  config = function()
    require("genero_config")
  end,
},
```

### 3. Set environment variables

Ensure BRODIR is set in your shell:

```bash
export BRODIR=/path/to/your/brodir
```

Or update the `genero_tools_path` in `init.lua`:

```lua
vim.g.genero_tools_config = {
  genero_tools_path = "/path/to/your/brodir/etc/genero-tools/query.sh",
  -- ... other config
}
```

### 4. Start Neovim

```bash
nvim
```

Lazy.nvim will automatically download and install plugins on first launch.

## Keybindings

| Key | Action |
|-----|--------|
| `F5` | Compile current file |
| `Ctrl+Space` | Trigger autocomplete (insert mode) |
| `Ctrl+,` | Jump to previous error/warning |
| `Ctrl+.` | Jump to next error/warning |
| `Space+ca` | Enable autocompile on save |
| `Space+cd` | Disable autocompile on save |
| `Space+cc` | Clear error markers |
| `Space+hn` | Jump to next hint |
| `Space+hp` | Jump to previous hint |
| `Space+hl` | List all hints |
| `Space+hd` | Show hint details |
| `Space+hf` | Apply auto-fix for hint |
| `Space+sv` | Toggle SVN markers on/off |
| `Space+sr` | Refresh SVN markers |
| `Space+ss` | Show SVN status and changes |
| `Space+su` | Toggle unified signs (compiler + SVN) |
| `Space+sl` | List available snippets |
| `Space+sh` | Show snippet help |
| `Space+gd` | Toggle debug stream on/off |
| `Space+gl` | Lookup function definition |
| `Space+gf` | List functions in file |
| `Space+gs` | Get function signature |
| `Space+gm` | Get file metadata |
| `Ctrl+h/j/k/l` | Navigate between windows |
| `Space+bn` | Next buffer |
| `Space+bp` | Previous buffer |
| `Space+bd` | Delete current buffer |
| `Ctrl+Up/Down` | Resize window vertically |
| `Ctrl+Left/Right` | Resize window horizontally |
| `Space` | Show available keybindings (which-key) |

## Commands

```vim
:GeneroCompile              " Compile current file
:GeneroAutocompileEnable    " Enable autocompile on save
:GeneroAutocompileDisable   " Disable autocompile on save
:GeneroAutocompileStatus    " Show autocompile status
:GeneroClearErrors          " Clear error markers
:GeneroNextError            " Jump to next error
:GeneroPrevError            " Jump to previous error
:GeneroFirstError           " Jump to first error
:GeneroLastError            " Jump to last error
:GeneroLookup               " Lookup function definition
:GeneroListFunctions        " List functions in file
:GeneroListModuleFiles      " List files in module
:GeneroFunctionSignature    " Get function signature
:GeneroFileMetadata         " Get file metadata
:GeneroNextHint             " Jump to next hint
:GeneroPrevHint             " Jump to previous hint
:GeneroListHints            " List all hints in file
:GeneroHintDetails          " Show hint details
:GeneroHintAutofix          " Apply auto-fix for hint
:GeneroHintHelp             " Show hint documentation
:GeneroClearHintCache       " Clear all cached hints
:GeneroSVNRefresh           " Manually refresh SVN markers
:GeneroSVNToggle            " Toggle SVN markers on/off
:GeneroSVNStatus            " Show SVN status and changes
:GeneroSVNCacheStats        " Show SVN cache statistics
:GeneroSVNCacheClear        " Clear SVN cache
:GeneroUnifiedSignsEnable   " Enable unified sign column
:GeneroUnifiedSignsDisable  " Disable unified sign column
:GeneroUnifiedSignsToggle   " Toggle unified sign column
:GeneroUnifiedSignsStatus   " Show unified signs status
:GeneroSnippetList          " List all available snippets
:GeneroSnippetHelp          " Show snippet documentation
:GeneroDebugStream          " Start debug streaming
:GeneroDebugStreamStop      " Stop debug streaming
:GeneroDebugStreamToggle    " Toggle debug stream on/off
:GeneroDebugStreamSelect    " Select different debug file
:GeneroDebugStreamClear     " Clear debug stream content
:GeneroDebugStreamStatus    " Show debug stream status
:GeneroClearCache           " Clear result cache
:GeneroCompleteEnable       " Enable autocomplete
:GeneroCompleteDisable      " Disable autocomplete
:GeneroConfigShow           " Show current configuration
:GeneroHelp                 " Show this help
```

## Customization

### Configuration Options

The plugin has 50+ configuration options. Here are the most important ones:

**Compiler Settings:**
```lua
compiler_enabled = true                    -- Enable/disable compiler
compiler_autocompile = true                -- Auto-compile on save
compiler_autocompile_delay = 500           -- Delay in ms before compiling
compiler_command = "fglcomp"               -- Compiler for .4gl/.m3/.m4
compiler_form_command = "fglform"          -- Compiler for .per files
compiler_args = { "-M", "-W", "all" }      -- Compiler arguments
compiler_highlight_unused = true           -- Highlight unused variables
compiler_sign_column = true                -- Show signs in gutter
compiler_sign_column_always_visible = true -- Keep sign column visible
```

**Code Hints Settings:**
```lua
hints_enabled = true                       -- Enable/disable hints
hints_display = "signs"                    -- Display: "signs", "virtual_text", "both"
hints_severity = "warning"                 -- Severity: "info", "warning", "style"
hints_realtime = true                      -- Real-time detection
hints_delay = 500                          -- Debounce delay in ms
auto_fix_enabled = true                    -- Enable auto-fix suggestions

-- Individual hint checks (true = enabled, false = disabled)
trailing_whitespace = true
mixed_indentation = true
lowercase_keywords = true
unclosed_blocks = true
line_length = true
deprecated_functions = true

-- Thresholds
max_line_length = 100
max_nesting_depth = 5
max_blank_lines = 2
```

**Autocomplete Settings:**
```lua
autocomplete_on_pause = true               -- Auto-trigger on pause
autocomplete_delay = 500                   -- Delay in ms before triggering
```

**Debug Streaming (Neovim only):**
```lua
debug_stream_enabled = true                -- Enable debug streaming
debug_stream_width = 0                     -- 0 = auto-size to 1/3 screen
debug_stream_max_lines = 1000              -- Max lines to keep
debug_stream_auto_scroll = true            -- Auto-scroll to latest
debug_stream_directory = "./debug"         -- Debug file directory
```

**SVN Integration:**
```lua
svn_enabled = true                         -- Enable SVN diff markers
svn_show_added = true                      -- Show added lines
svn_show_modified = true                   -- Show modified lines
svn_show_deleted = true                    -- Show deleted lines
svn_cache_ttl = 300                        -- SVN cache TTL in seconds
svn_auto_update = true                     -- Auto-update on save
```

**Lua Layer (Neovim only):**
```lua
lua_enabled = true                         -- Enable Lua layer features (auto-detected: true on Neovim, false on Vim)
```

**Debug Mode (for troubleshooting):**
```lua
debug_mode = false                         -- Set to true to enable debug logging
```

**Per-File Configuration:**
Create `.genero-hints` in project root for per-file hint configuration:
```json
{
  "rules": [
    {
      "pattern": "src/**/*.4gl",
      "config": {
        "max_line_length": 120,
        "max_nesting_depth": 6
      }
    }
  ]
}
```

**Floating Window Settings:**
```lua
floating_window_border = "rounded"         -- Border style
floating_window_width = 80                 -- Width in columns
floating_window_height = 20                -- Height in lines
floating_window_position = "center"        -- Position: center, top, bottom, etc.
popup_auto_close_delay = 5000              -- Auto-close delay in ms
```

### Change the Color Scheme

In `init.lua`, modify the Tokyonight setup:

```lua
require("tokyonight").setup({
  style = "night",  -- Options: "night", "storm", "day", "moon"
  transparent = false,  -- Set to true for transparent background
  -- ... other options
})
```

### Disable Floating Windows

If you prefer traditional UI, disable Noice:

```lua
-- Comment out or remove the noice.nvim plugin entry
```

### Customize Keybindings

Add your own keybindings after the existing ones:

```lua
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Your custom keybindings
map("n", "<leader>xx", ":YourCommand<CR>", opts)
```

### Adjust Statusline

Modify the lualine configuration to show/hide components:

```lua
sections = {
  lualine_a = { "mode" },
  lualine_b = { "filename", "modified" },
  lualine_c = { "diagnostics" },
  -- Add or remove components as needed
},
```

## Troubleshooting

### Plugins not installing

If plugins don't install on first launch:

```bash
rm -rf ~/.local/share/nvim/lazy
nvim
```

### Compiler not found

Ensure fglcomp is in your PATH:

```bash
which fglcomp
```

If not found, update `compiler_command` in `genero_config.lua` with the full path.

### Query.sh not found

Ensure BRODIR is set and the path exists:

```bash
echo $BRODIR
ls $BRODIR/etc/genero-tools/query.sh
```

### Version conflicts

This configuration is tested for Neovim 0.9.5 only. If you have version issues:

1. Check your Neovim version: `nvim --version`
2. Ensure plugin versions match (see init.lua for version constraints)
3. Clear plugin cache: `rm -rf ~/.local/share/nvim/lazy`

## Features

### Modern Dark Theme
- **Tokyonight** color scheme with beautiful dark aesthetics
- Optimized for readability and reduced eye strain
- Consistent colors across all UI elements

### Compiler Integration
- **Multi-file support**: .4gl, .m3, .m4 files (fglcomp) and .per files (fglform)
- **Automatic file type detection**: Selects correct compiler based on file extension
- **Autocompile on save**: Configurable 500ms delay to avoid multiple compilations
- **Error/warning highlighting**: Signs in gutter, inline highlighting, quickfix list
- **Unused variable detection**: Highlights unused variables when enabled
- **Mixed project support**: Handles projects with both .4gl and .per files

### Floating Windows & Modern UI
- **Noice.nvim** for floating command palette and messages
- **Dressing.nvim** for beautiful input/select dialogs
- **Indent-blankline** for visual indent guides
- Smooth animations and transitions

### Enhanced Statusline
- **Lualine** with Tokyonight theme integration
- Shows mode, filename, diagnostics, encoding, and location
- **Diagnostic counts**: Error and warning counts displayed with color-coded backgrounds
- Buffer and tab navigation in the tabline

### Code Hints System
Non-fatal code quality warnings that help maintain consistency:
- **Whitespace & formatting**: Trailing spaces, mixed indentation, excessive blank lines
- **Keyword & naming**: Lowercase keywords, inconsistent casing, naming convention violations
- **Code structure**: Unclosed blocks, excessive nesting, long lines, missing comments
- **Genero-specific**: Missing error handling, deprecated functions
- **Real-time detection**: Configurable debounce delay (default: 500ms)
- **Display modes**: Sign column, virtual text, or both
- **Auto-fix suggestions**: Apply fixes for common issues
- **Fully configurable**: Per-file or project-wide configuration

### Autocomplete System
- **Auto-trigger on pause**: Automatically shows suggestions after 500ms of inactivity
- **Manual trigger**: Ctrl+Space to manually trigger completion
- **Function/module suggestions**: Shows available functions and modules
- **Smart filtering**: Requires 2+ characters before triggering
- **Menu auto-close**: Closes when leaving insert mode

### Debug Streaming (Neovim only)
- **Real-time file monitoring**: Watch debug files as they're written
- **Dynamic window sizing**: Auto-sizes to 1/3 of screen width (configurable)
- **Auto-scroll**: Automatically scrolls to latest content
- **File selection**: Switch between different debug files
- **Configurable limits**: Maximum lines to keep in memory (default: 1000)

### SVN Integration
- **Visual diff markers**: Shows added, modified, and deleted lines
- **Sign column indicators**: Visual indicators for each change type
- **Configurable display**: Show/hide specific change types
- **Auto-update**: Updates markers on file save
- **Caching**: Efficient caching with configurable TTL

### Unified Sign Column
- **Combined display**: Compiler errors/warnings and SVN markers in one column
- **Space-efficient**: Reduces screen real estate compared to separate columns
- **Smart combination**: Intelligently combines signs when both appear on same line
- **Toggle on/off**: Enable/disable unified signs with `:GeneroUnifiedSignsToggle`

### Helpful Features
- **Which-key** integration for discovering keybindings (press `<leader>`)
- **Nvim-notify** for elegant notifications
- Automatic window resizing
- Highlight on yank for visual feedback
- Improved window navigation with Ctrl+hjkl

### Autocompile on Save
By default, autocompile is enabled. Files are compiled automatically when saved with a 500ms delay to avoid multiple compilations.

### Error Highlighting
Errors and warnings are highlighted in the editor with:
- Signs in the gutter (left margin)
- Inline highlighting
- Quickfix list for navigation

## Next Steps

1. Open a .4gl, .m3, .m4, or .per file
2. Press F5 to compile
3. Use Ctrl+[ and Ctrl+] to navigate errors
4. Enable autocompile with `<leader>ca` for automatic compilation on save
5. Use `<leader>hn` to navigate code hints
6. Use `<leader>sl` to see available code snippets

## File Type Support

The plugin automatically detects file types and uses the appropriate compiler:

| File Type | Compiler | Command |
|-----------|----------|---------|
| .4gl | fglcomp | `compiler_command` |
| .m3 | fglcomp | `compiler_command` |
| .m4 | fglcomp | `compiler_command` |
| .per | fglform | `compiler_form_command` |

You can have both .4gl and .per files in the same project - the plugin will automatically select the correct compiler for each file type.

## Support

For issues with the genero-tools plugin, see the main README.md in the repository.

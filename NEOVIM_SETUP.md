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

The genero-tools configuration is embedded in `init.lua` and will work out of the box. If you want to customize settings in a separate file, you can create `~/.config/nvim/genero_config.lua` (see genero_config.lua.example for reference).

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
| `Ctrl+,` | Jump to previous error/warning |
| `Ctrl+.` | Jump to next error/warning |
| `<leader>ca` | Enable autocompile on save |
| `<leader>cd` | Disable autocompile on save |
| `<leader>cc` | Clear error markers |
| `<leader>sl` | List available snippets |
| `<leader>sh` | Show snippet help |
| `Ctrl+h/j/k/l` | Navigate between windows |
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |
| `<leader>bd` | Delete current buffer |
| `Ctrl+Up/Down` | Resize window vertically |
| `Ctrl+Left/Right` | Resize window horizontally |
| `<leader>` | Show available keybindings (which-key) |

## Commands

```vim
:GeneroCompile              " Compile current file
:GeneroAutocompileEnable    " Enable autocompile on save
:GeneroAutocompileDisable   " Disable autocompile on save
:GeneroAutocompileStatus    " Show autocompile status
:GeneroClearErrors          " Clear error markers
:GeneroNextError            " Jump to next error
:GeneroPrevError            " Jump to previous error
:GeneroHelp                 " Show this help
```

## Customization

The configuration is highly customizable. Here are some common tweaks:

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

### Floating Windows & Modern UI
- **Noice.nvim** for floating command palette and messages
- **Dressing.nvim** for beautiful input/select dialogs
- **Indent-blankline** for visual indent guides
- Smooth animations and transitions

### Enhanced Statusline
- **Lualine** with Tokyonight theme integration
- Shows mode, filename, diagnostics, encoding, and location
- Buffer and tab navigation in the tabline

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

### Unused Variable Detection
Unused variables are highlighted when `compiler_highlight_unused` is enabled.

## Next Steps

1. Open a .4gl or .fgl file
2. Press F5 to compile
3. Use Ctrl+[ and Ctrl+] to navigate errors
4. Enable autocompile with `<leader>ca` for automatic compilation on save

## Support

For issues with the genero-tools plugin, see the main README.md in the repository.

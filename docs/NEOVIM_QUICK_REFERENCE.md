# Neovim Quick Reference Card

## Installation

```bash
cp init.lua.example ~/.config/nvim/init.lua
nvim
```

## Genero Compilation

| Key | Action |
|-----|--------|
| `F5` | Compile current file |
| `Ctrl+[` | Previous error |
| `Ctrl+]` | Next error |
| `<leader>ca` | Enable autocompile |
| `<leader>cd` | Disable autocompile |
| `<leader>cc` | Clear errors |

## Snippets

| Key | Action |
|-----|--------|
| `<leader>sl` | List snippets |
| `<leader>sh` | Snippet help |

## Window Navigation

| Key | Action |
|-----|--------|
| `Ctrl+h` | Left window |
| `Ctrl+j` | Down window |
| `Ctrl+k` | Up window |
| `Ctrl+l` | Right window |
| `Ctrl+Up` | Increase height |
| `Ctrl+Down` | Decrease height |
| `Ctrl+Left` | Decrease width |
| `Ctrl+Right` | Increase width |

## Buffer Management

| Key | Action |
|-----|--------|
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |
| `<leader>bd` | Delete buffer |

## Discovery

| Key | Action |
|-----|--------|
| `<leader>` | Show all keybindings |
| `:GeneroHelp` | Show Genero help |

## Commands

```vim
:GeneroCompile              " Compile current file
:GeneroAutocompileEnable    " Enable autocompile
:GeneroAutocompileDisable   " Disable autocompile
:GeneroAutocompileStatus    " Show status
:GeneroClearErrors          " Clear errors
:GeneroNextError            " Next error
:GeneroPrevError            " Previous error
:GeneroSnippetList          " List snippets
:GeneroSnippetHelp          " Snippet help
:GeneroHelp                 " Show help
```

## Features

✨ **Tokyonight Theme** - Beautiful dark colors
🪟 **Floating Windows** - Modern UI for commands
📢 **Notifications** - Elegant message display
📝 **Indent Guides** - Visual code structure
📊 **Rich Statusline** - Mode, file, diagnostics
🔍 **Which-key** - Keybinding discovery

## Customization

### Change Theme
Edit `init.lua`, find tokyonight setup:
```lua
style = "night",    -- or "storm", "day", "moon"
```

### Disable Floating Windows
Comment out `noice.nvim` plugin entry

### Add Keybinding
```lua
local map = vim.keymap.set
map("n", "<leader>xx", ":Command<CR>", { noremap = true, silent = true })
```

## Troubleshooting

**Plugins not installing:**
```bash
rm -rf ~/.local/share/nvim/lazy && nvim
```

**Colors wrong:**
- Check terminal supports 24-bit color
- Try different terminal emulator

**Floating windows not showing:**
- Verify `termguicolors` enabled
- Try disabling Noice plugin

## Tips

- Press `<leader>` to discover keybindings
- Use `Ctrl+hjkl` to navigate splits
- Autocompile enabled by default (500ms delay)
- Errors shown in sign column and quickfix
- Yank highlighting shows what you copied

## Files

- `init.lua.example` - Main configuration
- `NEOVIM_SETUP.md` - Complete setup guide
- `NEOVIM_MODERN_CONFIG.md` - Feature details
- `NEOVIM_UPGRADE_GUIDE.md` - Migration guide

## System Requirements

- Neovim 0.9.5+
- Git (for lazy.nvim)
- 24-bit color terminal
- fglcomp in PATH

---

**Quick Start:** Copy config → Start Neovim → Press `<leader>` → Explore!

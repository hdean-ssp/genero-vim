# Genero Tools Help System

The Genero Tools plugin includes a comprehensive help system that displays all keybindings, commands, and features in an easy-to-navigate floating window.

## Features

- **Persistent Floating Window**: Help displays in a large, centered floating window (Neovim)
- **Comprehensive Content**: All keybindings, commands, and features organized by category
- **Easy Navigation**: Scroll with j/k, search with /, jump with G/gg
- **Quick Access**: Toggle help on/off with a single keybinding
- **Syntax Highlighting**: Color-coded categories, commands, and keybindings

## Commands

### `:GeneroHelp`
Opens the help window displaying all available keybindings and commands.

```vim
:GeneroHelp
```

### `:GeneroHelpToggle`
Toggles the help window on/off. If the window is open, it closes it. If closed, it opens it.

```vim
:GeneroHelpToggle
```

### `:GeneroHelpClose`
Closes the help window if it's currently open.

```vim
:GeneroHelpClose
```

## Keybindings

### Default Keybinding
- `<Space>gh` - Toggle help window (Neovim with which-key)

### Within Help Window
- `j` / `k` or `↑` / `↓` - Scroll up/down
- `Ctrl+d` / `Ctrl+u` - Page down/up
- `G` - Jump to end
- `gg` - Jump to beginning
- `/` - Search within help
- `n` / `N` - Next/previous search result
- `q` or `Esc` - Close help window

## Help Content Categories

The help window organizes information into the following categories:

1. **COMPILATION** - Compile commands and autocompile settings
2. **NAVIGATION** - Error navigation, buffer navigation, window management
3. **GENERO TOOLS** - Function lookup, metadata, debug streaming
4. **CODE HINTS** - Code quality hints and auto-fixes
5. **SVN DIFF MARKERS** - Version control integration
6. **UNIFIED SIGNS** - Combined compiler and SVN sign column
7. **SNIPPETS** - Code snippet expansion
8. **AUTOCOMPLETE** - Completion menu and settings
9. **DEBUG STREAMING** - Real-time file monitoring
10. **WINDOW MANAGEMENT** - Split navigation
11. **TERMINAL** - Integrated terminal commands
12. **SEARCH (Telescope)** - Fuzzy finding and grep
13. **LSP** - Language server features for other languages
14. **COMMENTING** - Comment toggling
15. **KEY FEATURES** - Overview of major features
16. **TIPS & TRICKS** - Best practices and workflow tips

## Usage Examples

### Quick Reference
Press `<Space>gh` at any time to toggle the help window and see all available commands.

### Learning the Plugin
When first starting with Genero Tools, open the help window and browse through the categories to discover features:

```vim
:GeneroHelp
```

### Finding a Specific Command
Open help and use search to find specific functionality:

1. Press `<Space>gh` to open help
2. Press `/` to start searching
3. Type your search term (e.g., "snippet", "error", "compile")
4. Press `n` to jump to next match

### Quick Toggle
Keep help accessible while working:

```vim
" Open help to check a keybinding
<Space>gh

" Close help when done
<Space>gh
```

## Vim vs Neovim

### Neovim
- Full-featured floating window with syntax highlighting
- Persistent window that can be toggled on/off
- Searchable content with `/`
- Smooth scrolling and navigation

### Vim
- Uses the traditional `:GeneroHelp` command
- Displays help in the command area (echo)
- Content is the same but formatted for echo display
- No floating window support

## Customization

### Changing the Keybinding

To change the help toggle keybinding, modify your `init.lua`:

```lua
-- Change from <Space>gh to <F1>
vim.keymap.set('n', '<F1>', ':GeneroHelpToggle<CR>', { noremap = true, silent = true, desc = "Toggle help" })
```

### Auto-show on Startup

Help automatically displays when Neovim/Vim starts with no files:

```lua
-- This is already configured in init.lua.example
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("GeneroHelp")
    end
  end,
})
```

To disable this behavior, remove or comment out the autocmd.

## Implementation Details

### Lua Module
The help system is implemented in `lua/genero_tools/help.lua` as a standalone module.

### Key Functions
- `require('genero_tools.help').show()` - Show help window
- `require('genero_tools.help').toggle()` - Toggle help window
- `require('genero_tools.help').close()` - Close help window

### Window Configuration
- Width: 85% of screen width
- Height: 85% of screen height
- Border: Rounded
- Position: Centered
- Title: "Genero Tools Help"

## Tips

1. **First-time users**: Run `:GeneroHelp` to see all available features
2. **Quick reference**: Use `<Space>gh` to quickly check a keybinding
3. **Search**: Use `/` within help to find specific commands
4. **which-key**: Press `<Space>` to see context-sensitive keybindings
5. **Combine**: Use help for comprehensive reference, which-key for quick hints

## Troubleshooting

### Help window doesn't open
- Ensure you're using Neovim (Vim uses echo-based help)
- Check that `lua/genero_tools/help.lua` exists
- Verify no errors with `:messages`

### Content is cut off
- The window is sized at 85% of screen - resize your terminal
- Use `j`/`k` to scroll through all content

### Keybinding doesn't work
- Verify which-key is installed and configured
- Check for keybinding conflicts with `:verbose map <Space>gh`
- Try the command directly: `:GeneroHelpToggle`

## See Also

- [README.md](../README.md) - Main plugin documentation
- [SETUP.md](../SETUP.md) - Installation and setup guide
- [docs/NEOVIM_SETUP.md](NEOVIM_SETUP.md) - Neovim-specific configuration

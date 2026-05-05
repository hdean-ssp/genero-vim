# Snippet Telescope Integration

## Overview

The snippet list command (`:GeneroSnippetList`) now uses Telescope when available, providing a consistent UI experience with other Genero-Tools pickers. This gives you:

- **Live preview** of snippet body before selection
- **Fuzzy search** to quickly find snippets
- **Consistent keybindings** with other Telescope pickers
- **Syntax highlighting** in preview window

## Usage

### Automatic Telescope Integration

```vim
:GeneroSnippetList
```

This command automatically uses Telescope if available, otherwise falls back to the floating window implementation.

### Explicit Telescope Command

```vim
:GeneroSnippetsTelescope
```

This command explicitly uses the Telescope picker (will show an error if Telescope is not installed).

## Features

### Preview Window

The Telescope picker shows a preview of each snippet including:
- Snippet name and trigger
- Description
- Full template body with syntax highlighting
- Placeholder markers (e.g., `${1:function_name}`)

### Keybindings

Standard Telescope keybindings apply:

| Key | Action |
|-----|--------|
| `<CR>` | Select and expand snippet |
| `<C-n>` / `<Down>` | Next snippet |
| `<C-p>` / `<Up>` | Previous snippet |
| `<C-c>` / `<Esc>` | Close picker |
| `<C-u>` | Scroll preview up |
| `<C-d>` | Scroll preview down |

### Fuzzy Search

Type to filter snippets by trigger or description:
- `fn` - finds "function" snippet
- `loop` - finds "for_loop", "while_loop", etc.
- `case` - finds "case_statement" snippet

## Configuration

### Fallback Behavior

If Telescope is not installed, `:GeneroSnippetList` automatically falls back to the floating window implementation with keyboard/mouse selection.

### Disabling Telescope Integration

If you prefer the floating window implementation even when Telescope is available, you can use the Lua API directly:

```lua
require('genero_tools.snippets').list_snippets_display()
```

Or set up a custom command:

```vim
command! GeneroSnippetListFloat lua require('genero_tools.snippets').list_snippets_display()
```

## Comparison with Other Pickers

The snippet picker follows the same pattern as other Genero-Tools Telescope integrations:

| Picker | Command | Purpose |
|--------|---------|---------|
| File Functions | `:GeneroFileFunctions` | Navigate functions in current file |
| Module Functions | `:GeneroModuleFunctions` | Navigate functions in module |
| Module Files | `:GeneroModuleFiles` | Switch between module files |
| Diagnostics | `:GeneroDiagnostics` | Browse compiler errors/warnings |
| **Snippets** | `:GeneroSnippetList` | Browse and insert snippets |
| Variable References | (automatic) | Find variable references |

## Implementation Details

### Architecture

1. **VimScript Bridge** (`autoload/genero_tools/snippets.vim`)
   - `genero_tools#snippets#list()` tries Telescope first
   - Falls back to floating window if Telescope unavailable

2. **Telescope Picker** (`lua/genero_tools/telescope.lua`)
   - `M.snippets()` function implements the picker
   - Custom previewer shows snippet body with syntax highlighting
   - Returns `true` if successful, `false` to trigger fallback

3. **Snippet Data** (`lua/genero_tools/snippets/init.lua`)
   - `M.get_all_snippets()` provides snippet data
   - Returns array of snippet objects with trigger, description, body

### Custom Previewer

The snippet picker uses a custom Telescope previewer that:
- Formats snippet metadata (name, trigger, description)
- Displays the template body with separators
- Applies Genero (4gl) syntax highlighting
- Shows placeholder markers in context

## Testing

Run the test suite to verify Telescope integration:

```vim
:luafile test/test_snippet_telescope.lua
```

This tests:
- Telescope function availability
- Snippet data structure
- Telescope module availability
- Integration points

## Troubleshooting

### Telescope Not Found

If you see "Telescope required" messages:
1. Install Telescope: `https://github.com/nvim-telescope/telescope.nvim`
2. Ensure Telescope is loaded before Genero-Tools
3. Verify with `:Telescope` command

### Snippets Not Showing

If the picker is empty:
1. Verify LuaSnip is installed
2. Check snippet initialization: `:lua print(vim.inspect(require('genero_tools.snippets').health_check()))`
3. Ensure you're in a Genero file (`.4gl`, `.fgl`, `.per`)

### Preview Not Working

If preview window is blank:
1. Check snippet body exists: `:GeneroSnippetHelp <trigger>`
2. Verify Telescope previewers are available
3. Try updating Telescope to latest version

## Related Documentation

- [Snippets Overview](SNIPPETS.md)
- [Telescope Integration](TELESCOPE_INTEGRATION.md)
- [Snippet Configuration](SNIPPET_CONFIGURATION.md)
- [Snippet Testing Guide](SNIPPET_TESTING_GUIDE.md)

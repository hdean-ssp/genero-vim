# Snippet System Architecture

**Last Updated**: March 22, 2026
**Status**: Complete
**Scope**: Neovim 0.5+ with LuaSnip

---

## System Overview

The snippet system is a two-layer architecture:

```
┌─────────────────────────────────────────┐
│     VimScript Layer (autoload/)         │
│  - User-facing commands and functions   │
│  - Snippet list UI with selection       │
│  - Autocomplete integration             │
│  - Placeholder navigation keybindings   │
└──────────────┬──────────────────────────┘
               │ luaeval() calls
               ↓
┌─────────────────────────────────────────┐
│      Lua Layer (lua/genero_tools/)      │
│  - Snippet loading and management       │
│  - LuaSnip integration                  │
│  - Placeholder parsing                  │
│  - Hot-reload support                   │
└─────────────────────────────────────────┘
```

---

## Layer 1: VimScript Layer

### Files
- `autoload/genero_tools/snippets.vim` - Main snippet interface
- `autoload/genero_tools/complete.vim` - Autocomplete integration
- `autoload/genero_tools/keybindings.vim` - Placeholder navigation keybindings

### Key Functions

#### Snippet List Display

```vim
genero_tools#snippets#list()
  ├─ Checks if selection is enabled
  ├─ Calls Lua to get all snippets
  └─ Displays selectable floating window

genero_tools#snippets#list_with_selection()
  ├─ Creates floating window
  ├─ Sets up keybindings
  └─ Handles selection

genero_tools#snippets#show_snippet_list()
  ├─ Formats snippet list
  ├─ Creates nvim_open_win()
  └─ Applies highlighting
```

#### Selection Handling

```vim
genero_tools#snippets#select_snippet()
  ├─ Gets selected snippet
  ├─ Closes list window
  └─ Calls expand()

genero_tools#snippets#next_snippet()
  └─ Moves selection down

genero_tools#snippets#prev_snippet()
  └─ Moves selection up

genero_tools#snippets#mouse_select_snippet()
  ├─ Gets line number from mouse
  └─ Calls select_snippet()
```

#### Snippet Expansion

```vim
genero_tools#snippets#expand(trigger)
  ├─ Checks snippet_expansion_mode
  ├─ Calls Lua expand_with_luasnip()
  └─ Returns to user

genero_tools#snippets#expand_by_name(trigger)
  └─ Fallback expansion method
```

#### Placeholder Navigation

```vim
genero_tools#snippets#next_placeholder()
  └─ Calls Lua next_placeholder()

genero_tools#snippets#prev_placeholder()
  └─ Calls Lua prev_placeholder()

genero_tools#snippets#next_placeholder_or_tab()
  ├─ Tries to jump to next placeholder
  └─ Falls back to Tab if not in snippet

genero_tools#snippets#prev_placeholder_or_tab()
  ├─ Tries to jump to previous placeholder
  └─ Falls back to Shift+Tab if not in snippet
```

#### Autocomplete Integration

```vim
genero_tools#complete#get_completions(base)
  ├─ Checks autocomplete_include_snippets
  ├─ Calls get_snippet_completions()
  └─ Merges with function completions

genero_tools#complete#get_snippet_completions(base)
  ├─ Calls Lua get_all_snippets()
  ├─ Filters by base string
  └─ Formats for autocomplete menu

genero_tools#complete#on_snippet_selected(trigger)
  ├─ Closes completion menu
  └─ Calls expand()
```

### Data Flow: Snippet List Selection

```
User: :GeneroSnippetList
  ↓
genero_tools#snippets#list()
  ↓
genero_tools#snippets#list_with_selection()
  ↓
luaeval('get_all_snippets()')
  ↓
genero_tools#snippets#show_snippet_list()
  ├─ nvim_create_buf()
  ├─ nvim_open_win()
  └─ setup_list_keybindings()
  ↓
User: j/k to navigate, Enter to select
  ↓
genero_tools#snippets#select_snippet()
  ├─ genero_tools#snippets#close_snippet_list()
  └─ genero_tools#snippets#expand(trigger)
  ↓
Snippet expands at cursor
```

### Data Flow: Autocomplete Integration

```
User: Ctrl+N in insert mode
  ↓
genero_tools#complete#omnifunc()
  ↓
genero_tools#complete#get_completions(base)
  ├─ genero_tools#complete#get_snippet_completions(base)
  │  ├─ luaeval('get_all_snippets()')
  │  └─ Filter by base
  └─ Merge with function completions
  ↓
Autocomplete menu shows snippets with [snippet] indicator
  ↓
User: Select snippet, press Enter
  ↓
genero_tools#complete#on_snippet_selected(trigger)
  ├─ Close completion menu
  └─ genero_tools#snippets#expand(trigger)
  ↓
Snippet expands with placeholder support
```

---

## Layer 2: Lua Layer

### Files
- `lua/genero_tools/snippets/init.lua` - Main snippet module
- `lua/genero_tools/snippets/manager.lua` - Snippet loading and management
- `lua/genero_tools/snippets/async_params.lua` - Parameter population

### Key Functions

#### Initialization

```lua
M.setup()
  ├─ Load built-in snippets
  ├─ Load custom snippets
  ├─ Merge snippets
  ├─ Register with LuaSnip
  └─ Set up file watcher
```

#### Snippet Loading

```lua
Manager.load_builtin()
  └─ Load from lua/genero_tools/snippets/templates/builtin/

Manager.load_custom()
  └─ Load from ~/.config/nvim/genero-snippets/

Manager.load_snippets_from_directory(dir)
  ├─ Find all .lua files
  ├─ Execute each file
  └─ Merge results
```

#### Snippet Retrieval

```lua
M.get_all_snippets()
  ├─ Get all loaded snippets
  └─ Convert to array format for VimScript

M.get_snippet(trigger)
  ├─ Check custom snippets first
  └─ Fall back to built-in

M.list_snippets()
  └─ Return all snippets as table
```

#### Snippet Expansion

```lua
M.expand_with_luasnip(trigger)
  ├─ Get snippet by trigger
  ├─ Parse snippet body
  ├─ Create LuaSnip snippet object
  ├─ Insert at cursor
  └─ Expand with LuaSnip

M.expand_by_name(trigger)
  └─ Fallback expansion (no placeholder support)
```

#### Placeholder Navigation

```lua
M.next_placeholder()
  └─ Call ls.jump(1)

M.prev_placeholder()
  └─ Call ls.jump(-1)

M.parse_snippet_body(body, placeholders)
  ├─ Parse ${N:label} syntax
  └─ Create LuaSnip nodes
```

#### File Watching

```lua
Manager.watch_files()
  ├─ Create autocommand group
  ├─ Watch custom snippet directory
  └─ Reload on file save
```

### Data Flow: Snippet Expansion

```
VimScript: genero_tools#snippets#expand(trigger)
  ↓
Lua: M.expand_with_luasnip(trigger)
  ├─ M.get_snippet(trigger)
  ├─ Parse body for placeholders
  ├─ Create LuaSnip snippet object
  ├─ vim.api.nvim_buf_set_lines() - Insert at cursor
  ├─ vim.api.nvim_win_set_cursor() - Position cursor
  └─ ls.snip_expand() - Expand with LuaSnip
  ↓
LuaSnip: Expands snippet with placeholder support
  ↓
User: Tab/Shift+Tab to navigate placeholders
```

### Data Flow: Custom Snippet Hot-Reload

```
User: Save custom snippet file
  ↓
BufWritePost autocommand triggered
  ↓
Manager.watch_files() callback
  ├─ Clear custom_snippets cache
  ├─ Manager.load_custom()
  └─ Manager.register_with_luasnip()
  ↓
Custom snippets immediately available
```

---

## Configuration Flow

### Configuration Hierarchy

```
g:genero_tools_config
├─ snippets_enabled: 1
├─ snippet_engine: 'luasnip'
├─ snippet_smart_expansion: 1
├─ snippet_custom_dir: '~/.config/nvim/genero-snippets'
├─ snippet_list_selectable: 1
├─ snippet_expansion_mode: 'luasnip'
└─ autocomplete_include_snippets: 1
```

### Configuration Usage

```vim
" VimScript layer checks config
genero_tools#config#get('snippet_list_selectable')
  ├─ If 1: Use selectable list
  └─ If 0: Use basic list

genero_tools#config#get('snippet_expansion_mode')
  ├─ If 'luasnip': Use expand_with_luasnip()
  └─ Else: Use expand_by_name()

genero_tools#config#get('autocomplete_include_snippets')
  ├─ If 1: Include snippets in autocomplete
  └─ If 0: Skip snippets
```

---

## Keybinding Integration

### Snippet List Keybindings

```vim
" In snippet list floating window
<CR>      → genero_tools#snippets#select_snippet()
<Esc>     → genero_tools#snippets#close_snippet_list()
j/<Down>  → genero_tools#snippets#next_snippet()
k/<Up>    → genero_tools#snippets#prev_snippet()
<Mouse>   → genero_tools#snippets#mouse_select_snippet()
```

### Placeholder Navigation Keybindings

```vim
" In insert mode after snippet expansion
<Tab>     → genero_tools#snippets#next_placeholder_or_tab()
<S-Tab>   → genero_tools#snippets#prev_placeholder_or_tab()
```

### Autocomplete Keybindings

```vim
" In insert mode
<C-n>     → genero_tools#complete#omnifunc()
          → Includes snippets if enabled
```

---

## Error Handling

### VimScript Layer

```vim
try
  call luaeval('...')
catch
  call genero_tools#error#error('Snippets', 'Error message')
endtry
```

### Lua Layer

```lua
if not ok then
  vim.api.nvim_err_writeln('Error message')
  return false
end
```

### Graceful Degradation

1. **LuaSnip not available**: Show warning, disable snippets
2. **Snippet not found**: Show error, don't expand
3. **Lua error**: Log error, fall back to VimScript
4. **Neovim not available**: Disable snippets, show warning

---

## Performance Characteristics

### Snippet Loading
- Built-in snippets: ~10-50ms (one-time at startup)
- Custom snippets: ~5-20ms (one-time at startup)
- Hot-reload: ~5-10ms (on file save)

### Snippet Expansion
- Lookup: O(1) - constant time
- Expansion: ~1-5ms
- Placeholder navigation: <1ms

### Autocomplete Integration
- Snippet filtering: O(n) where n = snippet count
- Typical: <1ms for 100+ snippets
- No noticeable impact on autocomplete speed

### Memory Usage
- Built-in snippets: ~50-100KB
- Custom snippets: ~10-50KB
- Total: <200KB for typical usage

---

## Compatibility

### Vim vs Neovim

| Feature | Vim | Neovim |
|---------|-----|--------|
| Snippet list | ✗ | ✓ |
| Selection | ✗ | ✓ |
| Expansion | ✗ | ✓ |
| Autocomplete | ✓ | ✓ |
| Placeholders | ✗ | ✓ |

### Version Requirements

- **Neovim**: 0.5+ (0.6+ recommended)
- **LuaSnip**: Latest version
- **Lua**: 5.1+

---

## Extension Points

### Adding New Snippet Sources

```lua
-- In lua/genero_tools/snippets/init.lua
function M.load_external_snippets(source_name)
  -- Load snippets from external source
  -- Merge with existing snippets
  -- Re-register with LuaSnip
end
```

### Custom Expansion Modes

```lua
-- Support different expansion engines
if expansion_mode == 'vim-snipmate' then
  -- Use vim-snipmate expansion
elseif expansion_mode == 'ultisnips' then
  -- Use UltiSnips expansion
end
```

### Placeholder Processors

```lua
-- Process placeholders before expansion
function M.process_placeholder(placeholder)
  -- Custom processing logic
  -- Return processed placeholder
end
```

---

## Testing

### Unit Tests

- Snippet loading: `test/test_snippet_manager.lua`
- Snippet commands: `test/test_snippet_commands.lua`
- Integration: `test/test_task_8_integration.lua`

### Manual Testing

1. **Snippet list selection**
   ```vim
   :GeneroSnippetList
   " Test keyboard and mouse selection
   ```

2. **Autocomplete integration**
   ```vim
   " In insert mode
   Ctrl+N
   " Verify snippets appear
   ```

3. **Placeholder navigation**
   ```vim
   " After expanding snippet
   Tab/Shift+Tab
   " Verify placeholder jumping
   ```

4. **Custom snippets**
   ```bash
   # Create custom snippet
   mkdir -p ~/.config/nvim/genero-snippets
   # Edit snippet file
   # Verify hot-reload works
   ```

---

## Future Enhancements

### Planned Features

1. **Snippet Snippets**: Snippets for creating snippets
2. **Snippet Search**: Search snippets by description
3. **Snippet Categories**: Organize snippets by category
4. **Snippet Sharing**: Share snippets between users
5. **Snippet Validation**: Validate snippet syntax

### Optimization Opportunities

1. **Lazy Loading**: Load snippets on-demand
2. **Caching**: Cache compiled snippets
3. **Indexing**: Index snippets for faster search
4. **Compression**: Compress snippet storage

---

## Related Documentation

- [Snippet Configuration Guide](SNIPPET_CONFIGURATION.md)
- [Autocomplete Integration](AUTOCOMPLETE.md)
- [LuaSnip Documentation](https://github.com/L3MON4D3/LuaSnip)
- [Genero-Tools Architecture](../specs/display-enhancements/design.md)


# Snippet System Configuration Guide

**Last Updated**: March 22, 2026
**Status**: Complete
**Compatibility**: Neovim 0.5+ (Vim not supported)

---

## Overview

The Genero-Tools snippet system provides intelligent code snippet expansion with LuaSnip integration. Snippets support:
- Automatic expansion with placeholder navigation
- Keyboard and mouse selection from snippet list
- Integration with autocomplete menu
- Custom snippet directories
- Hot-reload of custom snippets

---

## Configuration Options

### Core Snippet Settings

```vim
" Enable/disable snippet system
snippets_enabled: 1

" Snippet expansion engine
snippet_engine: 'luasnip'

" Enable smart expansion (context-aware)
snippet_smart_expansion: 1

" Custom snippet directory
snippet_custom_dir: '~/.config/nvim/genero-snippets'
```

### Snippet List Selection

```vim
" Enable selection in snippet list (keyboard and mouse)
snippet_list_selectable: 1

" Snippet expansion mode
snippet_expansion_mode: 'luasnip'
```

### Autocomplete Integration

```vim
" Include snippets in autocomplete menu
autocomplete_include_snippets: 1
```

---

## Usage

### Listing Snippets

Display all available snippets with selection support:

```vim
:GeneroSnippetList
```

**Keyboard Controls**:
- `j/k` or `Up/Down` - Navigate snippets
- `Enter` - Select and expand snippet
- `Esc` - Cancel

**Mouse Controls**:
- Click on snippet to select and expand

### Expanding Snippets

#### Method 1: From Snippet List
```vim
:GeneroSnippetList
" Then select snippet with keyboard or mouse
```

#### Method 2: From Autocomplete Menu
```vim
" In insert mode, trigger autocomplete
Ctrl+N
" Snippets appear with [snippet] indicator
" Select snippet to expand
```

#### Method 3: Direct Expansion
```vim
:GeneroSnippet <trigger>
```

Example:
```vim
:GeneroSnippet function_def
```

### Placeholder Navigation

After expanding a snippet, navigate between placeholders:

**Keyboard Controls**:
- `Tab` - Jump to next placeholder
- `Shift+Tab` - Jump to previous placeholder

Example snippet with placeholders:
```
function ${1:function_name}(${2:parameters})
  ${3:body}
end function
```

After expansion, Tab moves through: function_name → parameters → body

### Snippet Help

Display detailed information about a specific snippet:

```vim
:GeneroSnippetHelp <trigger>
```

Example:
```vim
:GeneroSnippetHelp function_def
```

Shows:
- Snippet name and trigger
- Description
- Template body
- Placeholder information
- Usage instructions

---

## Snippet List Selection

### Visual Feedback

The snippet list displays:
- Snippet number `[N]`
- Trigger keyword
- Description

Example:
```
[1] function_def - Define a new function
[2] if_statement - If/else statement
[3] for_loop - For loop structure
```

Current selection is highlighted with `CursorLine` color.

### Selection Mechanism

**Keyboard Selection**:
1. Navigate with `j/k` or arrow keys
2. Press `Enter` to select
3. Snippet expands at cursor position

**Mouse Selection**:
1. Click on snippet line
2. Snippet expands at cursor position

**Cancel**:
- Press `Esc` to close without selecting

---

## Autocomplete Integration

### Snippet Completions

Snippets appear in autocomplete menu with:
- `[snippet]` kind indicator
- Trigger as completion word
- Description in menu

Example autocomplete menu:
```
function_def [snippet] Define a new function
if_statement [snippet] If/else statement
for_loop     [snippet] For loop structure
```

### Selecting from Autocomplete

1. Trigger autocomplete: `Ctrl+N`
2. Navigate to snippet (appears with `[snippet]` indicator)
3. Press `Enter` to select
4. Snippet expands with placeholder support

### Filtering Snippets

Snippets are filtered by typed prefix:

```vim
" Type 'func' to filter
func<Ctrl+N>
" Shows: function_def, function_call, etc.
```

---

## Custom Snippets

### Directory Structure

Custom snippets are stored in:
```
~/.config/nvim/genero-snippets/
```

### Creating Custom Snippets

Create a Lua file in the custom directory:

```lua
-- ~/.config/nvim/genero-snippets/my_snippets.lua

return {
  {
    trigger = 'mysnip',
    name = 'My Snippet',
    description = 'My custom snippet',
    body = [[
function my_function()
  -- Body here
end function
    ]],
    placeholders = {
      { label = 'function_name', type = 'text' },
      { label = 'body', type = 'text' },
    }
  }
}
```

### Snippet Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `trigger` | string | Yes | Keyword to trigger snippet |
| `name` | string | No | Display name |
| `description` | string | No | Short description |
| `body` | string | Yes | Snippet template |
| `placeholders` | array | No | Placeholder definitions |

### Hot-Reload

Custom snippets are automatically reloaded when saved:

1. Edit snippet file in `~/.config/nvim/genero-snippets/`
2. Save file (`:w`)
3. Snippet is immediately available

No restart required!

---

## Placeholder Syntax

### Basic Placeholders

Use `${N:label}` syntax for placeholders:

```
function ${1:function_name}(${2:parameters})
  ${3:body}
end function
```

Numbers determine navigation order:
- `${1:...}` - First placeholder (Tab jumps here)
- `${2:...}` - Second placeholder
- `${3:...}` - Third placeholder

### Placeholder Types

```lua
placeholders = {
  { label = 'name', type = 'text' },      -- Text input
  { label = 'type', type = 'choice' },    -- Choice selection
  { label = 'value', type = 'expression' }, -- Expression
}
```

---

## Keybindings

### Default Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+N` | Insert | Trigger autocomplete (includes snippets) |
| `Tab` | Insert | Jump to next placeholder |
| `Shift+Tab` | Insert | Jump to previous placeholder |

### Custom Keybindings

Configure in your init.vim:

```vim
" Custom snippet list keybinding
nnoremap <leader>sn :GeneroSnippetList<CR>

" Custom snippet help keybinding
nnoremap <leader>sh :GeneroSnippetHelp<Space>

" Custom snippet expand keybinding
nnoremap <leader>se :GeneroSnippet<Space>
```

---

## Troubleshooting

### Snippets Not Appearing in Autocomplete

**Problem**: Snippets don't show in autocomplete menu

**Solutions**:
1. Check `autocomplete_include_snippets` is enabled:
   ```vim
   let g:genero_tools_config = {
     \ 'autocomplete_include_snippets': 1,
     \ }
   ```

2. Verify snippets are loaded:
   ```vim
   :GeneroSnippetList
   ```

3. Check LuaSnip is installed:
   ```vim
   :lua require('luasnip')
   ```

### Snippet List Not Selectable

**Problem**: Snippet list shows but can't select items

**Solutions**:
1. Check `snippet_list_selectable` is enabled:
   ```vim
   let g:genero_tools_config = {
     \ 'snippet_list_selectable': 1,
     \ }
   ```

2. Verify Neovim version (0.5+):
   ```vim
   :version
   ```

3. Check Lua support:
   ```vim
   :lua print('Lua available')
   ```

### Placeholder Navigation Not Working

**Problem**: Tab/Shift+Tab don't jump between placeholders

**Solutions**:
1. Verify LuaSnip is installed and working:
   ```vim
   :lua require('luasnip').jumpable(1)
   ```

2. Check snippet has placeholders:
   ```vim
   :GeneroSnippetHelp <trigger>
   ```

3. Ensure you're in insert mode when using Tab

### Custom Snippets Not Loading

**Problem**: Custom snippets don't appear

**Solutions**:
1. Check custom directory exists:
   ```bash
   ls ~/.config/nvim/genero-snippets/
   ```

2. Create directory if needed:
   ```bash
   mkdir -p ~/.config/nvim/genero-snippets
   ```

3. Verify Lua syntax in snippet files:
   ```bash
   lua -c ~/.config/nvim/genero-snippets/my_snippets.lua
   ```

4. Check for errors in Neovim:
   ```vim
   :messages
   ```

---

## Performance Considerations

### Snippet Loading

- Built-in snippets: Loaded once at startup
- Custom snippets: Loaded once at startup, hot-reloaded on save
- Caching: Snippets cached in memory for fast access

### Autocomplete Performance

- Snippet filtering: O(n) where n = number of snippets
- Typical performance: <1ms for 100+ snippets
- No noticeable impact on autocomplete speed

### Placeholder Navigation

- Navigation: O(1) constant time
- No performance impact on editing

---

## Best Practices

### Snippet Design

1. **Keep triggers short**: 3-10 characters
2. **Use descriptive names**: Help users understand purpose
3. **Include placeholders**: Make snippets interactive
4. **Add descriptions**: Show in autocomplete menu
5. **Test thoroughly**: Verify expansion works correctly

### Organization

1. **Group related snippets**: One file per category
2. **Use consistent naming**: `function_def`, `function_call`, etc.
3. **Document complex snippets**: Add comments in Lua
4. **Version control**: Commit custom snippets to git

### Performance

1. **Limit snippet count**: Keep under 500 for best performance
2. **Avoid complex placeholders**: Simple text works best
3. **Cache frequently used**: Built-in snippets are cached
4. **Monitor loading time**: Check startup performance

---

## Examples

### Function Definition Snippet

```lua
{
  trigger = 'function_def',
  name = 'Function Definition',
  description = 'Define a new function',
  body = [[
function ${1:function_name}(${2:parameters})
  ${3:-- Function body}
end function
  ]],
}
```

### If Statement Snippet

```lua
{
  trigger = 'if_statement',
  name = 'If Statement',
  description = 'If/else statement',
  body = [[
if ${1:condition} then
  ${2:-- Then block}
else
  ${3:-- Else block}
end if
  ]],
}
```

### For Loop Snippet

```lua
{
  trigger = 'for_loop',
  name = 'For Loop',
  description = 'For loop structure',
  body = [[
for ${1:i} = ${2:start} to ${3:end}
  ${4:-- Loop body}
end for
  ]],
}
```

---

## Related Documentation

- [Snippet System Architecture](SNIPPET_ARCHITECTURE.md)
- [Autocomplete Integration](AUTOCOMPLETE.md)
- [Keybindings Reference](KEYBINDINGS.md)
- [LuaSnip Documentation](https://github.com/L3MON4D3/LuaSnip)

---

## Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review [Best Practices](#best-practices)
3. Check error messages: `:messages`
4. Verify configuration: `:echo g:genero_tools_config`


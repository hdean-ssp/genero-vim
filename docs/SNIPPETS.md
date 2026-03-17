# Genero Code Snippets

The Genero Code Snippets feature provides intelligent code snippet expansion for common Genero language patterns. This feature is **Neovim-only** and requires LuaSnip.

## Overview

Snippets enable you to quickly insert code templates with placeholder fields for customization. Available snippets include:

- Function definitions
- Control flow (if/else, for, while, case)
- Error handling (try/catch)
- Data structures (records, arrays)

## Requirements

- **Neovim 0.5+** (Lua support required)
- **LuaSnip** - Install via your plugin manager

**Note**: Snippet commands are only available in Neovim. Vim users can use basic snippet expansion with vim-snipmate or vim-vsnip.

### Installation

Add to your Neovim config:

```lua
-- Using lazy.nvim
{
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
}
```

## Quick Start

### Expand a Snippet

Type a snippet trigger and press Tab to expand:

```
fn<Tab>  →  FUNCTION function_name(parameters)
            END FUNCTION
```

### Navigate Placeholders

After expansion, use Tab/Shift+Tab to move between placeholders:

```
FUNCTION ${1:function_name}(${2:parameters})
          ↑ cursor here, press Tab to move to next
END FUNCTION
```

### List Available Snippets

```vim
:GeneroSnippetList
```

### Show Snippet Help

```vim
:GeneroSnippetHelp fn
```

## Available Snippets

### Function Patterns

| Trigger | Name | Description |
|---------|------|-------------|
| `fn` | Function Definition | Basic function with parameters |
| `fnr` | Function with Return | Function that returns a value |
| `fnv` | Function Returning Variable | Function with return variable |
| `fnp` | Function with Parameters | Function with typed parameters |

### Control Flow

| Trigger | Name | Description |
|---------|------|-------------|
| `if` | If Statement | Basic if condition |
| `ife` | If-Else Statement | If with else branch |
| `ifei` | If-Else If | If with multiple conditions |
| `ifm` | If with Multiple Conditions | If with AND/OR logic |
| `for` | For Loop | Basic for loop |
| `forc` | For Loop with Counter | For loop with counter variable |
| `while` | While Loop | Basic while loop |
| `whilec` | While Loop with Counter | While with counter |
| `whilet` | While True Loop | While true with break |
| `case` | Case Statement | Case/when statement |

### Data Structures

| Trigger | Name | Description |
|---------|------|-------------|
| `rec` | Record Definition | Define a record type |
| `arr` | Array Declaration | Array with size and type |
| `arrd` | Dynamic Array | Dynamic array without size |
| `arri` | Array of Integers | Integer array |
| `arrs` | Array of Strings | String array |
| `arrr` | Array of Records | Record array |
| `arrm` | Multidimensional Array | 2D or higher array |

### Error Handling

| Trigger | Name | Description |
|---------|------|-------------|
| `try` | Try-Catch | Error handling block |
| `tryf` | Try-Catch-Finally | Try with finally block |

## Smart Parameter Population (Neovim)

When you expand a function call snippet in Neovim, the plugin automatically queries function signatures and populates parameters:

```
CALL my_function(${1:param1 -- STRING}, ${2:param2 -- INTEGER})
```

This works for functions in your genero-tools API database.

## Configuration

Snippet configuration is stored in `g:genero_tools_config`. Default values:

```lua
vim.g.genero_tools_config = {
  snippets_enabled = true,                                    -- Enable/disable snippets
  snippet_engine = 'luasnip',                                 -- Snippet engine (luasnip, vim-snipmate, vim-vsnip)
  snippet_smart_expansion = true,                             -- Enable async parameter population
  snippet_custom_dir = expand('~/.config/nvim/genero-snippets') -- Custom snippet directory
}
```

Override defaults in your config:

```lua
vim.g.genero_tools_config = {
  snippets_enabled = true,
  snippet_engine = 'luasnip',
  snippet_smart_expansion = true,
  snippet_custom_dir = vim.fn.expand('~/.config/nvim/my-snippets'),
}
```

## Custom Snippets

Create custom snippets in `~/.config/nvim/genero-snippets/`:

```lua
-- ~/.config/nvim/genero-snippets/custom.lua
return {
  {
    trigger = "mysnip",
    name = "My Custom Snippet",
    description = "My custom code template",
    body = [[
      DEFINE ${1:variable} ${2:type}
      LET ${1:variable} = ${3:value}
    ]],
  },
}
```

Custom snippets are automatically loaded and take precedence over built-in snippets.

## Commands

### List Snippets

```vim
:GeneroSnippetList
```

Display all available snippets in a floating window with triggers and descriptions.

### Show Help

```vim
:GeneroSnippetHelp {trigger}
```

Display detailed help for a specific snippet including template and placeholder descriptions.

### Expand Snippet

```vim
:GeneroSnippet {trigger}
```

Programmatically expand a snippet by trigger name.

## Keybindings

Default keybindings (configure in your init.lua):

```lua
-- Expand snippet by trigger (abbreviation)
-- Type trigger and press Tab

-- Navigate placeholders
<Tab>       -- Next placeholder
<S-Tab>     -- Previous placeholder
<C-c>       -- Exit snippet mode
<Esc>       -- Exit snippet mode
```

## Troubleshooting

### Snippets not expanding

1. Verify LuaSnip is installed: `:lua require('luasnip')`
2. Check snippets are enabled: `:lua print(vim.g.genero_tools_config.snippets_enabled)`
3. Verify snippet exists: `:GeneroSnippetList`

### LuaSnip not found

Install LuaSnip:

```lua
{
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
}
```

### Custom snippets not loading

1. Create directory: `mkdir -p ~/.config/nvim/genero-snippets`
2. Add Lua file with snippet definitions
3. Restart Neovim or reload snippets

### Parameter population not working

1. Verify async module is available: `:lua require('genero_tools.async')`
2. Check function signature is in genero-tools database
3. Verify `snippet_smart_expansion` is enabled in config

## Vim Compatibility

Snippets are **Neovim-only** and require Lua support. Vim users can:

1. Use basic snippet expansion with vim-snipmate or vim-vsnip
2. Manually insert snippet templates using `:GeneroSnippetInsert`
3. Upgrade to Neovim for full snippet support

## Integration with Other Features

### With GeneroLookup

After looking up a function, you can expand a function call snippet with the looked-up function name.

### With Autocomplete

When autocomplete suggests a function, you can expand a function call snippet with the suggested function.

## Performance

Snippets are cached for performance:

- Built-in snippets loaded once at startup
- Custom snippets loaded on demand
- Function signatures cached with 1-hour TTL
- Hot-reload available for custom snippets

## See Also

- [NEOVIM.md](NEOVIM.md) - Neovim-specific features
- [QUICK_START.md](QUICK_START.md) - Getting started guide
- [init.lua.example](../init.lua.example) - Example Neovim configuration


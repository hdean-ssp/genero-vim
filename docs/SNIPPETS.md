# Genero Code Snippets

The Genero Code Snippets feature provides quick access to common Genero language patterns. This feature is **Neovim-only** and requires LuaSnip.

## Installation

Add LuaSnip to your plugin manager:

```lua
-- Using lazy.nvim
{
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
}
```

## Quick Start

Type a snippet trigger and press Tab to expand:

```
fn<Tab>  →  FUNCTION function_name(parameters)
            END FUNCTION
```

Use Tab/Shift+Tab to navigate between placeholders.

## Available Snippets

### Functions
| Trigger | Description |
|---------|-------------|
| `fn` | Function definition |
| `fnr` | Function with return type |
| `fnv` | Function returning variable |
| `fnp` | Function with typed parameters |

### Control Flow
| Trigger | Description |
|---------|-------------|
| `if` | If statement |
| `ife` | If-else statement |
| `ifei` | If-else if |
| `ifm` | If with multiple conditions |
| `for` | For loop |
| `forc` | For loop with counter |
| `while` | While loop |
| `whilec` | While loop with counter |
| `whilet` | While true loop |
| `case` | Case/when statement |

### Data Structures
| Trigger | Description |
|---------|-------------|
| `rec` | Record definition |
| `arr` | Array declaration |
| `arrd` | Dynamic array |
| `arri` | Integer array |
| `arrs` | String array |
| `arrr` | Record array |
| `arrm` | Multidimensional array |

### Error Handling
| Trigger | Description |
|---------|-------------|
| `try` | Try-catch block |
| `tryf` | Try-catch-finally |

## Commands

List all snippets:
```vim
:GeneroSnippetList
```

Show help for a snippet:
```vim
:GeneroSnippetHelp fn
```

Expand a snippet by name:
```vim
:GeneroSnippet fn
```

## Configuration

Enable/disable snippets:
```lua
vim.g.genero_tools_config.snippets_enabled = true
```

Disable smart parameter population:
```lua
vim.g.genero_tools_config.snippet_smart_expansion = false
```

## Smart Parameter Population

When you expand a function call snippet in Neovim, the plugin automatically queries function signatures and populates parameters:

```
CALL my_function(${1:param1 -- STRING}, ${2:param2 -- INTEGER})
```

This works for functions in your genero-tools API database.

## Integration with GeneroLookup

After looking up a function with `:GeneroLookup`, you can expand a function call snippet with the looked-up function name.

## See Also

- [NEOVIM.md](NEOVIM.md) - Neovim-specific features
- [QUICK_START.md](QUICK_START.md) - Getting started guide

# Completion Priority Configuration

## Overview

The completion system prioritizes suggestions in the following order:
1. **Genero-Tools** - Functions from your Genero codebase (highest priority)
2. **LSP** - Language server completions (for non-Genero files)
3. **LuaSnip** - Snippet completions
4. **Buffer** - Words from current buffer, with proximity-based ranking
5. **Path** - File system paths (lowest priority)

## Priority Levels

```lua
sources = cmp.config.sources({
  { name = "genero",   priority = 1100 },  -- Highest priority
  { name = "nvim_lsp", priority = 1000 },
  { name = "luasnip",  priority = 750 },
  { name = "buffer",   priority = 500 },
  { name = "path",     priority = 250 },   -- Lowest priority
}),
```

## Buffer Completion with Proximity

Buffer completions are sorted by proximity to the cursor position. Words closer to your current position appear higher in the list.

### Configuration

```lua
{ 
  name = "buffer",
  priority = 500,
  option = {
    -- Only search current buffer
    get_bufnrs = function()
      return { vim.api.nvim_get_current_buf() }
    end,
    keyword_pattern = [[\k\+]],
    -- Minimum 3 characters to trigger
    keyword_length = 3,
  }
},
```

### How Proximity Works

When you type a partial word, buffer completions are ranked by:
1. **Distance from cursor** - Closer matches rank higher
2. **Recently used** - Recently selected items rank higher
3. **Exact match** - Exact prefix matches rank higher than fuzzy matches

### Example

```4gl
FUNCTION test()
    LET local_var = 1
    LET another_var = 2
    
    # 100 lines later...
    
    LET x = loc|  # Typing "loc" here
END FUNCTION
```

Completion order:
1. `local_var` (from genero-tools if it's a known function)
2. `local_var` (from buffer, closer to cursor)
3. `another_var` (from buffer, further from cursor)

## Sorting Comparators

The completion list uses multiple comparators in order:

```lua
sorting = {
  priority_weight = 2,
  comparators = {
    require("cmp").config.compare.score,          -- Match quality
    require("cmp").config.compare.recently_used,  -- Recently selected
    require("cmp").config.compare.locality,       -- Proximity to cursor
    require("cmp").config.compare.kind,           -- Item type (function, variable, etc.)
    require("cmp").config.compare.sort_text,      -- Alphabetical
    require("cmp").config.compare.length,         -- Shorter items first
    require("cmp").config.compare.order,          -- Source order
  },
},
```

### Comparator Priority

1. **score** - How well the item matches what you typed
2. **recently_used** - Items you've selected recently
3. **locality** - Distance from cursor (for buffer completions)
4. **kind** - Functions before variables, etc.
5. **sort_text** - Alphabetical order
6. **length** - Shorter completions first
7. **order** - Source registration order

## Source Labels

Completion items show their source in the menu:

```
function_name    [Genero]   # From genero-tools
local_var        [Buf]      # From buffer
path/to/file     [Path]     # From filesystem
snippet_trigger  [Snippet]  # From LuaSnip
```

## Genero-Tools Priority

### Why Genero-Tools is Highest Priority

Genero-Tools completions are given highest priority because they:
- Come from your actual codebase
- Include function signatures
- Are context-aware (module-scoped)
- Provide accurate type information

### Genero-Tools Completion Features

1. **Module-scoped functions** - Functions from current module
2. **Project-wide search** - Falls back to entire project
3. **Function signatures** - Shows parameters and return types
4. **Smart filtering** - Only shows relevant completions

### Example

```4gl
FUNCTION test()
    CALL cust|  # Typing "cust"
END FUNCTION
```

Completion order:
1. `customer_get_by_id()` - [Genero] From your codebase
2. `customer_update()` - [Genero] From your codebase
3. `custom_function()` - [Genero] From your codebase
4. `customer` - [Buf] Variable from buffer
5. `customer_id` - [Buf] Variable from buffer

## Customization

### Change Priority Levels

Edit `init.lua`:

```lua
sources = cmp.config.sources({
  { name = "genero",   priority = 2000 },  -- Even higher priority
  { name = "buffer",   priority = 1000 },  -- Increase buffer priority
  { name = "nvim_lsp", priority = 500 },   -- Decrease LSP priority
  -- ... other sources
}),
```

### Disable Proximity Sorting

Remove `locality` comparator:

```lua
sorting = {
  comparators = {
    require("cmp").config.compare.score,
    require("cmp").config.compare.recently_used,
    -- require("cmp").config.compare.locality,  -- Disabled
    require("cmp").config.compare.kind,
    -- ... other comparators
  },
},
```

### Search All Buffers

Change buffer source to search all open buffers:

```lua
{ 
  name = "buffer",
  priority = 500,
  option = {
    get_bufnrs = function()
      return vim.api.nvim_list_bufs()  -- All buffers
    end,
  }
},
```

### Increase Minimum Characters

Require more characters before triggering buffer completion:

```lua
{ 
  name = "buffer",
  priority = 500,
  option = {
    keyword_length = 5,  -- Require 5 characters
  }
},
```

## Performance Considerations

### Buffer Completion Performance

Searching the entire buffer can be slow for large files. The configuration limits this by:
- Only searching current buffer (not all open buffers)
- Requiring minimum 3 characters
- Using efficient proximity algorithm

### Genero-Tools Performance

Genero-Tools uses caching to avoid repeated queries:
- Cache TTL: 3600 seconds (1 hour)
- Module-scoped search first (fast)
- Project-wide search as fallback (slower)

### Optimization Tips

1. **Increase keyword_length** for buffer completions:
   ```lua
   keyword_length = 4,  -- Require 4 characters
   ```

2. **Disable buffer completions** for large files:
   ```lua
   enabled = function()
     local line_count = vim.api.nvim_buf_line_count(0)
     return line_count < 10000  -- Disable for files > 10k lines
   end,
   ```

3. **Increase cache TTL** for genero-tools:
   ```lua
   vim.g.genero_tools_config = {
     cache_ttl = 7200,  -- 2 hours
   }
   ```

## Troubleshooting

### Genero Completions Not Appearing

1. Check if genero-tools is loaded:
   ```vim
   :lua print(vim.inspect(require('cmp').get_config().sources))
   ```

2. Verify filetype:
   ```vim
   :set filetype?
   ```
   Should be: `4gl`, `fgl`, or `per`

3. Check genero-tools path:
   ```vim
   :GeneroConfigShow
   ```

### Buffer Completions Too Slow

1. Increase minimum characters:
   ```lua
   keyword_length = 5,
   ```

2. Limit to smaller region:
   ```lua
   -- Only search 1000 lines around cursor
   get_bufnrs = function()
     local buf = vim.api.nvim_get_current_buf()
     local cursor = vim.api.nvim_win_get_cursor(0)
     -- Custom logic to limit search region
     return { buf }
   end,
   ```

### Wrong Priority Order

1. Check priority values:
   ```vim
   :lua print(vim.inspect(require('cmp').get_config().sources))
   ```

2. Verify sorting comparators:
   ```vim
   :lua print(vim.inspect(require('cmp').get_config().sorting))
   ```

3. Check if another plugin is overriding:
   ```vim
   :verbose lua print(vim.inspect(require('cmp').get_config()))
   ```

## Related Documentation

- [AUTOCOMPLETE.md](AUTOCOMPLETE.md) - General autocomplete documentation
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [nvim-cmp documentation](https://github.com/hrsh7th/nvim-cmp) - Official cmp docs

## References

- nvim-cmp comparators: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/compare.lua
- Buffer source options: https://github.com/hrsh7th/cmp-buffer
- Source priorities: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources

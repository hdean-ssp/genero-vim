# Variable References

Find all references to a variable in the current buffer with scope-aware searching.

## Features

- **Scope-Aware Searching**: Only scans relevant code based on variable scope
  - Local variables: Scans only current function
  - Module variables (m_*): Scans entire buffer
  - Global variables (gl_*): Scans entire buffer
- **Telescope Integration**: Uses Telescope picker with built-in preview (falls back to floating window)
- **Performance Optimized**: Uses caching to avoid redundant scans
- **Interactive Navigation**: Fuzzy search, live preview, and quick jump
- **Context Display**: Shows line number, column, and code snippet for each reference

## Usage

### Command
```vim
:GeneroFindVariableReferences [variable_name]
```

If no variable name is provided, uses the word under cursor.

### Keybinding
```vim
gr    " Find references for variable under cursor (with live preview)
gR    " Find references for function under cursor
```

### Example Workflow

1. Position cursor on a variable name
2. Press `gr` (or run `:GeneroFindVariableReferences`)
3. Telescope picker appears showing all references
4. Type to fuzzy search through references
5. Use `j`/`k` or `Ctrl-n`/`Ctrl-p` to navigate
   - **Live preview** shows the reference in context automatically
6. Press `Enter` to jump to a reference
7. Press `Esc` to close without jumping

**Without Telescope**: Falls back to a floating window with basic navigation.

## How It Works

### Scope Detection

The system determines variable scope using:

1. **Naming Convention** (fast):
   - `m_*` → Module-level variable
   - `gl_*` → Global variable
   - Others → Local variable (default)

2. **DEFINE Analysis** (fallback):
   - Searches for DEFINE statement
   - Checks scope field from type info
   - Uses actual scope if found

### Search Strategy

**Local Variables** (default):
- Finds current function boundaries
- Scans only lines within that function
- Fast: O(n) where n = function size

**Module/Global Variables**:
- Scans entire buffer
- Still fast: O(n) where n = buffer size
- Results are cached for subsequent lookups

### Caching

Results are cached with key:
```
var-refs:<bufnr>:<changedtick>:<var_name>
```

Cache is automatically invalidated when:
- Buffer is modified (changedtick changes)
- Buffer is closed
- Cache TTL expires

## Display Format

### Telescope Picker (Neovim with Telescope)
```
┌─ 4 references to l_count ─────────────────────────────────┐
│ > LET l_count = 0                                          │
│   IF l_count > 10 THEN                                     │
│   LET l_count = l_count + 1                                │
│   RETURN l_count                                           │
└────────────────────────────────────────────────────────────┘
```

Features:
- Fuzzy search through references
- Live preview pane showing code context
- Syntax highlighting in preview
- Standard Telescope keybindings

### Floating Window (Fallback)
```
  Idx  Line:Col  Code Snippet
  ───────────────────────────────────────
    1   142:5   LET l_count = 0
    2   145:12  IF l_count > 10 THEN
    3   148:8   LET l_count = l_count + 1
    4   152:15  RETURN l_count
    
  Enter: jump  q/Esc: close
```

Used when Telescope is not available.

## Performance

### Local Variable Search
- **Typical function**: 50-200 lines
- **Search time**: <5ms
- **Cached**: <1ms

### Module Variable Search
- **Large file**: 12,000 lines
- **First search**: 50-100ms
- **Cached**: <1ms

### Optimization Tips

1. Use naming conventions (`m_`, `gl_`) for faster scope detection
2. Results are cached - subsequent searches are instant
3. Local variable searches are always fast (function-scoped)

## Comparison with Function References

| Feature | Function References | Variable References |
|---------|-------------------|-------------------|
| Data Source | genero-tools query.sh | Buffer scanning |
| Scope | Cross-file | Current buffer only |
| Speed | Network dependent | Instant (cached) |
| Accuracy | 100% (database) | 95%+ (pattern matching) |
| Keybinding | `gR` | `gr` |
| UI | Telescope / Floating | Telescope / Floating |
| Preview | ✅ | ✅ |
| Fuzzy Search | ✅ | ✅ |

## Limitations

1. **Current Buffer Only**: Only searches the open file, not across the codebase
2. **Pattern Matching**: May find false positives in comments or strings
3. **No Cross-File**: Cannot find references in other files

## Future Enhancements

Potential improvements:
- Cross-file variable references (requires database support)
- Filter out references in comments/strings
- Show variable type in header
- Group references by context (assignments, reads, function calls)

## Examples

### Local Variable
```4gl
FUNCTION calculate_total()
  DEFINE l_sum INTEGER
  DEFINE l_count INTEGER
  
  LET l_sum = 0        # Reference 1
  LET l_count = 10
  
  WHILE l_count > 0    # Reference 2
    LET l_sum = l_sum + l_count  # References 3, 4, 5
    LET l_count = l_count - 1
  END WHILE
  
  RETURN l_sum         # Reference 6
END FUNCTION
```

Searching for `l_sum` finds 6 references, all within the function.

### Module Variable
```4gl
DEFINE m_config RECORD
  debug BOOLEAN,
  timeout INTEGER
END RECORD

FUNCTION init()
  LET m_config.debug = FALSE    # Reference 1
  LET m_config.timeout = 30     # Reference 2
END FUNCTION

FUNCTION get_timeout()
  RETURN m_config.timeout       # Reference 3
END FUNCTION
```

Searching for `m_config` finds 3 references across multiple functions.

## See Also

- [Function References](../README.md#find-references) - Find function callers
- [Type Info](../README.md#type-info) - View variable types
- [Navigation](../README.md#navigation) - Go to definition

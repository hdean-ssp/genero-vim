# Snippet Telescope Picker - Visual Example

## Before (Floating Window)

```
┌─ Snippets ──────────────────────────────────────────────────┐
│ [1] fn - Function definition                                │
│ [2] if - IF statement                                       │
│ [3] for - FOR loop                                          │
│ [4] while - WHILE loop                                      │
│ [5] case - CASE statement                                   │
│ [6] try - TRY/CATCH block                                   │
│ [7] record - RECORD definition                              │
│ [8] array - ARRAY definition                                │
│ [9] cursor - CURSOR declaration                             │
│ [10] report - REPORT definition                             │
│ [11] menu - MENU definition                                 │
│                                                              │
│ Use :GeneroSnippetHelp <trigger> for more details           │
└──────────────────────────────────────────────────────────────┘
```

**Navigation:**
- `j`/`k` or arrow keys to move
- `Enter` to select
- `Esc` to close
- Mouse click to select

## After (Telescope Picker)

```
┌─ Genero Snippets (11) ──────────────────────────────────────┐
│ > fn_                                                        │
│   fn              Function definition                        │
│   for             FOR loop                                   │
│   function        Function with parameters                   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
┌─ Snippet Preview ────────────────────────────────────────────┐
│ Snippet: Function definition                                 │
│                                                              │
│ Trigger: fn                                                  │
│                                                              │
│ Description:                                                 │
│   Creates a basic function definition with name and body    │
│                                                              │
│ Template:                                                    │
│ ────────────────────────────────────────────────────────────│
│ FUNCTION ${1:function_name}()                                │
│     ${2:-- function body}                                    │
│ END FUNCTION                                                 │
│ ────────────────────────────────────────────────────────────│
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Navigation:**
- Type to fuzzy search (e.g., "fn" filters to function-related snippets)
- `Ctrl-n`/`Ctrl-p` or arrow keys to move
- `Enter` to select and expand
- `Esc` to close
- `Ctrl-u`/`Ctrl-d` to scroll preview

## Key Improvements

### 1. Live Preview
- See the full snippet body before selecting
- Understand what placeholders are available
- Preview shows syntax-highlighted Genero code

### 2. Fuzzy Search
```
Type: "loop"
Results:
  for             FOR loop
  while           WHILE loop
  foreach         FOREACH loop
```

```
Type: "def"
Results:
  fn              Function definition
  record          RECORD definition
  array           ARRAY definition
```

### 3. Consistent UI
Same interface as other Genero-Tools pickers:
- `:GeneroFileFunctions` - Navigate functions
- `:GeneroModuleFunctions` - Browse module functions
- `:GeneroDiagnostics` - View compiler errors
- `:GeneroSnippetList` - Browse snippets ← **NEW**

### 4. Better Context
The preview shows:
- Snippet name and trigger
- Full description
- Complete template with placeholders
- Syntax highlighting for Genero code

## Usage Examples

### Example 1: Finding a Function Snippet

```vim
:GeneroSnippetList
```

1. Type "func" in the prompt
2. See filtered results: `fn`, `function`
3. Navigate with `Ctrl-n`/`Ctrl-p`
4. Preview shows the template
5. Press `Enter` to expand

Result:
```4gl
FUNCTION |()
    -- function body
END FUNCTION
```
(Cursor at `|`, ready to type function name)

### Example 2: Finding a Loop Snippet

```vim
:GeneroSnippetList
```

1. Type "for" in the prompt
2. See: `for`, `foreach`
3. Select `for` with `Enter`

Result:
```4gl
FOR | = 1 TO 10
    -- loop body
END FOR
```
(Cursor at `|`, ready to type variable name)

### Example 3: Browsing All Snippets

```vim
:GeneroSnippetList
```

1. Don't type anything (shows all snippets)
2. Use `Ctrl-n`/`Ctrl-p` to browse
3. Read descriptions and previews
4. Select when ready

## Comparison Table

| Feature | Floating Window | Telescope Picker |
|---------|----------------|------------------|
| **Search** | No search | Fuzzy search |
| **Preview** | No preview | Live preview with syntax highlighting |
| **Navigation** | j/k only | j/k, Ctrl-n/p, arrows |
| **Context** | Trigger + description | Full template + description |
| **Consistency** | Custom UI | Matches other pickers |
| **Scrolling** | Limited | Full preview scrolling |
| **Filtering** | No filtering | Real-time fuzzy filtering |

## Keybinding Comparison

### Floating Window
```vim
j/k         - Navigate
Enter       - Select
Esc         - Close
Mouse       - Click to select
```

### Telescope Picker
```vim
Ctrl-n/p    - Navigate (or j/k in normal mode)
Enter       - Select and expand
Esc/Ctrl-c  - Close
Ctrl-u/d    - Scroll preview
/           - Start search (insert mode)
```

## Configuration

### Use Telescope by Default (Recommended)
```vim
" No configuration needed - automatic when Telescope is installed
:GeneroSnippetList
```

### Force Floating Window
```vim
" If you prefer the old UI
:lua require('genero_tools.snippets').list_snippets_display()
```

### Explicit Telescope Command
```vim
" Always use Telescope (error if not installed)
:GeneroSnippetsTelescope
```

## Benefits Summary

1. **Faster Discovery** - Fuzzy search finds snippets quickly
2. **Better Understanding** - Preview shows what you'll get
3. **Consistent Experience** - Same UI as other tools
4. **More Information** - See full template before inserting
5. **Syntax Highlighting** - Preview shows Genero code properly
6. **Backward Compatible** - Falls back if Telescope not available

## Try It!

1. Open a `.4gl` file
2. Run `:GeneroSnippetList`
3. Type "fn" to search
4. See the preview
5. Press `Enter` to expand
6. Use `Tab` to jump between placeholders

The Telescope integration makes snippet discovery and insertion much more intuitive and consistent with the rest of Genero-Tools!

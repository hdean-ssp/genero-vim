# Help Window Preview

## What the Help Window Looks Like

When you run `:GeneroHelp` or press `<Space>gh`, you'll see a large floating window like this:

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    Genero Tools - Comprehensive Help                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

COMPILATION:
────────────────────────────────────────────────────────────────────────────────
  F5                   :GeneroCompile              Compile current file
  <Space>ca            :GeneroAutocompileEnable    Enable autocompile on save
  <Space>cd            :GeneroAutocompileDisable   Disable autocompile on save
  <Space>cc            :GeneroClearErrors          Clear error markers
  <Space>ce                                        Filter: show errors only
  <Space>cw                                        Filter: show warnings only
  <Space>cx                                        Filter: show all diagnostics
  <Space>cD            :GeneroDiagnostics          Diagnostics picker (Telescope)

NAVIGATION:
────────────────────────────────────────────────────────────────────────────────
  ]d / [d                                          Next/previous error or warning
  ]h / [h                                          Next/previous code hint
  ]b / [b                                          Next/previous buffer
  ]] / [[                                          Next/previous temp tag (#TMP<initials>)
  gd                                               Go to definition (jump to source)
  gp                                               Peek definition (preview in float)
  gr                                               Find references (all callers)
  Ctrl+h/j/k/l                                     Navigate between windows
  <Space>bd            :bdelete                    Delete current buffer

GENERO TOOLS:
────────────────────────────────────────────────────────────────────────────────
  <Space>gl            :GeneroLookup               Lookup function definition
  <Space>gf            :GeneroListFunctions        List functions in file
  <Space>gs            :GeneroFunctionSignature    Get function signature
  <Space>gm            :GeneroFileMetadata         Get file metadata
  <Space>gd            :GeneroDebugStreamToggle    Toggle debug stream
  <Space>gr            :GeneroFindReferences       Find all function callers
  <Space>gF            :GeneroFileFunctions        File functions (Telescope)
  <Space>gM            :GeneroModuleFunctions      Module functions (Telescope)
  <Space>gS            :GeneroModuleFiles          Module sibling files

CODE HINTS:
────────────────────────────────────────────────────────────────────────────────
  <Space>hl            :GeneroListHints            List all hints in file
  <Space>hd            :GeneroHintDetails          Show hint details
  <Space>hf            :GeneroHintAutofix          Apply auto-fix for hint
  <Space>hh            :GeneroHintHelp             Show hint documentation
  ]h / [h                                          Navigate to next/previous hint

... (more categories) ...

KEY FEATURES:
────────────────────────────────────────────────────────────────────────────────
  •                                                Go to definition (gd) and peek (gp)
  •                                                Find references with Telescope preview
  •                                                Function signature & type hover
  •                                                Schema/table/column lookup
  •                                                Block matching highlights (IF/END IF)
  •                                                Statusline breadcrumb with ref count
  •                                                Module-scoped autocomplete
  •                                                TODO/BUG/FIX/TMP highlighting
  •                                                Auto-close blocks (IF→END IF)
  •                                                Inline diagnostics (errors always visible)
  •                                                Code hints with auto-fix
  •                                                Autocompile on save (500ms delay)
  •                                                SVN diff markers (auto-refresh)
  •                                                Bracket navigation: ]d ]h ]b ]]

TIPS & TRICKS:
────────────────────────────────────────────────────────────────────────────────
  •                                                Press <Space> to see keybindings (which-key)
  •                                                Use ]d/[d for errors, ]h/[h for hints
  •                                                Use ]]/[[ to jump between #TMP tags
  •                                                gd jumps, gp peeks without moving
  •                                                gr shows all callers with preview
  •                                                <Space>gF picks functions in file
  •                                                <Space>gM picks functions in module
  •                                                <Space>gS switches module sibling files
  •                                                <Space>cD browses errors with preview
  •                                                Hover on function to see signature
  •                                                Hover on variable to see type
  •                                                Hover on table to see all columns
  •                                                Ctrl+\ for quick terminal access
  •                                                <Space>fw searches word in project
  •                                                :TodoTelescope finds all TODO tags

╔══════════════════════════════════════════════════════════════════════════════╗
║  Navigation: j/k or ↑/↓ to scroll  •  q or Esc to close  •  / to search     ║
║  Press ? for command mode  •  :GeneroHelp to reopen  •  <Space> for which-key║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Window Features

### Size and Position
- **Width**: 85% of your terminal width
- **Height**: 85% of your terminal height
- **Position**: Centered on screen
- **Border**: Rounded corners with title

### Colors (Syntax Highlighting)
- **Headers** (╔═╗ ║ ╚═╝): Highlighted as Title (bright)
- **Categories** (COMPILATION:): Highlighted as Function (cyan/blue)
- **Separators** (────): Highlighted as Comment (gray)
- **Keybindings** (<Space>gl): Highlighted as Identifier (yellow/orange)
- **Commands** (:GeneroLookup): Highlighted as Keyword (purple/magenta)
- **Bullets** (•): Highlighted as Special (red/orange)

### Navigation
```
j / k          Scroll down/up one line
Ctrl+d / Ctrl+u  Page down/up
G              Jump to end
gg             Jump to beginning
/              Start search
n / N          Next/previous search result
q / Esc        Close window
```

## Usage Scenarios

### Scenario 1: Quick Keybinding Lookup
```
1. Press <Space>gh
2. Window opens instantly
3. Scan for your category (e.g., "NAVIGATION")
4. Find the keybinding you need
5. Press q to close
```

### Scenario 2: Learning New Features
```
1. Run :GeneroHelp
2. Scroll through categories with j/k
3. Read descriptions of features
4. Try commands in another window
5. Keep help open for reference
```

### Scenario 3: Finding a Specific Command
```
1. Press <Space>gh
2. Press / to search
3. Type "snippet" (or whatever you're looking for)
4. Press n to jump to next match
5. Press q when done
```

### Scenario 4: Reference While Coding
```
1. Open help: :GeneroHelp
2. Switch to code window: Ctrl+h
3. Reference help as needed: Ctrl+l
4. Toggle off when done: <Space>gh
```

## Comparison: Old vs New

### Old Help (Echo-based)
```vim
:GeneroHelp

" Output scrolls in command area:
COMPILATION:
  F5              - Compile current file
  Space+ca        - Enable autocompile on save
  ...
" (content disappears after scrolling)
" (can't search or navigate)
" (limited screen space)
```

### New Help (Floating Window)
```vim
:GeneroHelp

" Opens large, persistent floating window
" Full navigation support (j/k, G/gg, Ctrl+d/u)
" Searchable with /
" Stays open until you close it
" 85% of screen for maximum content
" Syntax highlighted for readability
```

## Tips for Best Experience

1. **Use a Large Terminal**: The help window is 85% of your screen, so a larger terminal gives you more content at once.

2. **Learn the Navigation Keys**: 
   - `j`/`k` for line-by-line scrolling
   - `Ctrl+d`/`u` for page scrolling
   - `G`/`gg` for jumping to end/beginning

3. **Use Search**: Press `/` and type keywords to quickly find what you need.

4. **Keep It Open**: The window is persistent - you can switch to other windows and come back.

5. **Combine with which-key**: Use `<Space>` for context-sensitive hints, `<Space>gh` for comprehensive reference.

## Accessibility

- **Keyboard-only**: All navigation via keyboard
- **No mouse required**: Pure keyboard workflow
- **Screen reader friendly**: Plain text content
- **High contrast**: Syntax highlighting uses standard colors
- **Resizable**: Adapts to terminal size

## Platform Support

### Neovim
✅ Full floating window support
✅ Syntax highlighting
✅ All navigation features
✅ Toggle functionality

### Vim 8.1+
⚠️ Falls back to echo-based help
⚠️ No floating window (Vim limitation)
✅ Same comprehensive content
✅ All commands still work

## See Also

- [HELP_SYSTEM.md](HELP_SYSTEM.md) - Full help system documentation
- [README.md](../README.md) - Main plugin documentation
- [SETUP.md](../SETUP.md) - Installation guide

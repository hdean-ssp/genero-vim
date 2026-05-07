# Genero Tools Quick Reference Card

## Essential Keybindings

### Help & Discovery
| Key | Action |
|-----|--------|
| `<Space>gh` | Toggle help window |
| `<Space>` | Show which-key menu |
| `:GeneroHelp` | Open comprehensive help |

### Compilation
| Key | Action |
|-----|--------|
| `F5` | Compile current file |
| `<Space>ca` | Enable autocompile |
| `<Space>cd` | Disable autocompile |
| `<Space>cc` | Clear error markers |
| `<Space>cD` | Browse diagnostics (Telescope) |

### Navigation
| Key | Action |
|-----|--------|
| `]d` / `[d` | Next/previous error |
| `]h` / `[h` | Next/previous hint |
| `]b` / `[b` | Next/previous buffer |
| `]]` / `[[` | Next/previous #TMP tag |
| `gd` | Go to definition |
| `gp` | Peek definition |
| `gr` | Find references |

### Genero Tools
| Key | Action |
|-----|--------|
| `<Space>gl` | Lookup function |
| `<Space>gf` | List functions in file |
| `<Space>gF` | File functions (Telescope) |
| `<Space>gM` | Module functions (Telescope) |
| `<Space>gS` | Module sibling files |
| `<Space>gr` | Find references |

### Code Hints
| Key | Action |
|-----|--------|
| `<Space>hl` | List all hints |
| `<Space>hd` | Show hint details |
| `<Space>hf` | Apply auto-fix |
| `]h` / `[h` | Navigate hints |

### SVN & Signs
| Key | Action |
|-----|--------|
| `<Space>sv` | Toggle SVN markers |
| `<Space>sr` | Refresh SVN markers |
| `<Space>ss` | Show SVN status |
| `<Space>su` | Toggle unified signs |

### Snippets
| Key | Action |
|-----|--------|
| `<Space>sl` | List snippets |
| `<Space>sh` | Snippet help |
| `Tab` | Expand/next placeholder |
| `Shift+Tab` | Previous placeholder |

### Autocomplete
| Key | Action |
|-----|--------|
| `Ctrl+Space` | Trigger completion |
| `Tab` / `Shift+Tab` | Navigate suggestions |
| `Enter` | Accept suggestion |
| `Ctrl+e` | Close menu |
| `Ctrl+u` / `Ctrl+d` | Scroll docs |

### Terminal
| Key | Action |
|-----|--------|
| `Ctrl+\` | Toggle terminal |
| `<Space>tf` | Floating terminal |
| `<Space>th` | Horizontal terminal |
| `<Space>tv` | Vertical terminal |
| `Esc` | Exit terminal mode |

### Search (Telescope)
| Key | Action |
|-----|--------|
| `<Space>fw` | Search word under cursor |
| `<Space>fg` | Live grep |
| `<Space>ff` | Find files |
| `<Space>fb` | Search buffers |

### Window Management
| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Navigate windows |
| `Ctrl+Up/Down` | Navigate splits vertically |
| `Ctrl+Left/Right` | Navigate splits horizontally |

### Commenting
| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gbc` | Toggle block comment |
| `gc` | Toggle comment (visual) |
| `gcO` | Add comment above |
| `gco` | Add comment below |

## Essential Commands

### Compilation
```vim
:GeneroCompile              " Compile current file
:GeneroAutocompileEnable    " Enable autocompile
:GeneroAutocompileDisable   " Disable autocompile
:GeneroClearErrors          " Clear error markers
:GeneroDiagnostics          " Browse diagnostics
```

### Navigation
```vim
:GeneroLookup               " Lookup function
:GeneroGotoDefinition       " Jump to definition
:GeneroPeekDefinition       " Preview definition
:GeneroFindReferences       " Find all callers
:GeneroFileFunctions        " File functions picker
:GeneroModuleFunctions      " Module functions picker
:GeneroModuleFiles          " Module sibling files
```

### Code Hints
```vim
:GeneroListHints            " List all hints
:GeneroHintDetails          " Show hint details
:GeneroHintAutofix          " Apply auto-fix
:GeneroNextHint             " Jump to next hint
:GeneroPrevHint             " Jump to previous hint
```

### SVN Integration
```vim
:GeneroSVNToggle            " Toggle SVN markers
:GeneroSVNRefresh           " Refresh SVN markers
:GeneroSVNStatus            " Show SVN status
:GeneroUnifiedSignsToggle   " Toggle unified signs
```

### Snippets
```vim
:GeneroSnippetList          " List all snippets
:GeneroSnippetHelp          " Show snippet help
```

### Debug Streaming
```vim
:GeneroDebugStreamToggle    " Toggle debug stream
:GeneroDebugStream          " Start debug stream
:GeneroDebugStreamStop      " Stop debug stream
```

### Configuration
```vim
:GeneroConfigShow           " Show configuration
:GeneroClearCache           " Clear result cache
:GeneroCompleteEnable       " Enable autocomplete
:GeneroCompleteDisable      " Disable autocomplete
```

### Help
```vim
:GeneroHelp                 " Open help window
:GeneroHelpToggle           " Toggle help window
:GeneroHelpClose            " Close help window
```

## Key Features at a Glance

### Code Intelligence
- ✅ Go to definition (gd) and peek (gp)
- ✅ Find references with preview (gr)
- ✅ Function signature hover
- ✅ Variable type resolution
- ✅ Schema/table/column lookup
- ✅ Module-scoped autocomplete

### Visual Feedback
- ✅ Block matching highlights (IF/END IF)
- ✅ Quote matching highlights
- ✅ Statusline breadcrumb
- ✅ Reference count display
- ✅ Inline diagnostics
- ✅ Sign column markers

### Productivity
- ✅ Autocompile on save
- ✅ Code hints with auto-fix
- ✅ Code snippets
- ✅ Auto-close blocks
- ✅ SVN diff markers
- ✅ Telescope pickers

### Navigation
- ✅ Bracket-style navigation (]d, ]h, ]b, ]])
- ✅ Error/warning navigation
- ✅ Hint navigation
- ✅ Buffer navigation
- ✅ Temp tag navigation (#TMP)

## Workflow Tips

### Starting a Session
1. Open Neovim with a .4gl file
2. Press `<Space>` to see available commands
3. Press `<Space>gh` for comprehensive help
4. Start coding - autocompile is enabled by default

### Fixing Errors
1. Save file (autocompile runs)
2. Use `]d` to jump to first error
3. Fix the error
4. Use `]d` again for next error
5. Or use `<Space>cD` to browse all errors

### Exploring Code
1. Hover on function to see signature
2. Press `gd` to jump to definition
3. Press `gp` to peek without jumping
4. Press `gr` to see all callers
5. Use `<Space>gF` to pick functions in file

### Using Hints
1. Hints appear automatically
2. Use `]h` to jump to next hint
3. Press `<Space>hd` to see details
4. Press `<Space>hf` to apply auto-fix
5. Use `<Space>hl` to see all hints

### Working with Snippets
1. Press `<Space>sl` to see available snippets
2. Type snippet trigger (e.g., `fn`)
3. Press `Tab` to expand
4. Use `Tab` to jump between placeholders
5. Press `<Space>sh` for snippet help

### Version Control
1. SVN markers show automatically
2. Use `<Space>sv` to toggle on/off
3. Use `<Space>sr` to refresh
4. Use `<Space>ss` to see status
5. Use `<Space>su` for unified signs

## Troubleshooting Quick Fixes

### Compilation Issues
```vim
:GeneroClearErrors          " Clear stale errors
:GeneroAutocompileStatus    " Check autocompile status
:messages                   " View error messages
```

### Navigation Issues
```vim
:GeneroClearCache           " Clear result cache
:GeneroConfigShow           " Verify configuration
```

### Hint Issues
```vim
:GeneroClearHintCache       " Clear hint cache
:GeneroListHints            " Refresh hints
```

### SVN Issues
```vim
:GeneroSVNCacheClear        " Clear SVN cache
:GeneroSVNRefresh           " Refresh markers
```

## Getting More Help

- **Comprehensive Help**: `:GeneroHelp` or `<Space>gh`
- **Context Menu**: Press `<Space>` for which-key
- **Documentation**: See `docs/` folder
- **Troubleshooting**: See `docs/TROUBLESHOOTING.md`

## Print-Friendly Version

To print this reference card:
1. Open in a browser or Markdown viewer
2. Print to PDF or paper
3. Keep handy while learning the plugin

---

**Quick Start**: Press `<Space>gh` to open the comprehensive help window!

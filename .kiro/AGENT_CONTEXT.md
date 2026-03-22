# Agent Context - Genero-Tools Plugin

**Quick Start**: Read [START_HERE.md](START_HERE.md) first (5 minutes)

---

## Project Summary

**Genero-Tools** is a Vim/Neovim plugin providing IDE functionality for Genero codebase development. It integrates with the `genero-tools` CLI tool to provide code navigation, compilation, snippets, hints, and debug streaming.

**Status**: Display Enhancements ✓ Complete | Snippet System ✓ Ready for Testing

---

## Current Work

### Bug Fix #001: Snippet Expansion (Ready for Testing)
- **Location**: `.kiro/bug-fixes/BF-1/`
- **Status**: Implementation complete
- **What's Fixed**: Selectable snippet list, LuaSnip expansion, autocomplete integration, placeholder navigation
- **Next**: Execute 30+ test cases in `docs/SNIPPET_TESTING_GUIDE.md`

### Display Enhancements (100% Complete)
- **Location**: `.kiro/specs/display-enhancements/`
- **Status**: All 6 active phases complete
- **What's Done**: Unified display system with 5 display modes, 100% backward compatible

---

## Key Files

| File | Purpose |
|------|---------|
| [START_HERE.md](START_HERE.md) | **Start here** - 5 min overview |
| [FUTURE_BUGS.md](FUTURE_BUGS.md) | Bug tracking |
| [FUTURE_TASKS.md](FUTURE_TASKS.md) | Enhancement roadmap |
| [bug-fixes/BF-1/](bug-fixes/BF-1/) | Current bug fix documentation |
| [enhancements/](enhancements/) | Future enhancement documentation |
| [specs/display-enhancements/](specs/display-enhancements/) | Project specifications |

---

## Quick Navigation

**I need to...**
- Understand the project → [START_HERE.md](START_HERE.md)
- Fix a bug → [FUTURE_BUGS.md](FUTURE_BUGS.md) → [bug-fixes/BF-1/](bug-fixes/BF-1/)
- Implement a feature → [FUTURE_TASKS.md](FUTURE_TASKS.md) → [enhancements/](enhancements/)
- Understand architecture → [specs/display-enhancements/design.md](specs/display-enhancements/design.md)
- Set up the plugin → [START_HERE.md](START_HERE.md#setup-guide)
- Configure the plugin → [START_HERE.md](START_HERE.md#configuration)

---

## Architecture

### Two-Layer Design
- **VimScript Layer** (`autoload/`): User-facing commands, display mode resolution
- **Lua Layer** (`lua/`): Async operations, snippets, UI components (Neovim only)

### Key Modules
- `display.vim` - Unified display system
- `config.vim` - Configuration management
- `compiler/` - Compilation and errors
- `snippets.vim` - Code templates
- `complete.vim` - Autocomplete
- `hints/` - Code suggestions
- `svn/` - Version control markers
- `debug_stream.vim` - Debug output

---

## Display Modes

| Mode | Vim | Neovim | Use Case |
|------|-----|--------|----------|
| quickfix | ✓ | ✓ | Traditional error list |
| popup | ✗ | ✓ | Floating window |
| split | ✓ | ✓ | Side-by-side window |
| echo | ✓ | ✓ | Command-line |
| inline | ✗ | ✓ | Inline popup |

---

## Vim vs Neovim

### Fully Supported in Both
- Quickfix, split, echo display modes
- Compiler integration
- Code navigation
- Hints, SVN integration

### Neovim Only
- Popup, inline display modes
- Snippets (requires Lua)
- Async operations
- Enhanced debug streaming

### Graceful Degradation
- Vim users get warnings for unsupported features
- Fallback to echo mode for popups
- Autocomplete works in both

---

## Configuration Example

```vim
let g:genero_tools_config = {
  \ 'display_mode': 'popup',
  \ 'compiler_enabled': 1,
  \ 'compiler_display_mode': 'quickfix',
  \ 'snippets_enabled': 1,
  \ 'snippet_list_selectable': 1,
  \ }
```

---

## Essential Commands

```vim
:GeneroFunctionSignature <name>  " Show function signature
:GeneroListFunctions             " List functions in file
:GeneroFileMetadata              " Show file metadata
:GeneroCompile                   " Compile current file
:GeneroSnippetList               " Show snippets
:GeneroSnippet <trigger>         " Expand snippet
:GeneroDebugStreamToggle         " Toggle debug streaming
```

---

## Essential Keybindings

```vim
<leader>gl  " Lookup function
<leader>gf  " List functions
<leader>gs  " Get signature
<leader>gm  " Get metadata
<leader>cc  " Clear errors
<C-.>       " Next error
<C-,>       " Previous error
<C-n>       " Autocomplete
Tab         " Next placeholder (in snippet)
Shift+Tab   " Previous placeholder (in snippet)
```

---

## Next Steps

1. **Read**: [START_HERE.md](START_HERE.md) (5 minutes)
2. **Choose**: Pick a task (bug fix or enhancement)
3. **Navigate**: Go to appropriate directory
4. **Implement**: Follow the documentation
5. **Test**: Execute test cases
6. **Commit**: Push changes

---

## Documentation

### For Agents (`.kiro/`)
- **START_HERE.md** - Quick entry point
- **bug-fixes/BF-N/** - Bug fix documentation
- **enhancements/** - Enhancement documentation
- **specs/display-enhancements/** - Project specifications

### For Humans (`docs/`)
- **SNIPPET_CONFIGURATION.md** - How to use snippets
- **SNIPPET_ARCHITECTURE.md** - How snippets work
- **SNIPPET_TESTING_GUIDE.md** - How to test snippets
- **COMPATIBILITY.md** - Vim vs Neovim features
- **SETUP.md** - Installation guide

---

**Start here**: [START_HERE.md](START_HERE.md)


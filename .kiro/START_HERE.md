# Genero-Tools Plugin - Agent Entry Point

**Last Updated**: March 22, 2026
**Project Status**: Display Enhancements ✓ Complete | Snippet System ✓ Ready for Testing
**Quick Start**: 5 minutes to understand the project

---

## What Is This Project?

**Genero-Tools** is a Neovim/Vim plugin that provides modern IDE functionality for developers working with Genero codebases (especially large ones). It integrates with the `genero-tools` command-line tool to provide:

- **Code Navigation**: Function lookup, file metadata, signatures
- **Compilation**: Real-time error checking with visual feedback
- **Snippets**: Code templates with placeholder navigation
- **Hints**: Inline suggestions and code quality indicators
- **SVN Integration**: Visual diff markers for version control
- **Debug Streaming**: Real-time debug output display

**Target Users**: Developers new to Neovim or using Vim who need IDE-like features for Genero development.

---

## Current Status

### ✓ Display Enhancements (100% Complete)
Unified display system for all plugin features with 5 display modes:
- Quickfix lists (Vim & Neovim)
- Floating windows (Neovim only)
- Split windows (Vim & Neovim)
- Echo/command-line (Vim & Neovim)
- Inline popups (Neovim only)

### ✓ Snippet System (Implementation Complete - Ready for Testing)
Snippet expansion with LuaSnip integration:
- Selectable snippet list (keyboard & mouse)
- Autocomplete integration
- Placeholder navigation (Tab/Shift+Tab)
- Custom snippet support

---

## Quick Navigation

### I Need To...

**Understand the project**
→ Read this file (5 min)

**Fix a bug**
→ See [Bug Fixes](#bug-fixes) section below

**Implement a feature**
→ See [Enhancements](#enhancements) section below

**Understand architecture**
→ Read [Architecture Overview](#architecture-overview) below

**Set up the plugin**
→ Read [Setup Guide](#setup-guide) below

**Understand configuration**
→ Read [Configuration](#configuration) below

---

## Architecture Overview

### Two-Layer Design

```
┌─────────────────────────────────────────┐
│     VimScript Layer (autoload/)         │
│  - User-facing commands and functions   │
│  - Display mode resolution              │
│  - Feature integration                  │
└──────────────┬──────────────────────────┘
               │ luaeval() calls
               ↓
┌─────────────────────────────────────────┐
│      Lua Layer (lua/genero_tools/)      │
│  - Async operations (Neovim only)       │
│  - Snippet management                   │
│  - UI components                        │
└─────────────────────────────────────────┘
```

### Key Modules

| Module | Purpose | Files |
|--------|---------|-------|
| **display** | Unified display system | `display.vim` |
| **config** | Configuration management | `config.vim` |
| **compiler** | Compilation & errors | `compiler/*.vim` |
| **snippets** | Code templates | `snippets.vim`, `lua/snippets/` |
| **complete** | Autocomplete | `complete.vim` |
| **hints** | Code suggestions | `hints/*.vim` |
| **svn** | Version control markers | `svn/*.vim` |
| **debug_stream** | Debug output | `debug_stream.vim` |

---

## Setup Guide

### For Neovim Users (Full Features)

1. **Install Neovim 0.5+**
   ```bash
   # macOS
   brew install neovim
   
   # Linux
   sudo apt install neovim  # or equivalent for your distro
   ```

2. **Install Plugin Manager** (e.g., vim-plug)
   ```bash
   sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
   ```

3. **Add to init.nvim**
   ```vim
   call plug#begin()
   Plug 'your-org/genero-tools'
   Plug 'L3MON4D3/LuaSnip'  " Required for snippets
   call plug#end()
   ```

4. **Install genero-tools CLI**
   ```bash
   # Ensure genero-tools command is available in PATH
   which genero-tools
   ```

5. **Configure** (optional)
   ```vim
   let g:genero_tools_config = {
     \ 'display_mode': 'popup',
     \ 'compiler_enabled': 1,
     \ 'snippets_enabled': 1,
     \ }
   ```

### For Vim Users (Limited Features)

1. **Install Vim 8.2+**
   ```bash
   # macOS
   brew install vim
   
   # Linux
   sudo apt install vim  # or equivalent
   ```

2. **Install Plugin Manager** (e.g., vim-plug)
   ```bash
   curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   ```

3. **Add to .vimrc**
   ```vim
   call plug#begin()
   Plug 'your-org/genero-tools'
   call plug#end()
   ```

4. **Install genero-tools CLI**
   ```bash
   which genero-tools
   ```

5. **Note**: Snippets and some display modes unavailable in Vim

---

## Configuration

### Display Modes

```vim
" Global setting (default: 'quickfix')
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',  " or 'popup', 'split', 'echo', 'inline'
  \ }

" Feature-specific overrides
let g:genero_tools_config = {
  \ 'display_mode': 'quickfix',
  \ 'compiler_display_mode': 'popup',      " Compiler uses popup
  \ 'hints_display_mode': 'inline',        " Hints use inline
  \ }
```

### Compiler Settings

```vim
let g:genero_tools_config = {
  \ 'compiler_enabled': 1,
  \ 'compiler_autocompile': 1,
  \ 'compiler_autocompile_delay': 1000,
  \ 'compiler_show_warnings': 1,
  \ 'compiler_show_errors': 1,
  \ }
```

### Snippet Settings

```vim
let g:genero_tools_config = {
  \ 'snippets_enabled': 1,
  \ 'snippet_list_selectable': 1,
  \ 'autocomplete_include_snippets': 1,
  \ 'snippet_expansion_mode': 'luasnip',
  \ }
```

---

## Bug Fixes

### Current: Issue #001 - Snippet Expansion

**Status**: Implementation complete, ready for testing
**Location**: `.kiro/bug-fixes/BF-1/`

**What's Fixed**:
- ✓ Snippet list now selectable (keyboard & mouse)
- ✓ Snippets expand with LuaSnip
- ✓ Snippets in autocomplete menu
- ✓ Placeholder navigation (Tab/Shift+Tab)

**To Test**:
1. Read `.kiro/bug-fixes/BF-1/QUICK_REFERENCE.md`
2. Follow `docs/SNIPPET_TESTING_GUIDE.md`
3. Execute 30+ test cases
4. Report results

**To Understand**:
- Implementation: `.kiro/bug-fixes/BF-1/IMPLEMENTATION_SUMMARY.md`
- Progress: `.kiro/bug-fixes/BF-1/IMPLEMENTATION_PROGRESS.md`
- Architecture: `docs/SNIPPET_ARCHITECTURE.md`

---

## Enhancements

### Planned Phases (8-13)

| Phase | Name | Priority | Effort | Status |
|-------|------|----------|--------|--------|
| 8 | Progress Display | Medium | 1-2 days | Planned |
| 9 | Custom Display Modes | Low | 2-3 days | Planned |
| 10 | Performance Optimization | Low | 1 day | Planned |
| 11 | Enhanced Error Reporting | Medium | 1-2 days | Planned |
| 12 | Configuration Validation UI | Low | 1-2 days | Planned |
| 13 | Display Mode Presets | Low | 1 day | Planned |

**To Implement**:
1. Choose a phase from above
2. Read `.kiro/enhancements/README.md`
3. Review phase documentation
4. Follow implementation guide
5. Test thoroughly

---

## Key Concepts

### Display Modes

**Quickfix**: Traditional error list (all editors)
```vim
:copen  " Open quickfix list
```

**Popup**: Floating window (Neovim only)
- Centered on screen
- Auto-closes after delay
- Keyboard/mouse navigation

**Split**: Side-by-side window (all editors)
- Preserves main editor
- Good for detailed content

**Echo**: Command-line display (all editors)
- Minimal, non-intrusive
- Good for notifications

**Inline**: Inline popup (Neovim only)
- Appears near cursor
- Context-aware positioning

### Configuration Hierarchy

```
Global display_mode (default: 'quickfix')
    ↓
Feature-specific override (e.g., compiler_display_mode)
    ↓
Resolved display mode for feature
```

### In-Editor Display (Independent)

These always display regardless of `display_mode`:
- Compiler error signs in sign column
- Syntax highlighting
- Virtual text hints
- SVN diff markers
- Debug streaming split window

---

## Common Tasks

### To Add a New Feature

1. Create spec in `.kiro/enhancements/PHASE_N_*.md`
2. Implement in appropriate module
3. Add configuration options to `config.vim`
4. Test with all display modes
5. Test in Vim and Neovim
6. Document in `docs/`

### To Fix a Bug

1. Document in `.kiro/FUTURE_BUGS.md`
2. Create directory `.kiro/bug-fixes/BF-N/`
3. Implement fix
4. Create test cases
5. Document in bug-fixes directory
6. Test thoroughly

### To Test a Feature

1. Read test guide in `docs/`
2. Execute test cases
3. Document results
4. Report issues

---

## Documentation Structure

### For Agents (`.kiro/`)
- **START_HERE.md** (this file) - Quick entry point
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

## Vim vs Neovim Compatibility

### Fully Supported in Both
- ✓ Quickfix display mode
- ✓ Split window display mode
- ✓ Echo display mode
- ✓ Compiler integration
- ✓ Code navigation
- ✓ Hints (basic)
- ✓ SVN integration

### Neovim Only
- ✗ Popup display mode (uses floating windows)
- ✗ Inline display mode
- ✗ Snippets (requires Lua)
- ✗ Async operations
- ✗ Debug streaming (enhanced)

### Graceful Degradation
- Vim users get warnings for unsupported features
- Fallback to echo mode for popups
- Autocomplete works in both

---

## Getting Help

### For Understanding
1. Read this file (START_HERE.md)
2. Read relevant section in `docs/`
3. Check `.kiro/specs/display-enhancements/` for details

### For Bugs
1. Check `.kiro/FUTURE_BUGS.md`
2. Check `.kiro/bug-fixes/BF-N/` for current fixes
3. Report new bugs with details

### For Features
1. Check `.kiro/FUTURE_TASKS.md`
2. Check `.kiro/enhancements/` for planned work
3. Propose new features with rationale

---

## Quick Reference

### Essential Files
- **Project Entry**: This file (START_HERE.md)
- **Bug Tracking**: `.kiro/FUTURE_BUGS.md`
- **Enhancement Roadmap**: `.kiro/FUTURE_TASKS.md`
- **Specifications**: `.kiro/specs/display-enhancements/README.md`
- **Current Bug Fix**: `.kiro/bug-fixes/BF-1/README.md`

### Essential Commands
```vim
" Show function signature
:GeneroFunctionSignature <name>

" List functions in file
:GeneroListFunctions

" Show file metadata
:GeneroFileMetadata

" Compile current file
:GeneroCompile

" Show snippets
:GeneroSnippetList

" Expand snippet
:GeneroSnippet <trigger>

" Toggle debug streaming
:GeneroDebugStreamToggle
```

### Essential Keybindings
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

## Summary

**Genero-Tools** is a modern IDE plugin for Genero development in Vim/Neovim. The project is well-structured with:

- ✓ Complete display system (100% done)
- ✓ Snippet system (ready for testing)
- ✓ Clear documentation
- ✓ Organized for easy agent onboarding
- ✓ Vim and Neovim support

**To get started**: Read this file, then navigate to the section you need.

**To contribute**: Follow the structure in `.kiro/` for bug fixes and enhancements.

**To understand deeply**: Read the specifications in `.kiro/specs/display-enhancements/`.

---

## Next Steps

1. **Understand**: Read this file completely
2. **Choose**: Pick a task (bug fix or enhancement)
3. **Navigate**: Go to appropriate directory
4. **Implement**: Follow the documentation
5. **Test**: Execute test cases
6. **Commit**: Push changes

**Questions?** Check the relevant documentation file or specification.


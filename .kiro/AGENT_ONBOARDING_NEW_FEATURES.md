# Agent Onboarding: Implementing New Features

## Quick Context

**Project:** Genero-Tools Vim Plugin - A Vim/Neovim plugin for Genero development with code navigation, autocomplete, and compiler integration.

**Status:** Production-ready. All critical issues resolved. See `.kiro/STATUS_FINAL.md` for details.

**Tech Stack:**
- VimScript (primary) + Lua (Neovim optional layer)
- Genero language support (4GL, M3, M4, PER files)
- Vim 7+ / Neovim 0.4+ compatible

---

## Project Structure

```
plugin/genero_tools.vim          # Main plugin entry point
autoload/genero_tools/           # Core functionality
├── compiler/                    # Compilation & error handling
├── hints/                        # Code quality hints
├── signs/                        # Sign column management
├── lua_bridge.vim               # Neovim Lua integration
└── [other modules]              # Navigation, cache, config, etc.
docs/                            # User documentation
.kiro/specs/                      # Feature specifications
```

---

## Key Features to Understand

1. **Compiler Integration** - Real-time error/warning parsing with quickfix
2. **Code Hints** - Non-fatal code quality warnings (configurable)
3. **Code Navigation** - Function lookup, module exploration, file metadata
4. **Autocomplete** - Function/module name completion with signatures
5. **SVN Diff Markers** - Visual indicators for added/modified/deleted lines
6. **Snippets** - Code templates with smart parameter population (Neovim)
7. **Debug Streaming** - Real-time debug output monitoring (Neovim)

---

## Before Starting

1. **Read the spec** - Check `.kiro/specs/{feature-name}/` for requirements and design
2. **Review existing code** - Understand the module structure and patterns
3. **Check compatibility** - Ensure changes work in Vim 7+, Vim 8+, and Neovim
4. **Test thoroughly** - Use both Vim and Neovim for testing

---

## Common Implementation Patterns

### Adding a New Command
```vim
" In plugin/genero_tools.vim
command! -nargs=? GeneroNewCommand call genero_tools#new_module#command(<f-args>)

" In autoload/genero_tools/new_module.vim
function! genero_tools#new_module#command(args)
  " Implementation
endfunction
```

### Adding a Keybinding
```vim
" In autoload/genero_tools/keybindings.vim
nnoremap <leader>gn :GeneroNewCommand<CR>
```

### Error Handling
```vim
" Use consistent error format
call genero_tools#error#error('module_name', 'Error description')
```

### Configuration
```vim
" Access config with:
let config = genero_tools#config#get()
let value = config.option_name
```

---

## Testing Checklist

- [ ] Feature works in Vim 8+
- [ ] Feature works in Neovim 0.5+
- [ ] No syntax errors (use `:checktime` and `:messages`)
- [ ] Keybindings don't conflict with existing ones
- [ ] Error messages are clear and helpful
- [ ] Configuration options are documented
- [ ] Backward compatibility maintained

---

## Documentation Requirements

1. Update `README.md` with new commands/keybindings
2. Add configuration options to the Configuration section
3. Create/update relevant doc files in `docs/`
4. Update `.vimrc.example` with example keybindings

---

## Useful Commands

```vim
:GeneroHelp                      " Show all commands and keybindings
:GeneroConfigShow                " Display current configuration
:GeneroClearCache                " Clear result cache
:messages                        " View error messages
:checktime                       " Check for syntax errors
```

---

## Known Limitations & Future Work

See `.kiro/FUTURE_TASKS.md` for:
- Snippet placeholder navigation (high priority)
- Git diff markers (medium priority)
- Multiple debug windows (medium priority)
- Result filtering (low priority)
- Incremental caching (performance)

---

## Quick Links

- **Setup:** `SETUP.md`
- **Status:** `.kiro/STATUS_FINAL.md`
- **Future Tasks:** `.kiro/FUTURE_TASKS.md`
- **API Reference:** `docs/API_INTEGRATION.md`
- **Compatibility:** `docs/COMPATIBILITY.md`

---

## Getting Help

1. Check existing specs in `.kiro/specs/`
2. Review similar features in `autoload/genero_tools/`
3. Look at test results in `.kiro/` directory
4. Consult documentation in `docs/`

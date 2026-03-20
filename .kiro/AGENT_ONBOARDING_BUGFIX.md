# Agent Onboarding: Fixing Bugs

## Quick Context

**Project:** Genero-Tools Vim Plugin - A Vim/Neovim plugin for Genero development.

**Status:** Production-ready with known issues documented in `.kiro/ISSUES_FOUND_AND_ACTION_ITEMS.md`

**Tech Stack:**
- VimScript (primary) + Lua (Neovim optional layer)
- Vim 7+ / Neovim 0.4+ compatible

---

## Finding the Bug

1. **Check issue tracking:**
   - `.kiro/ISSUES_FOUND_AND_ACTION_ITEMS.md` - Known issues and action items
   - `.kiro/STATUS_FINAL.md` - Recent fixes and status
   - `.kiro/FUTURE_TASKS.md` - Known limitations

2. **Reproduce the bug:**
   - Test in both Vim and Neovim
   - Document exact steps to reproduce
   - Capture error messages and stack traces

3. **Identify the module:**
   - Check which feature is affected (compiler, hints, navigation, etc.)
   - Look in `autoload/genero_tools/{module}/` for relevant code
   - Review recent changes in `.kiro/CHANGES_SUMMARY.md`

---

## Project Structure

```
plugin/genero_tools.vim          # Main plugin entry point
autoload/genero_tools/           # Core functionality
├── compiler/                    # Compilation & error handling
├── hints/                        # Code quality hints
├── signs/                        # Sign column management
├── lua_bridge.vim               # Neovim Lua integration
├── error.vim                     # Error handling utilities
├── config.vim                    # Configuration management
└── [other modules]              # Navigation, cache, display, etc.
docs/                            # User documentation
```

---

## Debugging Workflow

### 1. Enable Debug Mode
```vim
let g:genero_tools_config.debug_mode = 1
:GeneroDebugStreamToggle         " View debug output (Neovim only)
```

### 2. Check Error Messages
```vim
:messages                        " View all error messages
:GeneroConfigShow                " Display current configuration
```

### 3. Trace the Issue
- Add debug output using `genero_tools#error#debug()`
- Check function return values
- Verify configuration options
- Test with minimal configuration

### 4. Verify Compatibility
- Test in Vim 8+
- Test in Neovim 0.5+
- Check for platform-specific issues (Linux, macOS, Windows)

---

## Common Bug Patterns

### Keybinding Conflicts
- Check `.vimrc.example` for conflicting mappings
- Verify keybinding is registered in `keybindings.vim`
- Test with minimal config

### Configuration Issues
- Verify option exists in `config.vim`
- Check default values
- Validate option types (string, number, list, dict)

### Async/Lua Issues (Neovim)
- Check `lua_bridge.vim` for Lua integration
- Verify Neovim version compatibility
- Test with `lua_enabled = 0` to isolate issue

### Error Handling
- Look for missing error checks
- Verify error messages are clear
- Check for silent failures

### Display Issues
- Check `display.vim` for formatting
- Verify floating window configuration
- Test different display modes

---

## Testing Checklist

- [ ] Bug is reproducible with exact steps
- [ ] Root cause identified and documented
- [ ] Fix tested in Vim 8+
- [ ] Fix tested in Neovim 0.5+
- [ ] No new errors introduced
- [ ] Backward compatibility maintained
- [ ] Error messages are clear
- [ ] Related features still work

---

## Fix Implementation

### 1. Locate the Bug
```vim
" Search for the problematic function
:grep -r "function_name" autoload/
```

### 2. Understand the Code
- Read the function and surrounding context
- Check for recent changes
- Review related functions

### 3. Implement the Fix
- Make minimal changes
- Add comments explaining the fix
- Maintain code style consistency

### 4. Test the Fix
```vim
" Reload the plugin
:source plugin/genero_tools.vim

" Test the affected feature
:GeneroCommand
```

---

## Error Handling Best Practices

```vim
" Use consistent error format
call genero_tools#error#error('module_name', 'Error description')

" Check for errors in function returns
let result = some_function()
if has_key(result, 'error')
  call genero_tools#error#error('module', result.error)
  return
endif
```

---

## Documentation Requirements

1. Document the bug in the spec (if creating a bugfix spec)
2. Update `.kiro/ISSUES_FOUND_AND_ACTION_ITEMS.md` with fix details
3. Add comments to code explaining the fix
4. Update relevant documentation in `docs/`

---

## Useful Commands

```vim
:GeneroHelp                      " Show all commands
:GeneroConfigShow                " Display configuration
:messages                        " View error messages
:checktime                       " Check for syntax errors
:GeneroDebugStreamToggle         " View debug output (Neovim)
```

---

## Known Issues Reference

See `.kiro/ISSUES_FOUND_AND_ACTION_ITEMS.md` for:
- Recently fixed issues (10/10 resolved)
- Issue categories (critical, high, medium, low)
- Detailed fix descriptions

---

## Quick Links

- **Issues:** `.kiro/ISSUES_FOUND_AND_ACTION_ITEMS.md`
- **Status:** `.kiro/STATUS_FINAL.md`
- **Changes:** `.kiro/CHANGES_SUMMARY.md`
- **API Reference:** `docs/API_INTEGRATION.md`
- **Compatibility:** `docs/COMPATIBILITY.md`

---

## Getting Help

1. Check `.kiro/ISSUES_FOUND_AND_ACTION_ITEMS.md` for similar issues
2. Review `.kiro/CHANGES_SUMMARY.md` for recent fixes
3. Look at error handling in `autoload/genero_tools/error.vim`
4. Consult documentation in `docs/`
5. Check test results in `.kiro/` directory

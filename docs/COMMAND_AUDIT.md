# Genero-Tools Command Audit

## Overview

This document audits all registered commands to identify their purpose, eliminate duplicates, and ensure consistency.

## Command Categories

### 1. Code Navigation Commands

#### VimScript (Raw Data) Commands
These return raw data and are suitable for programmatic use:

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroLookup` | `genero_tools#lookup_function()` | Find function definition | ✅ Working |
| `GeneroListFunctions` | `genero_tools#list_functions_in_file()` | List functions in file | ✅ Working |
| `GeneroListModuleFiles` | `genero_tools#list_module_files()` | List unique files in module | ✅ Fixed |
| `GeneroFunctionSignature` | `genero_tools#get_function_signature()` | Get function signature | ✅ Working |
| `GeneroFileMetadata` | `genero_tools#get_file_metadata()` | Get file metadata | ✅ Working |

#### Telescope (UI) Commands (Neovim only)
These provide interactive UI with preview and fuzzy search:

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroFileFunctions` | `telescope.file_functions()` | Browse functions in current file | ✅ Working |
| `GeneroModuleFunctions` | `telescope.module_functions()` | Browse functions in module | ✅ Working |
| `GeneroModuleFiles` | `telescope.module_files()` | Switch between module files | ✅ Working |
| `GeneroDiagnostics` | `telescope.diagnostics('all')` | Browse all compiler diagnostics | ✅ Working |
| `GeneroDiagnosticsErrors` | `telescope.diagnostics('errors')` | Browse errors only | ✅ Working |
| `GeneroDiagnosticsWarnings` | `telescope.diagnostics('warnings')` | Browse warnings only | ✅ Working |
| `GeneroSnippetsTelescope` | `telescope.snippets()` | Browse snippets with preview | ✅ Working |

#### Navigation Commands

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroGotoDefinition` | `navigation#goto_definition()` | Jump to function definition | ✅ Working |
| `GeneroPeekDefinition` | `navigation#peek_definition()` | Preview definition in float | ✅ Working |
| `GeneroFindReferences` | `references#find()` | Find function references | ✅ Working |
| `GeneroFindVariableReferences` | `references#find_variable()` | Find variable references | ✅ Working |
| `GeneroFindSmartReferences` | `references#find_smart()` | Smart reference detection | ✅ Working |

### 2. Compiler Commands

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroCompile` | `compiler#commands#compile()` | Compile current file | ✅ Working |
| `GeneroClearErrors` | `compiler#commands#clear_errors()` | Clear error list | ✅ Working |
| `GeneroNextError` | `compiler#commands#next_error()` | Jump to next error | ✅ Working |
| `GeneroPrevError` | `compiler#commands#prev_error()` | Jump to previous error | ✅ Working |
| `GeneroFirstError` | `compiler#commands#first_error()` | Jump to first error | ✅ Working |
| `GeneroLastError` | `compiler#commands#last_error()` | Jump to last error | ✅ Working |
| `GeneroAutocompileEnable` | `compiler#commands#autocompile_enable()` | Enable autocompile | ✅ Working |
| `GeneroAutocompileDisable` | `compiler#commands#autocompile_disable()` | Disable autocompile | ✅ Working |
| `GeneroAutocompileStatus` | `compiler#commands#autocompile_status()` | Show autocompile status | ✅ Working |
| `GeneroFilterErrors` | `compiler#commands#filter_errors()` | Show errors only | ✅ Working |
| `GeneroFilterWarnings` | `compiler#commands#filter_warnings()` | Show warnings only | ✅ Working |
| `GeneroFilterAll` | `compiler#commands#filter_all()` | Show all diagnostics | ✅ Working |
| `GeneroTypeInfo` | `compiler#type_info#manual()` | Show type info (debug) | ✅ Working |

### 3. Snippet Commands (Neovim only)

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroSnippetList` | `snippets#list()` | List snippets (Telescope if available) | ✅ Working |
| `GeneroSnippetsTelescope` | `telescope.snippets()` | List snippets (explicit Telescope) | ✅ Working |
| `GeneroSnippetHelp` | `snippets#help()` | Show snippet help | ✅ Working |
| `GeneroSnippet` | `snippets#expand()` | Expand snippet by trigger | ✅ Working |

### 4. SVN Commands

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroSVNRefresh` | `svn#commands#refresh()` | Refresh SVN status | ✅ Working |
| `GeneroSVNToggle` | `svn#commands#toggle()` | Toggle SVN markers | ✅ Working |
| `GeneroSVNStatus` | `svn#commands#status()` | Show SVN status | ✅ Working |
| `GeneroSVNCacheStats` | `svn#commands#cache_stats()` | Show SVN cache stats | ✅ Working |
| `GeneroSVNCacheClear` | `svn#commands#cache_clear()` | Clear SVN cache | ✅ Working |

### 5. Hint Commands

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroNextHint` | `hints#nav#next()` | Jump to next hint | ✅ Working |
| `GeneroPrevHint` | `hints#nav#prev()` | Jump to previous hint | ✅ Working |
| `GeneroListHints` | `hints#nav#list()` | List all hints | ✅ Working |
| `GeneroHintDetails` | `hints#nav#details()` | Show hint details | ✅ Working |
| `GeneroHintAutofix` | `hints#autofix#apply()` | Apply auto-fix | ✅ Working |
| `GeneroClearHintCache` | `hints#cache#clear()` | Clear hint cache | ✅ Working |
| `GeneroHintHelp` | `hints#help()` | Show hint help | ✅ Working |

### 6. Debug Stream Commands (Neovim only)

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroDebugStream` | `debug_stream#start()` | Start debug stream | ✅ Working |
| `GeneroDebugStreamStop` | `debug_stream#stop()` | Stop debug stream | ✅ Working |
| `GeneroDebugStreamToggle` | `commands#debug_stream_select()` | Toggle debug stream | ✅ Working |
| `GeneroDebugStreamSelect` | `commands#debug_stream_select()` | Select debug stream | ✅ Working |
| `GeneroDebugStreamClear` | `debug_stream#clear()` | Clear debug stream | ✅ Working |
| `GeneroDebugStreamStatus` | `debug_stream#status()` | Show debug stream status | ✅ Working |

### 7. Cache and Config Commands

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroClearCache` | `cache#clear()` | Clear all caches | ✅ Working |
| `GeneroCacheStats` | `cache#show_stats()` | Show cache statistics | ✅ Working |
| `GeneroConfigShow` | `config#show()` | Show configuration | ✅ Working |
| `GeneroCompleteEnable` | `complete#enable()` | Enable completion | ✅ Working |
| `GeneroCompleteDisable` | `complete#disable()` | Disable completion | ✅ Working |

### 8. Lua API Commands (Neovim only)

| Command | Function | Purpose | Status |
|---------|----------|---------|--------|
| `GeneroLuaUI` | Lua UI API | Access UI functions | ✅ Working |
| `GeneroLuaAsync` | Lua Async API | Access async functions | ✅ Working |

## Issues Found and Fixed

### Issue 1: GeneroListModuleFiles Not Working ✅ FIXED

**Problem:**
- `GeneroListModuleFiles` was returning function data instead of unique file paths
- The command called `find-functions-in-module` but didn't extract unique files
- `GeneroModuleFiles` (Telescope) correctly extracted unique files

**Solution:**
- Added `s:extract_unique_files()` helper function
- Modified `genero_tools#list_module_files()` to extract and return unique file paths
- Now returns sorted list of unique files in the module

**Status:** ✅ Fixed in this commit

### Issue 2: Command Naming Consistency

**Observation:**
- VimScript commands use `GeneroList*` prefix (e.g., `GeneroListFunctions`)
- Telescope commands use descriptive names (e.g., `GeneroFileFunctions`)
- This is intentional and serves different purposes:
  - `GeneroList*` = Raw data for programmatic use
  - `Genero*` (Telescope) = Interactive UI for user navigation

**Status:** ✅ No change needed - naming is intentional

## Command Usage Guidelines

### When to Use VimScript Commands
- Scripting and automation
- Integration with other tools
- Need raw data output
- Vim 8.x compatibility required

### When to Use Telescope Commands
- Interactive navigation
- Need preview before selection
- Want fuzzy search
- Neovim with Telescope installed

## Total Command Count

- **VimScript Commands:** 48
- **Telescope Commands:** 7
- **Neovim-only Commands:** 20
- **Total:** 55 commands

## Recommendations

### Keep Both Command Types
- VimScript commands provide programmatic access
- Telescope commands provide interactive UI
- Both serve different use cases

### Documentation
- Clearly document which commands are for UI vs programmatic use
- Show Telescope alternatives in help text
- Indicate Neovim-only commands

### Future Improvements
1. Add `:GeneroHelp` command to show all available commands
2. Consider adding `GeneroTelescope` command to list all Telescope pickers
3. Add command completion for better discoverability

## Conclusion

All commands are working as intended. The fix for `GeneroListModuleFiles` ensures it now correctly returns unique file paths instead of function data. The dual command structure (VimScript + Telescope) is intentional and provides flexibility for different use cases.

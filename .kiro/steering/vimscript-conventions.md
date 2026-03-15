---
inclusion: auto
fileMatchPattern: "**/*.vim"
---

# VimScript Conventions for Genero-Tools Plugin

This document establishes VimScript patterns and conventions used throughout the genero-tools plugin to ensure consistency and maintainability.

## Function Naming and Organization

### Autoload Functions
All plugin functions use the autoload pattern with the `genero_tools#` namespace prefix:

```vim
" Module-level functions
function! genero_tools#config#get(key) abort
  " Implementation
endfunction

" Nested module functions
function! genero_tools#display#quickfix(results) abort
  " Implementation
endfunction
```

**Pattern:** `genero_tools#<module>#<function_name>()`

### Function Attributes
- Always use `abort` to stop execution on errors
- Use `function!` to allow redefinition during development
- Document parameters and return values in comments

```vim
" Get configuration value with fallback to default
" Args: key (string) - configuration key name
" Returns: value (any) - configuration value or default
function! genero_tools#config#get(key) abort
  " Implementation
endfunction
```

## Result Dictionary Structure

All command execution functions return a consistent result dictionary:

```vim
let result = {
  \ 'success': v:true,      " Boolean: operation succeeded
  \ 'data': {},             " Any: operation result data
  \ 'error': '',            " String: error message if failed
  \ 'timestamp': localtime() " Number: unix timestamp
  \ }
```

**Usage pattern:**
```vim
let result = genero_tools#command#execute_shell('lookup', ['function_name'])
if result.success
  call genero_tools#display_result(result.data)
else
  echohl ErrorMsg | echo result.error | echohl None
endif
```

## Configuration Access

Always use the config getter function, never access `g:genero_tools_config` directly:

```vim
" Good
let timeout = genero_tools#config#get('timeout')
let cache_enabled = genero_tools#config#get('cache_enabled')

" Avoid
let timeout = g:genero_tools_config.timeout
```

This allows for default value handling and validation in one place.

## Error Handling

### Try-Catch Pattern
Use try-catch for operations that may fail:

```vim
try
  let output = system(cmd_line)
  let exit_code = v:shell_error
  
  if exit_code != 0
    let result.error = genero_tools#error#format_from_output(output, command)
    return result
  endif
  
  let data = json_decode(output)
catch
  let result.error = genero_tools#error#format_parse_error(v:exception)
  return result
endtry
```

### Error Messages
Always use the error formatting functions from `error.vim`:

```vim
" For specific error types
let msg = genero_tools#error#format_not_found('function', 'my_func')
let msg = genero_tools#error#format_timeout('lookup')
let msg = genero_tools#error#format_permission_denied('/path/to/file')

" For generic output parsing
let msg = genero_tools#error#format_from_output(output, command_name)
```

## Variable Naming

### Local Variables
Use lowercase with underscores:

```vim
let cmd_line = tool_path . ' ' . command
let start_time = localtime()
let result_count = len(results)
```

### Global Configuration
Use `g:genero_tools_config` dictionary:

```vim
let g:genero_tools_config = {
  \ 'genero_tools_path': 'query.sh',
  \ 'cache_enabled': v:true,
  \ 'timeout': 10000
  \ }
```

### Script-Local Variables
Use `s:` prefix for module-private state:

```vim
let s:cache = {}
let s:pagination_state = {}
```

## Command Definition Pattern

User-facing commands follow this pattern:

```vim
command! -nargs=? GeneroLookup call genero_tools#commands#lookup(<q-args>)
command! -nargs=? GeneroListFunctions call genero_tools#commands#list_functions(<q-args>)
```

**Conventions:**
- Command names start with `Genero` prefix
- Use `-nargs=?` for optional arguments
- Use `<q-args>` to preserve quoted arguments
- Delegate to `commands.vim` module

## Keybinding Pattern

Keybindings are registered in `keybindings.vim`:

```vim
function! genero_tools#keybindings#register() abort
  if !genero_tools#config#get('keybindings_enabled')
    return
  endif
  
  nnoremap <silent> <leader>gl :GeneroLookup <C-R><C-W><CR>
  nnoremap <silent> <leader>gf :GeneroListFunctions %<CR>
endfunction
```

**Conventions:**
- Use `<silent>` to suppress command echoing
- Use `<C-R><C-W>` to insert word under cursor
- Use `%` for current file
- Always check if keybindings are enabled

## Display and Output

### Echoing Messages
Use highlight groups for visual feedback:

```vim
" Error message
echohl ErrorMsg | echo 'Error: ' . message | echohl None

" Success message
echohl MoreMsg | echo 'Success: ' . message | echohl None

" Info message
echohl Question | echo 'Info: ' . message | echohl None
```

### Pagination
Use the pagination module for large result sets:

```vim
let pages = genero_tools#pagination#paginate(results, page_size)
let current_page = pages[0]
let total_pages = len(pages)
```

## Async Operations

For long-running operations, use async execution:

```vim
if genero_tools#config#get('async_enabled')
  call genero_tools#progress#show('Executing command...')
  " Async execution happens here
  call genero_tools#progress#hide()
endif
```

## Testing Patterns

### Unit Test Structure
```vim
" Test file: test/unit/test_config.vim
function! Test_config_get_returns_default() abort
  let value = genero_tools#config#get('nonexistent_key')
  call assert_equal(v:null, value)
endfunction
```

### Property Test Structure
```vim
" Test file: test/property/test_result_structure.vim
function! Test_result_always_has_required_fields() abort
  " Generate random inputs
  " Execute function
  " Assert result has success, data, error, timestamp
endfunction
```

## Module Organization

Each module in `autoload/genero_tools/` handles a specific concern:

- `config.vim` - Configuration management
- `command.vim` - Shell command execution
- `cache.vim` - Result caching with LRU eviction
- `display.vim` - Result display dispatcher
- `display/` - Display mode implementations (quickfix, popup, split, echo)
- `error.vim` - Error message formatting
- `keybindings.vim` - Keybinding registration
- `compat.vim` - Vim/Neovim compatibility
- `progress.vim` - Progress feedback
- `codebase.vim` - Codebase path detection
- `complete.vim` - Autocomplete implementation
- `commands.vim` - User-facing command implementations

## Common Patterns

### Checking Editor Type
```vim
if genero_tools#compat#is_neovim()
  " Neovim-specific code
else
  " Vim-specific code
endif
```

### Caching Pattern
```vim
let cached = genero_tools#cache#get(cache_key)
if !empty(cached)
  return cached
endif

let result = genero_tools#command#execute_shell(...)
if result.success
  call genero_tools#cache#set(cache_key, result.data)
endif
```

### Display Pattern
```vim
let result = genero_tools#command#execute_shell(...)
if result.success
  call genero_tools#display#display_result(result.data)
else
  echohl ErrorMsg | echo result.error | echohl None
endif
```

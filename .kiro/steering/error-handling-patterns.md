---
inclusion: auto
fileMatchPattern: "**/*.vim"
---

# Error Handling Patterns for Genero-Tools Plugin

This document establishes error handling conventions and patterns used throughout the genero-tools plugin.

## Error Result Structure

All functions that can fail return a result dictionary with error information:

```vim
let result = {
  \ 'success': v:false,
  \ 'data': {},
  \ 'error': 'Error message with guidance',
  \ 'timestamp': localtime()
  \ }
```

**Always check `result.success` before using `result.data`:**

```vim
let result = genero_tools#command#execute_shell('lookup', ['func'])
if result.success
  " Safe to use result.data
  call genero_tools#display#display_result(result.data)
else
  " Display error message
  echohl ErrorMsg | echo result.error | echohl None
endif
```

## Error Message Format

Error messages follow a consistent format: `Error: <message>\nTip: <guidance>`

```vim
" Example error message
Error: function not found: my_function
Tip: Check the spelling and ensure the function exists in the codebase.
```

This provides both the problem and actionable guidance.

## Error Categories and Handlers

### 1. Resource Not Found
**When:** Function, file, or module doesn't exist in codebase

**Handler:** `genero_tools#error#format_not_found(resource_type, resource_name)`

```vim
let msg = genero_tools#error#format_not_found('function', 'validate_input')
" Output: Error: function not found: validate_input
"         Tip: Check the spelling and ensure the function exists...
```

### 2. Invalid Path
**When:** File path is invalid or doesn't exist

**Handler:** `genero_tools#error#format_invalid_path(path)`

```vim
let msg = genero_tools#error#format_invalid_path('/invalid/path/file.4gl')
" Output: Error: Invalid path: /invalid/path/file.4gl
"         Tip: Ensure the path is correct and the file/directory exists.
```

### 3. Timeout
**When:** Command execution exceeds timeout limit

**Handler:** `genero_tools#error#format_timeout(command)`

```vim
let msg = genero_tools#error#format_timeout('lookup')
" Output: Error: Command timed out: lookup
"         Tip: The search took too long. For large codebases, try:
"           1. Use a more specific search term (e.g., "myFunc" instead of "func")
"           2. Filter by module name (e.g., "mymodule.m3:myFunc")
"           3. Filter by file path (e.g., "src/myfile.4gl:myFunc")
"           4. Increase timeout in config: let g:genero_tools_config.timeout = 20000
"           5. Enable async mode: let g:genero_tools_config.async_enabled = 1
"           6. For very large codebases (6M+ LOC), consider increasing to 30000ms
```

### 4. JSON Parse Error
**When:** genero-tools output cannot be parsed as JSON

**Handler:** `genero_tools#error#format_parse_error(error_detail)`

```vim
let msg = genero_tools#error#format_parse_error('Unexpected token at line 1')
" Output: Error: Failed to parse genero-tools output
"         Tip: This may indicate a genero-tools version mismatch or corrupted output.
"         Details: Unexpected token at line 1
```

### 5. Permission Denied
**When:** Insufficient permissions to access resource

**Handler:** `genero_tools#error#format_permission_denied(resource)`

```vim
let msg = genero_tools#error#format_permission_denied('/restricted/codebase')
" Output: Error: Permission denied accessing: /restricted/codebase
"         Tip: Check file permissions and ensure you have read access...
```

### 6. Result Too Large
**When:** Result set exceeds configured limit

**Handler:** `genero_tools#error#format_result_too_large(result_count, limit)`

```vim
let msg = genero_tools#error#format_result_too_large(5000, 1000)
" Output: Error: Too many results (5000 > 1000)
"         Tip: The search returned too many results. For large codebases, try:
"           1. Use a more specific search term (e.g., "myFunc" instead of "func")
"           2. Filter by module name (e.g., "mymodule.m3:myFunc")
"           3. Filter by file path (e.g., "src/myfile.4gl:myFunc")
"           4. Increase result_limit in config: let g:genero_tools_config.result_limit = 2000
"           5. Use pagination to view results in smaller chunks
```

## Generic Error Detection

For errors from genero-tools CLI output, use the generic handler:

```vim
function! genero_tools#error#format_from_output(output, command) abort
  let output_lower = tolower(a:output)
  
  " Detects error type from output and returns formatted message
  if output_lower =~? 'timeout\|timed out'
    return genero_tools#error#format_timeout(a:command)
  endif
  
  if output_lower =~? 'not found\|no such\|does not exist'
    return genero_tools#error#format_not_found('resource', a:command)
  endif
  
  if output_lower =~? 'permission denied\|access denied'
    return genero_tools#error#format_permission_denied(a:command)
  endif
  
  if output_lower =~? 'invalid path\|bad path'
    return genero_tools#error#format_invalid_path(a:command)
  endif
  
  " Default: return as-is with generic guidance
  return 'Error: ' . a:output . "\n" . 'Tip: Check genero-tools configuration and codebase path.'
endfunction
```

## Result Size Validation

Always check result size before returning from command execution:

```vim
let result = {
  \ 'success': v:false,
  \ 'data': {},
  \ 'error': '',
  \ 'timestamp': localtime()
  \ }

try
  let data = json_decode(output)
  
  " Check if result set is too large
  let size_error = genero_tools#error#check_result_size(data)
  if !empty(size_error)
    let result.error = size_error
    let result.success = v:false
    return result
  endif
  
  let result.success = v:true
  let result.data = data
catch
  let result.error = genero_tools#error#format_parse_error(v:exception)
endtry

return result
```

## Displaying Errors to Users

### In Command Output
```vim
if result.success
  call genero_tools#display#display_result(result.data)
else
  echohl ErrorMsg | echo result.error | echohl None
endif
```

### In Quickfix List
```vim
if result.success
  call genero_tools#display#quickfix(result.data)
else
  call setqflist([{'text': result.error, 'type': 'E'}])
  copen
endif
```

### In Popup (Neovim)
```vim
if result.success
  call genero_tools#display#popup(result.data)
else
  call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, {
    \ 'relative': 'cursor',
    \ 'row': 1,
    \ 'col': 0,
    \ 'width': 60,
    \ 'height': 10
    \ })
  call nvim_buf_set_lines(0, 0, -1, v:true, split(result.error, "\n"))
endif
```

## Large Codebase Error Guidance

For large codebases (6M+ LOC), provide specific guidance:

### Timeout Errors
```vim
" Suggest increasing timeout
Error: Command timed out: lookup
Tip: The search took too long. For large codebases, try:
  1. Use a more specific search term
  2. Filter by module or file name
  3. Increase timeout in config: let g:genero_tools_config.timeout = 20000
  4. Enable async mode: let g:genero_tools_config.async_enabled = 1
```

### Result Size Errors
```vim
" Suggest narrowing search
Error: Too many results (5000 > 1000)
Tip: The search returned too many results. Try:
  1. Use a more specific search term
  2. Filter by module or file
  3. Increase result_limit in config: let g:genero_tools_config.result_limit = 2000
```

## Error Handling in Async Operations

When executing commands asynchronously, handle errors in the callback:

```vim
function! s:on_command_complete(result) abort
  if a:result.success
    call genero_tools#display#display_result(a:result.data)
  else
    echohl ErrorMsg | echo a:result.error | echohl None
  endif
endfunction

call genero_tools#command#execute_async('lookup', ['func'], function('s:on_command_complete'))
```

## Testing Error Handling

### Unit Test Pattern
```vim
function! Test_error_format_not_found() abort
  let msg = genero_tools#error#format_not_found('function', 'my_func')
  call assert_match('Error: function not found: my_func', msg)
  call assert_match('Tip:', msg)
endfunction
```

### Integration Test Pattern
```vim
function! Test_command_returns_error_on_invalid_path() abort
  let result = genero_tools#command#execute_shell('lookup', ['/invalid/path'])
  call assert_equal(v:false, result.success)
  call assert_match('Error:', result.error)
  call assert_match('Tip:', result.error)
endfunction
```

## Common Error Scenarios

### Scenario 1: User searches for non-existent function
```vim
" User input: :GeneroLookup nonexistent_func
" Expected error:
Error: function not found: nonexistent_func
Tip: Check the spelling and ensure the function exists in the codebase.
```

### Scenario 2: Codebase path not found
```vim
" User opens file outside any genero project
" Expected error:
Error: Invalid path: /tmp/random/file.4gl
Tip: Ensure the path is correct and the file/directory exists.
```

### Scenario 3: Search times out on large codebase
```vim
" User searches for common term in 6M+ LOC codebase
" Expected error:
Error: Command timed out: lookup
Tip: The search took too long. For large codebases, try:
  1. Use a more specific search term (e.g., "myFunc" instead of "func")
  2. Filter by module name (e.g., "mymodule.m3:myFunc")
  3. Filter by file path (e.g., "src/myfile.4gl:myFunc")
  4. Increase timeout in config: let g:genero_tools_config.timeout = 20000
  5. Enable async mode: let g:genero_tools_config.async_enabled = 1
  6. For very large codebases (6M+ LOC), consider increasing to 30000ms
```

### Scenario 4: Too many results returned
```vim
" User searches for common function name
" Expected error:
Error: Too many results (5000 > 1000)
Tip: The search returned too many results. For large codebases, try:
  1. Use a more specific search term (e.g., "myFunc" instead of "func")
  2. Filter by module name (e.g., "mymodule.m3:myFunc")
  3. Filter by file path (e.g., "src/myfile.4gl:myFunc")
  4. Increase result_limit in config: let g:genero_tools_config.result_limit = 2000
  5. Use pagination to view results in smaller chunks
```

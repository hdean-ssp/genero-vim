---
inclusion: auto
fileMatchPattern: "**/*.vim"
---

# Genero-Tools CLI Integration Guide

This document describes how the plugin integrates with the genero-tools CLI and the expected command patterns, arguments, and output formats.

## CLI Tool Path

The genero-tools CLI is invoked via the `genero_tools_path` configuration:

```vim
let g:genero_tools_config.genero_tools_path = 'query.sh'
```

This can be:
- A simple command name (assumes it's in PATH): `'query.sh'`
- An absolute path: `'/usr/local/bin/query.sh'`
- A relative path: `'./scripts/query.sh'`

## Command Execution Pattern

All CLI commands follow this pattern in `command.vim`:

```vim
let cmd_line = tool_path . ' ' . command . ' ' . arg1 . ' ' . arg2
let output = system(cmd_line)
let exit_code = v:shell_error
```

### Argument Escaping

All arguments are escaped using single quotes to prevent shell injection:

```vim
function! genero_tools#command#escape_arg(arg) abort
  let escaped = substitute(a:arg, "'", "'\\\\''", 'g')
  return "'" . escaped . "'"
endfunction
```

**Example:**
```vim
let arg = "function's_name"
let escaped = genero_tools#command#escape_arg(arg)
" Result: 'function'\''s_name'
```

## Supported Commands

### 1. Lookup Command
**Purpose:** Find function definition in codebase

**Invocation:**
```vim
let result = genero_tools#command#execute_shell('lookup', ['function_name'])
```

**Expected Output (JSON):**
```json
{
  "name": "function_name",
  "file": "/path/to/file.4gl",
  "line": 42,
  "signature": "FUNCTION function_name(param1, param2) RETURNS type",
  "module": "module_name"
}
```

**Error Cases:**
- Function not found: `"Error: function not found"`
- Invalid codebase: `"Error: codebase not found"`

### 2. List Functions Command
**Purpose:** List all functions in a file

**Invocation:**
```vim
let result = genero_tools#command#execute_shell('list-functions', ['/path/to/file.4gl'])
```

**Expected Output (JSON):**
```json
{
  "file": "/path/to/file.4gl",
  "functions": [
    {
      "name": "function1",
      "line": 10,
      "signature": "FUNCTION function1() RETURNS void"
    },
    {
      "name": "function2",
      "line": 50,
      "signature": "FUNCTION function2(param) RETURNS string"
    }
  ]
}
```

### 3. List Module Files Command
**Purpose:** List all files in a module

**Invocation:**
```vim
let result = genero_tools#command#execute_shell('list-files', ['module_name'])
```

**Expected Output (JSON):**
```json
{
  "module": "module_name",
  "files": [
    "/path/to/file1.4gl",
    "/path/to/file2.4gl",
    "/path/to/file3.4gl"
  ]
}
```

### 4. Signature Command
**Purpose:** Get function signature with parameter details

**Invocation:**
```vim
let result = genero_tools#command#execute_shell('signature', ['function_name'])
```

**Expected Output (JSON):**
```json
{
  "name": "function_name",
  "signature": "FUNCTION function_name(param1 STRING, param2 INTEGER) RETURNS BOOLEAN",
  "parameters": [
    {
      "name": "param1",
      "type": "STRING"
    },
    {
      "name": "param2",
      "type": "INTEGER"
    }
  ],
  "return_type": "BOOLEAN"
}
```

### 5. Metadata Command
**Purpose:** Get file metadata (author, dates, tickets)

**Invocation:**
```vim
let result = genero_tools#command#execute_shell('metadata', ['/path/to/file.4gl'])
```

**Expected Output (JSON):**
```json
{
  "file": "/path/to/file.4gl",
  "author": "author_name",
  "created_date": "2024-01-15",
  "modified_date": "2024-03-10",
  "ticket_codes": ["TICKET-123", "TICKET-456"]
}
```

## Output Format Requirements

### JSON Parsing
All CLI output must be valid JSON. The plugin uses `json_decode()`:

```vim
try
  let data = json_decode(output)
  let result.success = v:true
  let result.data = data
catch
  let result.error = genero_tools#error#format_parse_error(v:exception)
  return result
endtry
```

### Exit Codes
- `0` - Success
- Non-zero - Failure (error message in stdout/stderr)

### Error Output
When a command fails, the CLI should output JSON with error information:

```json
{
  "error": "function not found: my_function",
  "code": "NOT_FOUND"
}
```

Or plain text error messages that are parsed by `format_from_output()`:

```
Error: function not found
```

## Timeout Handling

Commands are executed with a configurable timeout (default 10000ms):

```vim
let timeout = genero_tools#config#get('timeout')
```

If a command exceeds the timeout, `system()` will return an error. The plugin detects this and formats a helpful message:

```vim
if output_lower =~? 'timeout\|timed out'
  return genero_tools#error#format_timeout(a:command)
endif
```

**For Large Codebases:**
- Default timeout: 10000ms (10 seconds)
- Recommended for 6M+ LOC: 20000ms (20 seconds)
- Configure in vimrc:
  ```vim
  let g:genero_tools_config.timeout = 20000
  ```

## Result Size Limits

The plugin enforces a result limit to prevent overwhelming Vim:

```vim
let limit = genero_tools#config#get('result_limit')  " Default: 1000
```

If a result set exceeds this limit, an error is returned:

```vim
let size_error = genero_tools#error#check_result_size(data)
if !empty(size_error)
  let result.error = size_error
  let result.success = v:false
  return result
endif
```

**For Large Codebases:**
- Default limit: 1000 results
- Recommended for 6M+ LOC: 2000 results
- Configure in vimrc:
  ```vim
  let g:genero_tools_config.result_limit = 2000
  ```

## Codebase Path Detection

The plugin automatically detects the codebase root by searching for markers:

```vim
let markers = genero_tools#config#get('codebase_markers')
" Default: ['castle.sch', 'genero.conf', '.genero', '.git']
```

The `genero_tools#codebase#get_path()` function:
1. Starts from current file directory
2. Searches upward for any marker file
3. Returns the directory containing the marker
4. Falls back to current working directory if no marker found

**Example:**
```
/home/user/project/
  ├── castle.sch          <- Marker found here
  ├── src/
  │   └── module/
  │       └── file.4gl    <- Current file
```

When editing `file.4gl`, the codebase path is `/home/user/project/`.

## Command Execution Examples

### Example 1: Lookup Function
```vim
" User presses <leader>gl on function name 'validate_input'
let codebase_path = genero_tools#codebase#get_path()
let result = genero_tools#command#execute_shell('lookup', ['validate_input'])

" Result:
" {
"   "success": true,
"   "data": {
"     "name": "validate_input",
"     "file": "/home/user/project/src/validation.4gl",
"     "line": 42,
"     "signature": "FUNCTION validate_input(data STRING) RETURNS BOOLEAN"
"   },
"   "error": "",
"   "timestamp": 1710000000
" }
```

### Example 2: List Functions in File
```vim
" User presses <leader>gf to list functions in current file
let result = genero_tools#command#execute_shell('list-functions', ['/home/user/project/src/validation.4gl'])

" Result:
" {
"   "success": true,
"   "data": {
"     "file": "/home/user/project/src/validation.4gl",
"     "functions": [
"       {"name": "validate_input", "line": 42, "signature": "..."},
"       {"name": "validate_output", "line": 100, "signature": "..."}
"     ]
"   },
"   "error": "",
"   "timestamp": 1710000000
" }
```

### Example 3: Error Handling
```vim
" User searches for non-existent function
let result = genero_tools#command#execute_shell('lookup', ['nonexistent_func'])

" Result:
" {
"   "success": false,
"   "data": {},
"   "error": "Error: function not found: nonexistent_func\nTip: Check the spelling...",
"   "timestamp": 1710000000
" }
```

## Debugging CLI Issues

### Enable Verbose Output
```vim
" In vimrc
let g:genero_tools_config.debug = v:true
```

### Manual CLI Testing
```bash
# Test if query.sh is in PATH
which query.sh

# Test a lookup command
query.sh lookup my_function

# Test with codebase path
query.sh lookup my_function --codebase /path/to/codebase
```

### Check Plugin Logs
```vim
" View recent command executions
:messages
```

## Performance Considerations

### Async Execution
For large codebases, enable async mode to prevent Vim from blocking:

```vim
let g:genero_tools_config.async_enabled = v:true
```

This shows a progress indicator while the command executes.

### Caching
Results are cached by default with a 1-hour TTL:

```vim
let g:genero_tools_config.cache_enabled = v:true
let g:genero_tools_config.cache_ttl = 3600
let g:genero_tools_config.cache_max_size = 100
```

Cache is checked before executing CLI commands, reducing latency for repeated lookups.

### Pagination
Large result sets are paginated to prevent overwhelming Vim:

```vim
let g:genero_tools_config.pagination_size = 50
```

Results are split into pages of 50 items, with navigation commands to move between pages.

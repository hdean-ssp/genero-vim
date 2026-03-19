# Error Handling

The Genero-Tools Plugin uses standardized error message formatting and display across all modules.

## Error Message Format

All error messages follow a consistent format:

```
[MODULE] Error description
```

**Examples:**
- `[config] timeout must be positive, using default 10000`
- `[command] Function not found: myFunc`
- `[cache] Cache is full, evicting oldest entry`
- `[compiler] Failed to parse compiler output`

## Error Display Functions

### `genero_tools#error#format(module, message)`

Format an error message with the standard format.

**Parameters:**
- `module` (string): Module name (e.g., 'config', 'command', 'cache')
- `message` (string): Error description

**Returns:** Formatted error string `[MODULE] Error description`

**Example:**
```vim
let error_msg = genero_tools#error#format('config', 'timeout must be positive')
" Returns: '[config] timeout must be positive'
```

### `genero_tools#error#echo(module, message)`

Echo an error message to the command line.

**Parameters:**
- `module` (string): Module name
- `message` (string): Error description

**Example:**
```vim
call genero_tools#error#echo('command', 'Function not found: myFunc')
" Displays: [command] Function not found: myFunc
```

### `genero_tools#error#warn(module, message)`

Display a warning message with yellow highlighting.

**Parameters:**
- `module` (string): Module name
- `message` (string): Warning description

**Example:**
```vim
call genero_tools#error#warn('cache', 'Cache is nearly full')
" Displays: [cache] Cache is nearly full (with yellow highlight)
```

### `genero_tools#error#error(module, message)`

Display an error message with red highlighting.

**Parameters:**
- `module` (string): Module name
- `message` (string): Error description

**Example:**
```vim
call genero_tools#error#error('compiler', 'Compilation failed')
" Displays: [compiler] Compilation failed (with red highlight)
```

### `genero_tools#error#debug(module, message)`

Log a debug message (only if debug mode is enabled).

**Parameters:**
- `module` (string): Module name
- `message` (string): Debug message

**Example:**
```vim
call genero_tools#error#debug('command', 'Executing: query.sh lookup myFunc')
" Logs to debug stream if debug_mode is enabled
```

### `genero_tools#error#result(module, message)`

Create an error result dictionary for command functions.

**Parameters:**
- `module` (string): Module name
- `message` (string): Error description

**Returns:** Error result dictionary with structure:
```vim
{
  'success': v:false,
  'data': {},
  'error': '[MODULE] Error description',
  'timestamp': current_time
}
```

**Example:**
```vim
function! genero_tools#lookup_function(name) abort
  if empty(a:name)
    return genero_tools#error#result('command', 'Function name is required')
  endif
  " ... rest of function
endfunction
```

### `genero_tools#error#format_from_output(output, command)`

Extract and format an error message from command output.

**Parameters:**
- `output` (string): Command output (may contain multiple lines)
- `command` (string): Command name for context

**Returns:** Formatted error string `[Command] Error description`

**Behavior:**
- Searches for lines containing 'error', 'failed', or 'exception' (case-insensitive)
- Uses first matching line as error message
- Falls back to first non-empty line if no error pattern found
- Returns generic message if output is empty

**Example:**
```vim
let output = system('fglcomp myfile.4gl 2>&1')
if v:shell_error
  let error_msg = genero_tools#error#format_from_output(output, 'fglcomp')
  call genero_tools#error#error('compiler', error_msg)
endif
```

### `genero_tools#error#format_parse_error(exception)`

Format a parse error from an exception.

**Parameters:**
- `exception` (string): Exception message from try/catch block

**Returns:** Formatted error string `[Parser] Failed to parse command output: exception`

**Example:**
```vim
try
  let result = json_decode(output)
catch
  let error_msg = genero_tools#error#format_parse_error(v:exception)
  return genero_tools#error#result('parser', error_msg)
endtry
```

### `genero_tools#error#check_result_size(data)`

Check if result data exceeds reasonable size limits.

**Parameters:**
- `data` (any): Result data to check (typically a list)

**Returns:** Empty string if size is acceptable, formatted error message if too large

**Behavior:**
- Checks if data is a list exceeding 10,000 items
- Returns helpful message suggesting search refinement
- Returns empty string for non-list data or acceptable sizes

**Example:**
```vim
let result = genero_tools#execute_command('list-functions', [codebase_path])
if result.success
  let size_error = genero_tools#error#check_result_size(result.data)
  if !empty(size_error)
    call genero_tools#error#warn('command', size_error)
  endif
endif
```

## Error Handling Patterns

### Pattern 1: Validate Input

```vim
function! genero_tools#some_command(param) abort
  if empty(a:param)
    return genero_tools#error#result('module', 'Parameter is required')
  endif
  " ... rest of function
endfunction
```

### Pattern 2: Handle Exceptions

```vim
function! genero_tools#execute_command() abort
  try
    let result = system('some-command')
  catch
    return genero_tools#error#result('module', 'Command failed: ' . v:exception)
  endtry
  " ... rest of function
endfunction
```

### Pattern 3: Extract Error from Command Output

```vim
function! genero_tools#compiler#execute(file) abort
  let output = system('fglcomp ' . a:file . ' 2>&1')
  if v:shell_error
    let error_msg = genero_tools#error#format_from_output(output, 'fglcomp')
    return genero_tools#error#result('compiler', error_msg)
  endif
  " ... process output
endfunction
```

### Pattern 4: Handle Parse Errors

```vim
function! genero_tools#parse_json_output(output) abort
  try
    let result = json_decode(a:output)
  catch
    let error_msg = genero_tools#error#format_parse_error(v:exception)
    return genero_tools#error#result('parser', error_msg)
  endtry
  return result
endfunction
```

### Pattern 5: Check Result Size

```vim
function! genero_tools#lookup_function(name) abort
  let result = genero_tools#execute_command('lookup', [a:name])
  if result.success
    let size_error = genero_tools#error#check_result_size(result.data)
    if !empty(size_error)
      call genero_tools#error#warn('command', size_error)
    endif
  endif
  return result
endfunction
```

### Pattern 6: Display User Messages

```vim
function! genero_tools#display_result(result) abort
  if !a:result.success
    call genero_tools#error#error('display', a:result.error)
    return
  endif
  " ... display result
endfunction
```

### Pattern 7: Log Debug Information

```vim
function! genero_tools#debug_operation() abort
  call genero_tools#error#debug('module', 'Starting operation')
  " ... operation
  call genero_tools#error#debug('module', 'Operation complete')
endfunction
```

## Configuration

### Debug Mode

Enable debug logging to troubleshoot issues:

```vim
let g:genero_tools_config.debug_mode = 1
```

When enabled, debug messages are logged to the debug stream (Neovim only). View logs with:

```vim
:GeneroDebugStreamToggle
```

## Best Practices

1. **Use consistent module names** - Use the module filename as the module name (e.g., 'config', 'command', 'cache')

2. **Provide actionable messages** - Include specific information about what went wrong and how to fix it

3. **Use appropriate display functions**:
   - `error#error()` for critical errors that stop execution
   - `error#warn()` for warnings that don't stop execution
   - `error#debug()` for diagnostic information
   - `error#echo()` for general messages

4. **Return error results** - Command functions should return error result dictionaries, not display errors directly

5. **Log debug information** - Use `error#debug()` to log diagnostic information for troubleshooting

## Examples

### Configuration Validation Error

```vim
function! genero_tools#config#validate() abort
  let timeout = genero_tools#config#get('timeout')
  if timeout <= 0
    call genero_tools#error#warn('config', 'timeout must be positive, using default 10000')
    let g:genero_tools_config.timeout = 10000
  endif
endfunction
```

### Command Execution Error

```vim
function! genero_tools#execute_command(cmd, args) abort
  if empty(a:cmd)
    return genero_tools#error#result('command', 'Command name is required')
  endif
  
  try
    let result = system(a:cmd . ' ' . join(a:args))
  catch
    return genero_tools#error#result('command', 'Execution failed: ' . v:exception)
  endtry
  
  return {'success': v:true, 'data': result, 'error': '', 'timestamp': localtime()}
endfunction
```

### Compiler Output Error Extraction

```vim
function! genero_tools#compiler#execute(file) abort
  let output = system('fglcomp ' . a:file . ' 2>&1')
  if v:shell_error
    let error_msg = genero_tools#error#format_from_output(output, 'fglcomp')
    call genero_tools#error#error('compiler', error_msg)
    return genero_tools#error#result('compiler', error_msg)
  endif
  return {'success': v:true, 'data': output, 'error': '', 'timestamp': localtime()}
endfunction
```

### JSON Parse Error Handling

```vim
function! genero_tools#parse_json_response(output) abort
  try
    let result = json_decode(a:output)
    return result
  catch
    let error_msg = genero_tools#error#format_parse_error(v:exception)
    call genero_tools#error#error('parser', error_msg)
    return {}
  endtry
endfunction
```

### Result Size Validation

```vim
function! genero_tools#lookup_function(name) abort
  let result = genero_tools#execute_command('lookup', [a:name])
  if result.success
    let size_error = genero_tools#error#check_result_size(result.data)
    if !empty(size_error)
      call genero_tools#error#warn('command', size_error)
    endif
  endif
  return result
endfunction
```

### Display Error

```vim
function! genero_tools#display_result(result) abort
  if !a:result.success
    call genero_tools#error#error('display', a:result.error)
    return
  endif
  
  " Display successful result
  call genero_tools#display#show(a:result.data)
endfunction
```

## See Also

- [Configuration Validation](CONFIGURATION_VALIDATION_UPDATE.md) - Configuration validation examples
- [Developer Quick Reference](DEVELOPER_QUICK_REFERENCE.md) - Troubleshooting guide
- [Debug Streaming](DEBUG_STREAMING.md) - Debug stream documentation


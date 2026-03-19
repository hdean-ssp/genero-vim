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

### Pattern 3: Display User Messages

```vim
function! genero_tools#display_result(result) abort
  if !a:result.success
    call genero_tools#error#error('display', a:result.error)
    return
  endif
  " ... display result
endfunction
```

### Pattern 4: Log Debug Information

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


# Implementation Examples: Vim Genero-Tools Plugin

This document provides concrete code examples for implementing the improvements identified in the code review.

---

## 1. Configuration Validation Example

### Current Code (autoload/genero_tools/config.vim)

```vim
function! genero_tools#config#init() abort
  if !exists('g:genero_tools_config')
    let g:genero_tools_config = {}
  endif
  
  " Set defaults
  let defaults = {
    \ 'genero_tools_path': 'query.sh',
    \ 'cache_enabled': v:true,
    \ 'cache_ttl': 3600,
    \ 'cache_max_size': 100,
    \ 'display_mode': 'quickfix',
    \ 'timeout': 10000,
    \ 'async_enabled': v:true,
    \ 'result_limit': 1000,
    \ 'pagination_size': 50,
    \ }
  
  for [key, value] in items(defaults)
    if !has_key(g:genero_tools_config, key)
      let g:genero_tools_config[key] = value
    endif
  endfor
endfunction
```

### Improved Code with Validation

```vim
function! genero_tools#config#init() abort
  if !exists('g:genero_tools_config')
    let g:genero_tools_config = {}
  endif
  
  " Set defaults
  let defaults = {
    \ 'genero_tools_path': 'query.sh',
    \ 'cache_enabled': v:true,
    \ 'cache_ttl': 3600,
    \ 'cache_max_size': 100,
    \ 'display_mode': 'quickfix',
    \ 'timeout': 10000,
    \ 'async_enabled': v:true,
    \ 'result_limit': 1000,
    \ 'pagination_size': 50,
    \ 'debug_mode': v:false,
    \ }
  
  for [key, value] in items(defaults)
    if !has_key(g:genero_tools_config, key)
      let g:genero_tools_config[key] = value
    endif
  endfor
  
  " Validate configuration
  call genero_tools#config#validate()
endfunction

function! genero_tools#config#validate() abort
  " Validate timeout is positive
  let l:timeout = genero_tools#config#get('timeout')
  if l:timeout <= 0
    call genero_tools#error#warn('config', 'timeout must be positive, using default 10000')
    let g:genero_tools_config.timeout = 10000
  endif
  
  " Validate display_mode is supported
  let l:display_mode = genero_tools#config#get('display_mode')
  let l:valid_modes = ['quickfix', 'popup', 'split', 'echo', 'inline']
  if index(l:valid_modes, l:display_mode) == -1
    call genero_tools#error#warn('config', 'invalid display_mode "' . l:display_mode . '", using quickfix')
    let g:genero_tools_config.display_mode = 'quickfix'
  endif
  
  " Validate cache settings
  let l:cache_ttl = genero_tools#config#get('cache_ttl')
  if l:cache_ttl <= 0
    call genero_tools#error#warn('config', 'cache_ttl must be positive, using default 3600')
    let g:genero_tools_config.cache_ttl = 3600
  endif
  
  let l:cache_max_size = genero_tools#config#get('cache_max_size')
  if l:cache_max_size <= 0
    call genero_tools#error#warn('config', 'cache_max_size must be positive, using default 100')
    let g:genero_tools_config.cache_max_size = 100
  endif
  
  " Validate result_limit
  let l:result_limit = genero_tools#config#get('result_limit')
  if l:result_limit <= 0
    call genero_tools#error#warn('config', 'result_limit must be positive, using default 1000')
    let g:genero_tools_config.result_limit = 1000
  endif
  
  " Validate pagination_size
  let l:pagination_size = genero_tools#config#get('pagination_size')
  if l:pagination_size <= 0
    call genero_tools#error#warn('config', 'pagination_size must be positive, using default 50')
    let g:genero_tools_config.pagination_size = 50
  endif
endfunction

function! genero_tools#config#get(key) abort
  if !exists('g:genero_tools_config')
    call genero_tools#config#init()
  endif
  
  if has_key(g:genero_tools_config, a:key)
    return g:genero_tools_config[a:key]
  endif
  
  return v:false
endfunction
```

---

## 2. Standardized Error Handling Example

### Create New Error Module (autoload/genero_tools/error.vim)

```vim
" Genero-Tools Plugin - Error Handling Module
" Provides standardized error message formatting and display

" Error message format: [MODULE] Error description
function! genero_tools#error#format(module, message) abort
  return '[' . a:module . '] ' . a:message
endfunction

" Echo error message
function! genero_tools#error#echo(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  call genero_tools#display#echo(l:formatted)
endfunction

" Display warning message
function! genero_tools#error#warn(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  echohl WarningMsg
  echo l:formatted
  echohl None
endfunction

" Display error message
function! genero_tools#error#error(module, message) abort
  let l:formatted = genero_tools#error#format(a:module, a:message)
  echohl ErrorMsg
  echo l:formatted
  echohl None
endfunction

" Log debug message (if debug mode enabled)
function! genero_tools#error#debug(module, message) abort
  if genero_tools#config#get('debug_mode')
    let l:formatted = genero_tools#error#format(a:module, a:message)
    call genero_tools#debug#log(l:formatted)
  endif
endfunction

" Create error result dictionary
function! genero_tools#error#result(module, message) abort
  return {
    \ 'success': v:false,
    \ 'data': {},
    \ 'error': genero_tools#error#format(a:module, a:message),
    \ 'timestamp': localtime()
    \ }
endfunction
```

### Usage Example

```vim
" Before (inconsistent)
function! genero_tools#lookup_function(function_name) abort
  if empty(a:function_name)
    call genero_tools#display#echo('Error: No function name provided')
    return {}
  endif
endfunction

" After (consistent)
function! genero_tools#lookup_function(function_name) abort
  if empty(a:function_name)
    return genero_tools#error#result('lookup', 'No function name provided')
  endif
endfunction
```

---

## 3. Performance Metrics Example

### Create Metrics Module (autoload/genero_tools/metrics.vim)

```vim
" Genero-Tools Plugin - Performance Metrics Module
" Tracks command execution time and cache statistics

" Initialize metrics storage
function! genero_tools#metrics#init() abort
  if !exists('g:genero_tools_metrics')
    let g:genero_tools_metrics = {
      \ 'commands': {},
      \ 'cache_hits': 0,
      \ 'cache_misses': 0,
      \ }
  endif
endfunction

" Track command execution time
function! genero_tools#metrics#track_command(cmd, start_time) abort
  call genero_tools#metrics#init()
  
  let l:elapsed = reltimestr(reltime(a:start_time))
  let l:elapsed_ms = str2float(l:elapsed) * 1000
  
  if !has_key(g:genero_tools_metrics.commands, a:cmd)
    let g:genero_tools_metrics.commands[a:cmd] = {
      \ 'count': 0,
      \ 'total_time': 0,
      \ 'min_time': 999999,
      \ 'max_time': 0,
      \ }
  endif
  
  let l:stats = g:genero_tools_metrics.commands[a:cmd]
  let l:stats.count += 1
  let l:stats.total_time += l:elapsed_ms
  let l:stats.min_time = min([l:stats.min_time, l:elapsed_ms])
  let l:stats.max_time = max([l:stats.max_time, l:elapsed_ms])
  
  " Log if debug mode enabled
  if genero_tools#config#get('debug_mode')
    call genero_tools#error#debug('metrics', 'Command ' . a:cmd . ' took ' . printf('%.2f', l:elapsed_ms) . 'ms')
  endif
endfunction

" Track cache hit
function! genero_tools#metrics#track_cache_hit() abort
  call genero_tools#metrics#init()
  let g:genero_tools_metrics.cache_hits += 1
endfunction

" Track cache miss
function! genero_tools#metrics#track_cache_miss() abort
  call genero_tools#metrics#init()
  let g:genero_tools_metrics.cache_misses += 1
endfunction

" Get command statistics
function! genero_tools#metrics#get_command_stats(cmd) abort
  call genero_tools#metrics#init()
  
  if !has_key(g:genero_tools_metrics.commands, a:cmd)
    return {}
  endif
  
  let l:stats = g:genero_tools_metrics.commands[a:cmd]
  let l:avg_time = l:stats.total_time / l:stats.count
  
  return {
    \ 'count': l:stats.count,
    \ 'total_time': printf('%.2f', l:stats.total_time),
    \ 'avg_time': printf('%.2f', l:avg_time),
    \ 'min_time': printf('%.2f', l:stats.min_time),
    \ 'max_time': printf('%.2f', l:stats.max_time),
    \ }
endfunction

" Get cache statistics
function! genero_tools#metrics#get_cache_stats() abort
  call genero_tools#metrics#init()
  
  let l:total = g:genero_tools_metrics.cache_hits + g:genero_tools_metrics.cache_misses
  let l:hit_rate = l:total > 0 ? (g:genero_tools_metrics.cache_hits * 100 / l:total) : 0
  
  return {
    \ 'hits': g:genero_tools_metrics.cache_hits,
    \ 'misses': g:genero_tools_metrics.cache_misses,
    \ 'total': l:total,
    \ 'hit_rate': printf('%.1f', l:hit_rate),
    \ }
endfunction

" Show all metrics
function! genero_tools#metrics#show_all() abort
  call genero_tools#metrics#init()
  
  echo 'Performance Metrics:'
  echo ''
  
  " Show cache statistics
  let l:cache_stats = genero_tools#metrics#get_cache_stats()
  echo 'Cache Statistics:'
  echo '  Hits: ' . l:cache_stats.hits
  echo '  Misses: ' . l:cache_stats.misses
  echo '  Hit Rate: ' . l:cache_stats.hit_rate . '%'
  echo ''
  
  " Show command statistics
  echo 'Command Statistics:'
  for [l:cmd, l:stats] in items(g:genero_tools_metrics.commands)
    let l:cmd_stats = genero_tools#metrics#get_command_stats(l:cmd)
    echo '  ' . l:cmd . ':'
    echo '    Count: ' . l:cmd_stats.count
    echo '    Avg Time: ' . l:cmd_stats.avg_time . 'ms'
    echo '    Min/Max: ' . l:cmd_stats.min_time . '/' . l:cmd_stats.max_time . 'ms'
  endfor
endfunction

" Clear metrics
function! genero_tools#metrics#clear() abort
  let g:genero_tools_metrics = {
    \ 'commands': {},
    \ 'cache_hits': 0,
    \ 'cache_misses': 0,
    \ }
endfunction
```

### Usage in Command Execution

```vim
function! genero_tools#command#execute_shell(cmd, args) abort
  let l:start_time = reltime()
  
  " ... execute command ...
  
  " Track metrics
  call genero_tools#metrics#track_command(a:cmd, l:start_time)
  
  return l:result
endfunction
```

---

## 4. Cache Statistics Command Example

### Add to Commands Module

```vim
" Add to autoload/genero_tools/commands.vim

function! genero_tools#commands#show_cache_stats() abort
  let l:cache_size = genero_tools#cache#get_size()
  let l:cache_max = genero_tools#config#get('cache_max_size')
  let l:cache_stats = genero_tools#metrics#get_cache_stats()
  
  echo 'Cache Statistics:'
  echo '  Size: ' . l:cache_size . '/' . l:cache_max . ' entries'
  echo '  Hit Rate: ' . l:cache_stats.hit_rate . '%'
  echo '  Hits: ' . l:cache_stats.hits
  echo '  Misses: ' . l:cache_stats.misses
  
  " Estimate memory usage (rough estimate: ~50KB per entry)
  let l:memory_mb = (l:cache_size * 50) / 1024
  echo '  Estimated Memory: ~' . l:memory_mb . ' MB'
endfunction
```

### Register Command

```vim
" Add to plugin/genero_tools.vim

command! GeneroShowCacheStats call genero_tools#commands#show_cache_stats()
```

---

## 5. Async Operations Example (Lua)

### Implement Async Module (lua/genero_tools/async.lua)

```lua
-- Genero-Tools Lua Layer - Async Operations Module
-- Provides non-blocking command execution for Neovim

local M = {}

-- Store active jobs
local active_jobs = {}

-- Execute command asynchronously
function M.execute_command(cmd, args, callback)
  if not vim.fn.has('nvim') then
    error('Async operations require Neovim')
  end
  
  -- Build command
  local full_cmd = cmd
  if args and #args > 0 then
    for _, arg in ipairs(args) do
      full_cmd = full_cmd .. ' ' .. vim.fn.shellescape(arg)
    end
  end
  
  -- Start job
  local job_id = vim.fn.jobstart(full_cmd, {
    on_stdout = function(_, data, _)
      -- Accumulate output
      if not active_jobs[job_id] then
        active_jobs[job_id] = { output = '' }
      end
      if data then
        active_jobs[job_id].output = active_jobs[job_id].output .. table.concat(data, '\n')
      end
    end,
    on_exit = function(_, code, _)
      -- Job completed
      local output = active_jobs[job_id] and active_jobs[job_id].output or ''
      active_jobs[job_id] = nil
      
      -- Call callback with results
      if callback then
        callback({
          success = code == 0,
          output = output,
          exit_code = code,
        })
      end
    end,
  })
  
  -- Store job info
  active_jobs[job_id] = {
    cmd = cmd,
    output = '',
  }
  
  return job_id
end

-- Execute with progress indicator
function M.execute_with_progress(cmd, args, callback)
  if not vim.fn.has('nvim') then
    error('Async operations require Neovim')
  end
  
  -- Show progress indicator
  vim.notify('Executing ' .. cmd .. '...', vim.log.levels.INFO)
  
  -- Execute command
  return M.execute_command(cmd, args, function(result)
    if result.success then
      vim.notify('Command completed successfully', vim.log.levels.INFO)
    else
      vim.notify('Command failed with exit code ' .. result.exit_code, vim.log.levels.ERROR)
    end
    
    if callback then
      callback(result)
    end
  end)
end

-- Cancel running command
function M.cancel(job_id)
  if active_jobs[job_id] then
    vim.fn.jobstop(job_id)
    active_jobs[job_id] = nil
    return true
  end
  return false
end

-- Get active jobs
function M.get_active_jobs()
  return active_jobs
end

-- Clear all jobs
function M.clear_all()
  for job_id, _ in pairs(active_jobs) do
    vim.fn.jobstop(job_id)
  end
  active_jobs = {}
end

return M
```

---

## 6. Unit Test Example

### Create Test File (tests/unit/test_config.vim)

```vim
" Test configuration management

function! test_config_init_sets_defaults() abort
  " Given: Fresh configuration
  if exists('g:genero_tools_config')
    unlet g:genero_tools_config
  endif
  
  " When: Configuration is initialized
  call genero_tools#config#init()
  
  " Then: Defaults are set
  assert_equal(genero_tools#config#get('cache_enabled'), v:true)
  assert_equal(genero_tools#config#get('timeout'), 10000)
  assert_equal(genero_tools#config#get('display_mode'), 'quickfix')
  assert_equal(genero_tools#config#get('cache_ttl'), 3600)
  assert_equal(genero_tools#config#get('cache_max_size'), 100)
endfunction

function! test_config_get_returns_configured_value() abort
  " Given: Configuration with custom value
  call genero_tools#config#init()
  let g:genero_tools_config.timeout = 20000
  
  " When: Getting configuration value
  let l:timeout = genero_tools#config#get('timeout')
  
  " Then: Custom value is returned
  assert_equal(l:timeout, 20000)
endfunction

function! test_config_validation_fixes_invalid_timeout() abort
  " Given: Configuration with invalid timeout
  call genero_tools#config#init()
  let g:genero_tools_config.timeout = -1000
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Timeout is corrected to default
  assert_equal(genero_tools#config#get('timeout'), 10000)
endfunction

function! test_config_validation_fixes_invalid_display_mode() abort
  " Given: Configuration with invalid display mode
  call genero_tools#config#init()
  let g:genero_tools_config.display_mode = 'invalid_mode'
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Display mode is corrected to default
  assert_equal(genero_tools#config#get('display_mode'), 'quickfix')
endfunction

function! test_config_validation_fixes_invalid_cache_ttl() abort
  " Given: Configuration with invalid cache TTL
  call genero_tools#config#init()
  let g:genero_tools_config.cache_ttl = -100
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Cache TTL is corrected to default
  assert_equal(genero_tools#config#get('cache_ttl'), 3600)
endfunction

function! test_config_validation_fixes_invalid_cache_max_size() abort
  " Given: Configuration with invalid cache max size
  call genero_tools#config#init()
  let g:genero_tools_config.cache_max_size = 0
  
  " When: Validation runs
  call genero_tools#config#validate()
  
  " Then: Cache max size is corrected to default
  assert_equal(genero_tools#config#get('cache_max_size'), 100)
endfunction
```

---

## 7. Module Architecture Documentation Example

### Create Steering File (.kiro/steering/MODULE_ARCHITECTURE.md)

```markdown
---
inclusion: manual
---

# Module Architecture Guide

## Overview

The Vim Genero-Tools Plugin uses a modular architecture with clear separation of concerns. Each module has a specific responsibility and communicates with other modules through well-defined interfaces.

## Module Dependency Graph

```
config.vim (no dependencies)
  ↓
cache.vim (depends on config)
  ↓
command.vim (depends on config, cache)
  ↓
display.vim (depends on config)
  ↓
genero_tools.vim (depends on all above)
```

## Initialization Sequence

The plugin initializes modules in the following order:

1. **config#init()** - Load configuration with defaults
   - Reads g:genero_tools_config
   - Sets defaults for missing options
   - Validates configuration values

2. **cache#init()** - Initialize cache system
   - Creates cache storage
   - Sets up TTL tracking
   - Initializes LRU eviction

3. **command#init()** - Set up command execution
   - Prepares genero-tools CLI interface
   - Sets up timeout handling
   - Initializes async support

4. **display#init()** - Set up display modes
   - Registers display mode handlers
   - Sets up quickfix integration
   - Prepares floating window support

5. **keybindings#init()** - Register keybindings
   - Maps default keybindings
   - Sets up which-key integration
   - Registers user commands

6. **compiler#init()** - Initialize compiler integration
   - Sets up autocompile
   - Registers compiler commands
   - Initializes sign column

7. **snippets#init()** - Initialize snippet system
   - Loads snippet templates
   - Sets up snippet engine
   - Registers snippet commands

8. **svn#init()** - Initialize SVN integration
   - Detects SVN working copies
   - Sets up diff marker display
   - Registers SVN commands

## Module Responsibilities

### config.vim
**Purpose:** Configuration management

**Public Functions:**
- `config#init()` - Initialize configuration
- `config#get(key)` - Get configuration value
- `config#set(key, value)` - Set configuration value
- `config#validate()` - Validate configuration

**Dependencies:** None

**Configuration Keys:**
- genero_tools_path
- cache_enabled, cache_ttl, cache_max_size
- display_mode
- timeout
- async_enabled
- result_limit, pagination_size

### cache.vim
**Purpose:** Result caching with TTL and LRU eviction

**Public Functions:**
- `cache#init()` - Initialize cache
- `cache#get(key)` - Get cached result
- `cache#set(key, value)` - Cache result
- `cache#clear()` - Clear all cache
- `cache#get_size()` - Get cache size
- `cache#get_stats()` - Get cache statistics

**Dependencies:** config

**Cache Strategy:**
- TTL-based expiration (configurable)
- LRU eviction when full
- Automatic cleanup of expired entries

### command.vim
**Purpose:** Command execution and genero-tools CLI integration

**Public Functions:**
- `command#execute_shell(cmd, args)` - Execute command
- `command#execute_async(cmd, args, callback)` - Execute asynchronously
- `command#cancel(job_id)` - Cancel running command

**Dependencies:** config, cache

**Features:**
- Timeout protection
- JSON output parsing
- Error handling
- Async support
- Progress indicators

### display.vim
**Purpose:** Result display in multiple modes

**Public Functions:**
- `display#result(result, mode)` - Display result
- `display#echo(message)` - Echo message
- `display#quickfix(results)` - Display in quickfix
- `display#popup(results)` - Display in popup
- `display#split(results)` - Display in split
- `display#inline(results)` - Display inline

**Dependencies:** config

**Display Modes:**
- quickfix - Vim's built-in quickfix list
- popup - Floating window (Neovim only)
- split - New split window
- echo - Command line output
- inline - Inline popup

### genero_tools.vim
**Purpose:** Main API and user-facing functions

**Public Functions:**
- `lookup_function(name)` - Find function
- `list_functions_in_file(path)` - List functions
- `list_module_files(module)` - List module files
- `get_function_signature(name)` - Get signature
- `get_file_metadata(path)` - Get metadata

**Dependencies:** All modules

**Features:**
- Caching
- Error handling
- Display mode selection
- Async support

## Cross-Module Communication

### Cache Integration
All command execution goes through cache:
1. Check cache for result
2. If hit, return cached result
3. If miss, execute command
4. Cache result
5. Display result

### Display Mode Selection
Display mode is determined by configuration:
1. Get display_mode from config
2. Select appropriate display function
3. Format result for display mode
4. Display result

### Error Handling
Errors are handled consistently:
1. Catch error in module
2. Format error message
3. Return error result
4. Display error using display mode

## Module Interfaces

### Result Structure
All commands return:
```vim
{
  'success': boolean,
  'data': dict,
  'error': string,
  'timestamp': number
}
```

### Configuration Structure
Configuration is stored in:
```vim
g:genero_tools_config = {
  'genero_tools_path': string,
  'cache_enabled': boolean,
  'cache_ttl': number,
  'cache_max_size': number,
  'display_mode': string,
  'timeout': number,
  'async_enabled': boolean,
  'result_limit': number,
  'pagination_size': number,
}
```

## Adding New Modules

To add a new module:

1. Create file: `autoload/genero_tools/newmodule.vim`
2. Implement init function: `genero_tools#newmodule#init()`
3. Implement public functions with clear interfaces
4. Add to initialization sequence in `plugin/genero_tools.vim`
5. Document module in this file
6. Add tests in `tests/unit/test_newmodule.vim`

## Debugging Module Interactions

To debug module interactions:

1. Enable debug mode: `let g:genero_tools_config.debug_mode = 1`
2. Check debug stream (Neovim only)
3. Use `:GeneroConfigShow` to verify configuration
4. Use `:GeneroClearCache` to clear cache
5. Check genero-tools CLI directly

## Performance Considerations

- **Cache:** Reduces repeated queries significantly
- **Async:** Prevents editor blocking on long operations
- **Pagination:** Handles large result sets efficiently
- **Timeout:** Prevents hanging on slow systems
```

---

## Summary

These examples provide concrete implementations for the improvements identified in the code review. They can be used as templates for implementing the actual changes in the codebase.

**Key Points:**
1. Configuration validation prevents silent failures
2. Standardized error handling improves debugging
3. Performance metrics help identify bottlenecks
4. Async operations keep the editor responsive
5. Unit tests ensure code quality
6. Clear module architecture aids maintenance

For more details, see the full CODE_REVIEW.md and IMPROVEMENT_ROADMAP.md documents.


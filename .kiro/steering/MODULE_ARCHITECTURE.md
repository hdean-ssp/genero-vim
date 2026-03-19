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
- compiler_enabled, compiler_command, compiler_version
- snippets_enabled, snippet_engine
- svn_enabled
- debug_mode

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

### error.vim
**Purpose:** Standardized error handling and formatting

**Public Functions:**
- `error#format(module, message)` - Format error message
- `error#echo(module, message)` - Echo error
- `error#warn(module, message)` - Display warning
- `error#error(module, message)` - Display error
- `error#debug(module, message)` - Log debug message
- `error#result(module, message)` - Create error result

**Dependencies:** config, display

**Error Format:** `[MODULE] Error description`

### metrics.vim
**Purpose:** Performance metrics and statistics tracking

**Public Functions:**
- `metrics#init()` - Initialize metrics
- `metrics#track_command(cmd, start_time)` - Track command execution
- `metrics#track_cache_hit()` - Track cache hit
- `metrics#track_cache_miss()` - Track cache miss
- `metrics#get_command_stats(cmd)` - Get command statistics
- `metrics#get_cache_stats()` - Get cache statistics
- `metrics#show_all()` - Display all metrics
- `metrics#clear()` - Clear metrics

**Dependencies:** config

**Metrics Tracked:**
- Command execution time (count, total, min, max, average)
- Cache hit/miss ratio
- Cache size and memory usage

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
2. Format error message using error#format()
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
  'debug_mode': boolean,
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
- **Metrics:** Helps identify performance bottlenecks

## Module Interaction Diagram

```
User Input
    ↓
genero_tools.vim (API)
    ↓
    ├─→ config.vim (get settings)
    ├─→ cache.vim (check cache)
    ├─→ command.vim (execute if needed)
    ├─→ metrics.vim (track performance)
    └─→ display.vim (show results)
    ↓
User Output
```

## Testing Modules

Each module should have:
- Unit tests for public functions
- Integration tests for module interactions
- Property-based tests for correctness properties

See `tests/` directory for test structure.

## Common Patterns

### Pattern 1: Command Execution with Caching
```vim
function! genero_tools#lookup_function(function_name) abort
  let cache_key = 'lookup:' . a:function_name
  let cached = genero_tools#cache#get(cache_key)
  if !empty(cached)
    return cached
  endif
  
  let result = genero_tools#command#execute_shell('lookup', [a:function_name])
  if result.success
    call genero_tools#cache#set(cache_key, result)
  endif
  
  return result
endfunction
```

### Pattern 2: Error Handling
```vim
function! genero_tools#some_operation() abort
  if empty(some_param)
    return genero_tools#error#result('module', 'Parameter is required')
  endif
  
  " ... operation ...
endfunction
```

### Pattern 3: Display with Mode Selection
```vim
function! genero_tools#display_result(result) abort
  let display_mode = genero_tools#config#get('display_mode')
  call genero_tools#display#result(a:result, display_mode)
endfunction
```

## References

- See CODE_REVIEW.md section 1 for architecture analysis
- See IMPROVEMENT_ROADMAP.md for implementation tasks
- See IMPLEMENTATION_EXAMPLES.md for code examples
- See vimscript-conventions.md for code style


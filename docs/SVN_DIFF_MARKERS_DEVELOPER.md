# SVN Diff Markers - Developer Guide

## Quick Start

### Using the SVN Module

```vim
" Initialize the SVN module
call genero_tools#svn#init()

" Check if SVN is available
if genero_tools#svn#is_available()
  echo "SVN is installed"
endif

" Check if current file is in SVN working copy
if genero_tools#svn#is_in_working_copy(expand('%'))
  echo "File is in SVN working copy"
  
  " Get the diff
  let diff_result = genero_tools#svn#get_diff(expand('%'))
  if diff_result.success
    " Parse the diff
    let changes = genero_tools#svn#parse_diff(diff_result.diff)
    
    " Display changes
    echo "Added lines: " . string(changes.added)
    echo "Deleted lines: " . string(changes.deleted)
    echo "Modified lines: " . string(changes.modified)
  else
    echo "Error: " . diff_result.error
  endif
endif
```

## Module Architecture

### Main SVN Module (`autoload/genero_tools/svn.vim`)

Consolidated module that handles all SVN operations: detection, diff retrieval, parsing, and caching.

**Key Concepts:**
- Single entry point for all SVN operations
- Searches for `.svn` directory up the directory tree (up to 20 levels)
- Executes `svn diff` command with 5-second timeout
- Parses unified diff format with support for multiple hunks
- Integrates caching with configurable TTL (default 5 minutes)
- Handles binary files, authentication errors, and permission errors gracefully

**Usage Pattern:**
```vim
" Initialize SVN module
call genero_tools#svn#init()

" Check if SVN is available
if genero_tools#svn#is_available()
  " Check if file is in working copy
  if genero_tools#svn#is_in_working_copy(file_path)
    " Get diff
    let diff_result = genero_tools#svn#get_diff(file_path)
    
    if diff_result.success
      " Parse diff
      let changes = genero_tools#svn#parse_diff(diff_result.diff)
      
      " Place signs in sign column
      call genero_tools#svn#signs#place(bufnr('%'), changes)
      
      " Use changes
      echo "Added: " . string(changes.added)
      echo "Deleted: " . string(changes.deleted)
      echo "Modified: " . string(changes.modified)
    else
      echo "Error: " . diff_result.error
    endif
  endif
endif
```

**Module Functions:**

1. **Detection Functions**
   - `genero_tools#svn#is_available()` - Check if SVN is installed
   - `genero_tools#svn#is_in_working_copy(file_path)` - Check if file is in working copy
   - `genero_tools#svn#find_svn_dir(start_dir)` - Find .svn directory
   - `genero_tools#svn#get_working_copy_root(file_path)` - Get working copy root

2. **Diff Functions**
   - `genero_tools#svn#get_diff(file_path)` - Get SVN diff
   - `genero_tools#svn#parse_diff(diff_output)` - Parse diff output

3. **Sign Functions** (Phase 2)
   - `genero_tools#svn#signs#init()` - Initialize SVN signs
   - `genero_tools#svn#signs#place(bufnr, changes)` - Place signs in sign column
   - `genero_tools#svn#signs#clear(bufnr)` - Clear signs for buffer
   - `genero_tools#svn#signs#clear_all()` - Clear all signs

4. **Caching Functions**
   - `genero_tools#svn#cache_get(file_path)` - Get cached diff
   - `genero_tools#svn#cache_set(file_path, diff_result)` - Cache diff result
   - `genero_tools#svn#cache_invalidate(file_path)` - Invalidate cache for file
   - `genero_tools#svn#cache_clear()` - Clear all cache

5. **Initialization**
   - `genero_tools#svn#init()` - Initialize SVN module and cache

## Unified Diff Format

The parser handles standard unified diff format:

```
Index: filename
===================================================================
--- filename	(revision 100)
+++ filename	(working copy)
@@ -10,7 +10,8 @@
 context line
-deleted line
+added line
 context line
```

**Line Prefixes:**
- ` ` (space) - Context line (unchanged)
- `-` - Deleted line
- `+` - Added line
- `\` - "No newline at end of file" marker

**Hunk Header Format:**
```
@@ -OLD_START,OLD_COUNT +NEW_START,NEW_COUNT @@
```

## Caching System

### Cache Module (`autoload/genero_tools/svn/cache.vim`)

Provides efficient caching of SVN diff results with TTL (time-to-live) support and performance statistics.

**Key Features:**
- Automatic TTL-based expiration (default 5 minutes)
- LRU (Least Recently Used) eviction when cache exceeds max size
- Performance statistics tracking (hits, misses, evictions)
- Memory usage estimation
- Per-file cache invalidation

**Cache Keys**

Cache keys follow the pattern: `svn_diff:FILE_PATH`

**Cache TTL**

Default TTL is 5 minutes (300 seconds), configurable via:
```vim
let g:genero_tools_config.svn_cache_ttl = 600  " 10 minutes
```

**Cache Operations**

```vim
" Get cached diff
let cached = genero_tools#svn#cache#get(file_path)
if !empty(cached) && cached.cached
  echo "Found cached diff"
  let diff_result = cached
endif

" Set cache
call genero_tools#svn#cache#set(file_path, diff_result)

" Invalidate cache for file
call genero_tools#svn#cache#invalidate(file_path)

" Clear all cache
call genero_tools#svn#cache#clear()

" Get cache statistics
let stats = genero_tools#svn#cache#stats()
echo "Cache hits: " . stats.hits
echo "Cache misses: " . stats.misses
echo "Hit rate: " . stats.hit_rate . "%"

" Display cache statistics
:GeneroSVNCacheStats
```

**Cache Entry Structure**

```vim
{
  'diff': {
    'success': 1,
    'error': '',
    'diff': '... diff output ...'
  },
  'timestamp': 1234567890,
  'cached': 1
}
```

**Cache Statistics**

The cache tracks performance metrics:
- **hits** - Successful cache lookups
- **misses** - Cache misses
- **evictions** - Entries removed due to size limit
- **total_requests** - Total cache access attempts
- **hit_rate** - Percentage of successful hits
- **size** - Current number of cached entries
- **ttl** - Cache TTL in seconds
- **enabled** - Whether caching is enabled

**Performance Optimization**

```vim
" Check cache efficiency
let stats = genero_tools#svn#cache#stats()

if stats.hit_rate > 80
  echo "Excellent cache efficiency"
elseif stats.hit_rate > 50
  echo "Good cache efficiency"
elseif stats.hit_rate > 20
  echo "Moderate cache efficiency"
else
  echo "Low cache efficiency - consider adjusting TTL"
endif

" Monitor memory usage
let memory_kb = genero_tools#svn#cache#memory_usage()
echo "Cache memory usage: " . memory_kb . " KB"
```

### Cache Keys

Cache keys follow the pattern: `svn_diff:FILE_PATH`

### Cache TTL

Default TTL is 5 minutes (300 seconds), configurable via:
```vim
let g:genero_tools_config.svn_cache_ttl = 600  " 10 minutes
```

### Cache Operations

```vim
" Initialize cache
call genero_tools#svn#init()

" Get cached diff
let cached = genero_tools#svn#cache_get(file_path)
if !empty(cached)
  echo "Found cached diff"
  let diff_result = cached.diff
endif

" Set cache
call genero_tools#svn#cache_set(file_path, diff_result)

" Invalidate cache for file
call genero_tools#svn#cache_invalidate(file_path)

" Clear all cache
call genero_tools#svn#cache_clear()
```

### Cache Entry Structure

```vim
{
  'diff': {
    'success': 1,
    'error': '',
    'diff': '... diff output ...'
  },
  'timestamp': 1234567890
}
```

## Error Handling Module (`autoload/genero_tools/svn/error.vim`)

Provides comprehensive error handling and user-friendly error messages for SVN operations.

### Error Formatting Functions

Format error messages for specific scenarios:

- `genero_tools#svn#error#format_not_available()` - SVN not installed
- `genero_tools#svn#error#format_not_in_working_copy(file_path)` - File not in working copy
- `genero_tools#svn#error#format_binary_file(file_path)` - Binary file detected
- `genero_tools#svn#error#format_svn_failure(command, error_msg)` - SVN command failed
- `genero_tools#svn#error#format_auth_failure()` - Authentication failed
- `genero_tools#svn#error#format_permission_denied(file_path)` - Permission denied
- `genero_tools#svn#error#format_no_file()` - No file open
- `genero_tools#svn#error#format_disabled()` - SVN feature disabled
- `genero_tools#svn#error#format_cache_error(error_msg)` - Cache operation error
- `genero_tools#svn#error#format_parse_error()` - Diff parsing error

### Error Display Functions

- `genero_tools#svn#error#show(error_msg)` - Display error to user
- `genero_tools#svn#error#log(error_msg)` - Log error for debugging (verbose mode only)

### Validation Check Functions

Perform validation and display error if check fails:

- `genero_tools#svn#error#check_availability()` - Verify SVN is installed
- `genero_tools#svn#error#check_in_working_copy(file_path)` - Verify file is in working copy
- `genero_tools#svn#error#check_enabled()` - Verify SVN feature is enabled
- `genero_tools#svn#error#check_file_open()` - Verify file is open

### Result Handling Functions

Handle operation results and display error if failed:

- `genero_tools#svn#error#handle_diff_result(result)` - Handle diff operation result
- `genero_tools#svn#error#handle_status_result(result)` - Handle status operation result

### Usage Pattern

```vim
" Check prerequisites before operation
if !genero_tools#svn#error#check_enabled()
  return
endif

if !genero_tools#svn#error#check_file_open()
  return
endif

if !genero_tools#svn#error#check_availability()
  return
endif

if !genero_tools#svn#error#check_in_working_copy(expand('%'))
  return
endif

" Perform operation and handle result
let diff_result = genero_tools#svn#diff#get(expand('%'))
if !genero_tools#svn#error#handle_diff_result(diff_result)
  return
endif

" Process diff
let changes = genero_tools#svn#parser#parse(diff_result.diff)
```

### Common Error Scenarios

1. **SVN not installed**
   - `check_availability()` returns 0
   - Displays: "SVN is not installed or not available in PATH..."

2. **File not in working copy**
   - `check_in_working_copy()` returns 0
   - Displays: "File ... is not in an SVN working copy."

3. **Binary file**
   - `handle_diff_result()` returns 0
   - Displays: "File ... is a binary file..."

4. **Authentication failure**
   - `handle_diff_result()` returns 0
   - Displays: "SVN authentication failed..."

5. **Permission denied**
   - `handle_diff_result()` returns 0
   - Displays: "Permission denied accessing ..."

6. **SVN feature disabled**
   - `check_enabled()` returns 0
   - Displays: "SVN diff markers are disabled..."

7. **No file open**
   - `check_file_open()` returns 0
   - Displays: "No file is currently open..."

## Testing

### Running Tests

```vim
" Run SVN detection tests
:source test/test_svn_detection.vim
:call Test_svn_detection_all()

" Run SVN diff parser tests
:source test/test_svn_diff_parser.vim
:call Test_svn_diff_parser_all()

" Run SVN integration tests
:source test/test_svn_integration.vim
:call Test_svn_integration_all()
```

### Test Coverage

The SVN module is tested through:
- **Detection tests** - SVN availability, working copy detection, directory traversal
- **Parser tests** - Unified diff parsing, hunk handling, line number extraction
- **Integration tests** - Full workflow from detection to parsing

### Writing New Tests

Test functions must start with capital letter:

```vim
function! Test_my_feature() abort
  " Test code
  call assert_equal(expected, actual, 'Error message')
  echo 'Test passed: My feature'
endfunction
```

## Performance Considerations

### Caching Strategy

- SVN availability: Cached for 1 hour
- Diff results: Cached with configurable TTL (default 5 minutes)
- Cache is automatically invalidated when files are modified

### Optimization Tips

1. **Use caching** - Always use `get_diff_cached()` instead of `get_diff()`
2. **Batch operations** - Process multiple files in a single operation
3. **Lazy loading** - Only check SVN status when needed
4. **Timeout handling** - SVN commands have 5-second timeout

## SVN Commands Module (`autoload/genero_tools/svn/commands.vim`)

Provides user-facing commands for SVN diff markers management with centralized error handling.

**Public Functions:**

1. **`genero_tools#svn#commands#refresh()`** - Manually refresh diff markers
   - Command: `:GeneroSVNRefresh`
   - Validates prerequisites using error module:
     - `check_file_open()` - Verify file is open
     - `check_enabled()` - Verify SVN is enabled
     - `check_availability()` - Verify SVN is installed
     - `check_in_working_copy()` - Verify file is in SVN
   - Invalidates cache and retrieves fresh diff
   - Shows change summary (added/modified/deleted counts)

2. **`genero_tools#svn#commands#toggle()`** - Toggle diff markers on/off
   - Command: `:GeneroSVNToggle`
   - Validates prerequisites using error module
   - Per-buffer toggle state stored in `g:genero_tools_svn_toggle_state`
   - Calls `display_signs_for_buffer()` to re-enable signs
   - Calls `genero_tools#svn#signs#clear()` to disable signs
   - Shows status message

3. **`genero_tools#svn#commands#status()`** - Show SVN status for current file
   - Command: `:GeneroSVNStatus`
   - Validates prerequisites using error module
   - Displays file path, SVN status, and change summary
   - Shows cache status
   - Uses `handle_status_result()` for error handling

4. **`genero_tools#svn#commands#register()`** - Register all SVN commands
   - Called automatically on plugin initialization
   - Registers `:GeneroSVNRefresh`, `:GeneroSVNToggle`, `:GeneroSVNStatus`
   - Also registers cache commands: `:GeneroSVNCacheStats`, `:GeneroSVNCacheClear`

5. **`genero_tools#svn#commands#cache_stats()`** - Display cache statistics
   - Command: `:GeneroSVNCacheStats`
   - Shows cache performance metrics and efficiency assessment

6. **`genero_tools#svn#commands#cache_clear()`** - Clear cache and reset statistics
   - Command: `:GeneroSVNCacheClear`
   - Clears all cached diffs and resets performance counters

**Internal Helper Functions:**

1. **`genero_tools#svn#commands#display_signs_for_buffer()`** - Display SVN signs for current buffer
   - Internal helper function (not a user command)
   - Used by toggle command to re-enable signs
   - Silently returns if file not in working copy
   - No user-facing messages
   - Workflow:
     1. Get current file path
     2. Check if file is in SVN working copy
     3. Retrieve diff for file
     4. Parse diff to extract changes
     5. Place signs in current buffer

**Error Handling Pattern:**

All commands use the error module for consistent validation:

```vim
" Check if file is open
if !genero_tools#svn#error#check_file_open()
  return
endif

" Check if SVN is enabled
if !genero_tools#svn#error#check_enabled()
  return
endif

" Check if SVN is available
if !genero_tools#svn#error#check_availability()
  return
endif

" Check if file is in working copy
if !genero_tools#svn#error#check_in_working_copy(file_path)
  return
endif
```

This centralized approach ensures:
- Consistent error messages across all commands
- Proper error display to users
- Early validation before expensive operations
- Clear, actionable error messages

**Usage Pattern:**

```vim
" Refresh diff markers manually
:GeneroSVNRefresh

" Toggle diff markers on/off for current buffer
:GeneroSVNToggle

" Show SVN status for current file
:GeneroSVNStatus
```

**Toggle State Management:**

The toggle command maintains per-buffer state in `g:genero_tools_svn_toggle_state`:

```vim
" Toggle state is stored as:
" g:genero_tools_svn_toggle_state['buffer_N'] = 0 or 1

" Example: Check toggle state for current buffer
let bufnr = bufnr('%')
let toggle_key = 'buffer_' . bufnr
let is_enabled = get(g:genero_tools_svn_toggle_state, toggle_key, 1)
```

## Integration Points

### With SVN Module

Commands use the main SVN module functions:
- `genero_tools#svn#is_in_working_copy()` - Check if file is in working copy
- `genero_tools#svn#diff#get_diff()` - Get diff for file
- `genero_tools#svn#parser#parse_diff()` - Parse diff output
- `genero_tools#svn#cache_invalidate()` - Invalidate cache

### With Signs Module

Commands use the signs module to display/clear markers:
- `genero_tools#svn#signs#place()` - Place signs in buffer
- `genero_tools#svn#signs#clear()` - Clear signs from buffer

### With Display Module

Commands use the display module for user messages:
- `genero_tools#display#echo()` - Show messages to user

## Error Handling

Commands validate prerequisites before executing:

```vim
" Check if SVN is enabled
if !genero_tools#config#get('svn_enabled')
  call genero_tools#display#echo('SVN diff markers are disabled in configuration')
  return
endif

" Check if file is in working copy
if !genero_tools#svn#detection#is_in_working_copy(file_path)
  call genero_tools#display#echo('File is not in an SVN working copy')
  return
endif

" Check if diff retrieval succeeded
if !diff_result.success
  call genero_tools#display#echo('Error: ' . diff_result.error)
  return
endif
```

## Testing

### Command Tests

```vim
" Run SVN command tests
:source test/test_svn_commands.vim
:call Test_svn_commands_all()
```

### Test Coverage

- Refresh command with valid file
- Refresh command with invalid file
- Toggle command state management
- Toggle command sign placement/clearing
- Status command output
- Error handling for disabled SVN
- Error handling for files not in working copy

## Troubleshooting

### SVN not detected

```vim
" Check if SVN is installed
if !genero_tools#svn#is_available()
  echo "SVN is not installed or not in PATH"
endif

" Check if file is in working copy
if !genero_tools#svn#is_in_working_copy(expand('%'))
  echo "File is not in SVN working copy"
endif

" Check working copy root
let root = genero_tools#svn#get_working_copy_root(expand('%'))
if empty(root)
  echo "Could not find SVN working copy root"
else
  echo "Working copy root: " . root
endif
```

### Diff retrieval issues

```vim
" Get diff and check for errors
let diff_result = genero_tools#svn#get_diff(expand('%'))

if !diff_result.success
  echo "Error: " . diff_result.error
  
  " Check for specific error types
  if diff_result.error =~? 'binary'
    echo "File is binary, skipping diff markers"
  elseif diff_result.error =~? 'not in working copy'
    echo "File is not in SVN working copy"
  elseif diff_result.error =~? 'authentication'
    echo "SVN authentication failed"
  elseif diff_result.error =~? 'permission'
    echo "Permission denied"
  endif
endif
```

### Diff parsing issues

```vim
" Check if diff is empty
let diff_result = genero_tools#svn#get_diff(expand('%'))
if diff_result.success
  let changes = genero_tools#svn#parse_diff(diff_result.diff)
  
  if empty(changes.added) && empty(changes.deleted) && empty(changes.modified)
    echo "No changes in file"
  else
    echo "Added: " . len(changes.added)
    echo "Deleted: " . len(changes.deleted)
    echo "Modified: " . len(changes.modified)
  endif
endif
```

### Cache issues

```vim
" Clear cache if experiencing stale data
call genero_tools#svn#cache_clear()

" Invalidate cache for specific file
call genero_tools#svn#cache_invalidate(expand('%'))

" Check cache entry
let cached = genero_tools#svn#cache_get(expand('%'))
if !empty(cached)
  echo "Cache entry found"
  echo "Timestamp: " . cached.timestamp
else
  echo "No cache entry"
endif
```

## Code Style Guidelines

### Function Naming

- Public functions: `genero_tools#svn#module#function_name()`
- Private functions: `s:private_function_name()`

### Variable Naming

- Local variables: `let local_var = ...`
- Script variables: `let s:script_var = ...`
- Global variables: `let g:global_var = ...`

### Comments

- Use `"` for comments
- Document function purpose and parameters
- Include examples in documentation

### Error Handling

- Always return structured results
- Include error messages in result dict
- Handle exceptions gracefully

## References

- SVN Documentation: https://svnbook.red-bean.com/
- Vim Plugin Development: https://learnvimscriptthehardway.stevelosh.com/
- Unified Diff Format: https://en.wikipedia.org/wiki/Unified_diff

# SVN Diff Markers Feature

## Overview

The SVN Diff Markers feature provides visual indicators in the sign column showing which lines have been added, modified, or deleted compared to the SVN repository. This feature is implemented in Phase 1 with core SVN detection, diff retrieval, and parsing capabilities.

## Phase 1: Core Implementation

### Main SVN Module (`autoload/genero_tools/svn.vim`)

Provides consolidated SVN integration with detection, diff retrieval, parsing, and caching.

**Functions:**

- `genero_tools#svn#init()` - Initialize SVN module
  - Sets up SVN cache

- `genero_tools#svn#is_available()` - Check if SVN is installed
  - Returns: 1 if available, 0 if not
  - Executes `svn --version` to verify installation

- `genero_tools#svn#is_in_working_copy(file_path)` - Check if file is in SVN working copy
  - Parameters: file_path (string, optional - uses current file if empty)
  - Returns: 1 if in working copy, 0 if not
  - Searches up to 20 levels up the directory tree for `.svn` directory

- `genero_tools#svn#find_svn_dir(start_dir)` - Find .svn directory
  - Parameters: start_dir (string - starting directory)
  - Returns: path to .svn directory, or empty string if not found
  - Searches up to 20 levels up the directory tree

- `genero_tools#svn#get_working_copy_root(file_path)` - Get SVN working copy root
  - Parameters: file_path (string, optional - uses current file if empty)
  - Returns: path to working copy root, or empty string if not in working copy

- `genero_tools#svn#get_diff(file_path)` - Get SVN diff for a file
  - Parameters: file_path (string, optional - uses current file if empty)
  - Returns: dict with keys: success (bool), error (string), diff (string)
  - Handles binary files gracefully
  - Handles authentication errors
  - Handles permission errors
  - 5-second timeout to prevent hanging

- `genero_tools#svn#parse_diff(diff_output)` - Parse unified diff format
  - Parameters: diff_output (string - diff output from SVN)
  - Returns: dict with keys: added (list), deleted (list), modified (list)
  - Each list contains line numbers where changes occur
  - Handles multiple hunks and special cases

- `genero_tools#svn#cache_get(file_path)` - Get cached diff
  - Parameters: file_path (string)
  - Returns: cached entry or empty dict
  - Checks cache TTL (default 5 minutes)

- `genero_tools#svn#cache_set(file_path, diff_result)` - Cache diff result
  - Parameters: file_path (string), diff_result (dict)
  - Stores result with timestamp

- `genero_tools#svn#cache_invalidate(file_path)` - Invalidate cache for file
  - Parameters: file_path (string)

- `genero_tools#svn#cache_clear()` - Clear all SVN cache
  - Clears all cached diffs

**Example Usage:**

```vim
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

" Get working copy root
let root = genero_tools#svn#get_working_copy_root(expand('%'))
echo "Working copy root: " . root
```

### Sub-modules (Deprecated - Use Main Module)

The following sub-modules are now consolidated into the main SVN module:
- `autoload/genero_tools/svn/detection.vim` - Functionality moved to main module
- `autoload/genero_tools/svn/diff.vim` - Functionality moved to main module
- `autoload/genero_tools/svn/parser.vim` - Functionality moved to main module

For backward compatibility, these modules may still exist but should not be used directly. Use the main `genero_tools#svn#*` functions instead.

## Unified Diff Format

The parser handles standard unified diff format as produced by SVN:

```
Index: FILENAME
===================================================================
--- FILENAME	(revision OLDREV)
+++ FILENAME	(working copy)
@@ -START_LINE,NUM_LINES +START_LINE,NUM_LINES @@
 context line (unchanged)
-deleted line
+added line
 context line (unchanged)
```

**Line Prefixes:**
- ` ` (space) - Context line (unchanged)
- `-` - Deleted line
- `+` - Added line
- `\` - "No newline at end of file" marker

## Testing

### Unit Tests

- `test/test_svn_detection.vim` - Tests for SVN detection module
  - SVN availability checking
  - SVN directory detection
  - Working copy root detection
  - Cache behavior

- `test/test_svn_diff_parser.vim` - Tests for diff parser module
  - Basic diff parsing
  - Multi-hunk diff parsing
  - Empty diff handling
  - Special character handling
  - Summary generation

### Integration Tests

- `test/test_svn_integration.vim` - Integration tests
  - Full workflow (detect, retrieve, parse)
  - Realistic diff parsing
  - Cache operations
  - Summary generation
  - Empty diff handling

## Configuration

SVN diff markers can be configured through `g:genero_tools_config`:

```vim
let g:genero_tools_config = {
  \ 'svn_enabled': v:true,
  \ 'svn_show_added': v:true,
  \ 'svn_show_modified': v:true,
  \ 'svn_show_deleted': v:true,
  \ 'svn_cache_ttl': 300,
  \ 'svn_auto_update': v:true,
  \ }
```

## Performance Considerations

- SVN detection results are cached for 1 hour
- Diff results are cached with configurable TTL (default 5 minutes)
- Cache is automatically invalidated when files are modified
- SVN commands have a 5-second timeout to prevent hanging

## Error Handling

The modules handle various error scenarios gracefully:

- SVN not installed - returns error message
- File not in working copy - returns error message
- Binary files - skips diff markers
- Authentication failures - returns error message
- Permission errors - returns error message
- Network errors - returns error message

## Phase 2: Sign Column Display

### SVN Signs Module (`autoload/genero_tools/svn/signs.vim`)

Provides sign placement for SVN diff markers in the sign column.

**Functions:**

- `genero_tools#svn#signs#init()` - Initialize SVN signs
  - Defines highlight groups: GeneroSVNAdded, GeneroSVNModified, GeneroSVNDeleted
  - Defines signs with visual indicators: `+` for added, `~` for modified, `-` for deleted
  - Called automatically on first use

- `genero_tools#svn#signs#place(bufnr, changes)` - Place SVN signs for a buffer
  - Parameters: bufnr (buffer number), changes (dict with added/modified/deleted lists)
  - Places signs in sign column for each change type
  - Handles overlapping changes (modified takes precedence over added)
  - Deleted markers appear on the line before deletion

- `genero_tools#svn#signs#clear(bufnr)` - Clear SVN signs for a buffer
  - Parameters: bufnr (buffer number)
  - Removes all SVN signs from specified buffer

- `genero_tools#svn#signs#clear_all()` - Clear all SVN signs globally
  - Removes all SVN signs from all buffers

**Example Usage:**

```vim
" Initialize signs
call genero_tools#svn#signs#init()

" Get diff and parse changes
let diff_result = genero_tools#svn#get_diff(expand('%'))
if diff_result.success
  let changes = genero_tools#svn#parse_diff(diff_result.diff)
  
  " Place signs in sign column
  call genero_tools#svn#signs#place(bufnr('%'), changes)
endif

" Clear signs when done
call genero_tools#svn#signs#clear(bufnr('%'))
```

**Sign Appearance:**

- **Added** (`+`) - Green text in sign column
- **Modified** (`~`) - Yellow text in sign column
- **Deleted** (`-`) - Red text in sign column

**Sign Groups:**

Signs are placed in the `genero_svn` group to avoid conflicts with compiler signs.

## Phase 3: Caching and Performance

### SVN Cache Module (`autoload/genero_tools/svn/cache.vim`)

Provides caching system for SVN diff results with TTL (time-to-live) support and statistics tracking.

**Functions:**

- `genero_tools#svn#cache#get(file_path)` - Get cached SVN diff result
  - Parameters: file_path (string)
  - Returns: dict with keys: success (bool), error (string), diff (string), cached (bool)
  - Returns empty dict if cache is disabled or entry not found
  - Automatically expires entries based on TTL

- `genero_tools#svn#cache#set(file_path, diff_result)` - Store SVN diff in cache
  - Parameters: file_path (string), diff_result (dict)
  - Returns: 0 on success, 1 on error
  - Stores result with timestamp for TTL tracking
  - Automatically evicts oldest entries if cache exceeds max size

- `genero_tools#svn#cache#invalidate(file_path)` - Clear cache for specific file
  - Parameters: file_path (string)
  - Removes cache entry for the specified file

- `genero_tools#svn#cache#clear()` - Clear all SVN cache
  - Removes all cached diff results

- `genero_tools#svn#cache#evict_oldest()` - Evict oldest cache entry (LRU)
  - Removes the least recently used cache entry
  - Called automatically when cache exceeds max size

- `genero_tools#svn#cache#stats()` - Get cache statistics
  - Returns: dict with keys: hits, misses, evictions, total_requests, size, ttl, enabled, hit_rate
  - Provides performance metrics for cache efficiency monitoring

- `genero_tools#svn#cache#memory_usage()` - Get cache memory usage estimate
  - Returns: estimated memory usage in KB
  - Useful for monitoring cache footprint

- `genero_tools#svn#cache#reset_stats()` - Reset cache statistics
  - Clears all performance counters

- `genero_tools#svn#cache#show_stats()` - Display cache statistics
  - Command: `:GeneroSVNCacheStats`
  - Shows formatted cache statistics with efficiency assessment

**Configuration:**

Cache behavior is controlled via `g:genero_tools_config`:

```vim
let g:genero_tools_config = {
  \ 'svn_cache_ttl': 300,        " Cache TTL in seconds (default: 5 minutes)
  \ }
```

**Cache Statistics:**

The cache tracks the following metrics:
- **Hits** - Number of successful cache lookups
- **Misses** - Number of cache misses
- **Evictions** - Number of entries evicted due to size limit
- **Total Requests** - Total cache access attempts
- **Hit Rate** - Percentage of successful cache hits
- **Size** - Current number of cached entries
- **Memory Usage** - Estimated memory footprint in KB

**Example Usage:**

```vim
" Get cached diff (if available)
let cached = genero_tools#svn#cache#get(expand('%'))
if !empty(cached) && cached.cached
  echo "Using cached diff"
  let diff_result = cached
else
  " Retrieve fresh diff
  let diff_result = genero_tools#svn#get_diff(expand('%'))
  
  " Cache the result
  call genero_tools#svn#cache#set(expand('%'), diff_result)
endif

" View cache statistics
:GeneroSVNCacheStats

" Clear cache if needed
call genero_tools#svn#cache#clear()
```

## Phase 4: Commands and Status

### SVN Commands Module (`autoload/genero_tools/svn/commands.vim`)

Provides user-facing commands for SVN diff markers management.

**Functions:**

- `genero_tools#svn#commands#refresh()` - Manually refresh diff markers
  - Command: `:GeneroSVNRefresh`
  - Invalidates cache and retrieves fresh diff
  - Shows change summary (added/modified/deleted counts)

- `genero_tools#svn#commands#toggle()` - Toggle diff markers on/off
  - Command: `:GeneroSVNToggle`
  - Per-buffer toggle state
  - Preserves state across buffer switches
  - Uses internal helper `display_signs_for_buffer()` to re-enable

- `genero_tools#svn#commands#status()` - Show SVN status for current file
  - Command: `:GeneroSVNStatus`
  - Displays file path, SVN status, and change summary
  - Shows cache status

- `genero_tools#svn#commands#register()` - Register all SVN commands
  - Called automatically on plugin initialization
  - Registers `:GeneroSVNRefresh`, `:GeneroSVNToggle`, `:GeneroSVNStatus`

**Internal Helper:**

- `genero_tools#svn#commands#display_signs_for_buffer()` - Display SVN signs for current buffer
  - Internal helper function (not a user command)
  - Used by toggle command to re-enable signs
  - Silently returns if file not in working copy
  - No user-facing messages

**Example Usage:**

```vim
" Refresh diff markers manually
:GeneroSVNRefresh

" Toggle diff markers on/off for current buffer
:GeneroSVNToggle

" Show SVN status for current file
:GeneroSVNStatus
```

## Automatic Sign Loading on Buffer Entry

SVN diff markers now automatically load when you open a Genero file (`.fgl` or `.4gl`). This happens through the `BufEnter` autocommand which calls `genero_tools#svn#load_signs_for_buffer()`.

**Behavior:**

- When you open a `.fgl` or `.4gl` file, SVN signs are automatically loaded
- If the file is in an SVN working copy, diff markers appear immediately
- If the file is not in a working copy, no markers are shown (silently)
- Cached diffs are used if available (respects cache TTL)
- Fresh diffs are retrieved and cached if not in cache
- Per-buffer toggle state is respected (if you toggled markers off, they stay off)

**Configuration:**

The `svn_auto_update` setting now only controls the `BufWritePost` behavior:

```vim
let g:genero_tools_config = {
  \ 'svn_auto_update': v:true,  " Update markers on file save (default: true)
  \ }
```

- When `svn_auto_update` is `true`: Markers update automatically when you save the file
- When `svn_auto_update` is `false`: Markers only load on buffer entry, not on save
- Use `:GeneroSVNRefresh` to manually update markers at any time

**Example Workflow:**

```vim
" Open a file in SVN working copy
:e src/main.fgl

" SVN markers automatically appear in sign column
" (BufEnter autocommand triggers load_signs_for_buffer)

" Edit and save the file
" Markers automatically update (if svn_auto_update is true)

" Switch to another buffer
:e src/other.fgl

" SVN markers for the new file automatically load
```

## Future Enhancements (Phase 4+)

- Integration with compiler signs (already compatible via separate sign groups)
- Configuration options for sign appearance
- Status line integration
- Blame information display
- Diff navigation (jump to next/previous change)


## Troubleshooting

### SVN Not Detected

If SVN diff markers are not appearing:

1. **Verify SVN is installed**
   ```vim
   :echo genero_tools#svn#is_available()
   " Should return 1 if SVN is installed
   ```

2. **Verify file is in working copy**
   ```vim
   :echo genero_tools#svn#is_in_working_copy(expand('%'))
   " Should return 1 if file is in SVN working copy
   ```

3. **Check SVN feature is enabled**
   ```vim
   :echo genero_tools#config#get('svn_enabled')
   " Should return 1 (true)
   ```

4. **Enable verbose mode for debugging**
   ```vim
   let g:genero_tools_config.startup_messages = 'verbose'
   " Restart Neovim to see debug messages
   ```

### Common Error Messages

All error messages are now handled consistently through the error module, providing clear, actionable guidance:

**"SVN is not installed or not available in PATH"**
- Install SVN: `brew install svn` (macOS) or `apt-get install subversion` (Linux)
- Verify installation: `svn --version`
- Triggered by: `:GeneroSVNRefresh`, `:GeneroSVNToggle`, `:GeneroSVNStatus`

**"File ... is not in an SVN working copy"**
- File must be in a directory with `.svn` folder
- Check parent directories for `.svn` folder
- Run `svn status` in the file's directory to verify
- Triggered by: `:GeneroSVNRefresh`, `:GeneroSVNToggle`, `:GeneroSVNStatus`

**"No file is currently open"**
- Open a file before using SVN commands
- Triggered by: `:GeneroSVNRefresh`, `:GeneroSVNToggle`, `:GeneroSVNStatus`

**"SVN diff markers are disabled"**
- Enable with: `let g:genero_tools_config.svn_enabled = v:true`
- Add to your Neovim config file
- Triggered by: `:GeneroSVNRefresh`, `:GeneroSVNToggle`, `:GeneroSVNStatus`

**"File ... is a binary file"**
- SVN diff markers only work with text files
- Binary files are automatically skipped

**"SVN authentication failed"**
- Check SVN credentials
- Run `svn status` to authenticate
- Check `.subversion/auth/` directory

**"Permission denied accessing ..."**
- Check file permissions: `ls -la filename`
- Check directory permissions: `ls -la directory`
- Ensure read access to file and parent directories

### Cache Issues

If diff markers are showing stale data:

1. **Clear cache for current file**
   ```vim
   :GeneroSVNRefresh
   ```

2. **Clear all cache**
   ```vim
   :call genero_tools#svn#cache_clear()
   ```

3. **Check cache statistics**
   ```vim
   :GeneroSVNCacheStats
   ```

4. **Adjust cache TTL**
   ```vim
   let g:genero_tools_config.svn_cache_ttl = 600  " 10 minutes instead of 5
   ```

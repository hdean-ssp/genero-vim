# SVN Diff Markers - Architecture Guide

## Module Structure

```
autoload/genero_tools/svn/
├── detection.vim      # SVN availability and working copy detection
├── diff.vim           # SVN diff retrieval with error handling
├── parser.vim         # Unified diff format parsing
├── signs.vim          # Sign column display and management
├── cache.vim          # Performance optimization with TTL
├── commands.vim       # User-facing commands
├── error.vim          # Comprehensive error handling
└── svn.vim            # Main module (integration and delegation)
```

## Core Concepts

### 1. Detection Module

Detects SVN availability and working copy status.

```vim
" Check if SVN is installed
if genero_tools#svn#detection#is_available()
  " SVN is available
endif

" Check if file is in SVN working copy
if genero_tools#svn#detection#is_in_working_copy(file_path)
  " File is under SVN control
endif

" Get working copy root
let root = genero_tools#svn#detection#get_working_copy_root(file_path)
```

### 2. Diff Module

Retrieves and parses SVN diff output.

```vim
" Get diff for file
let result = genero_tools#svn#diff#get_diff(file_path)
if result.success
  let diff_output = result.diff
else
  let error_msg = result.error
endif

" Get SVN status
let status = genero_tools#svn#diff#get_status(file_path)
```

### 3. Parser Module

Extracts change information from unified diff format with intelligent modification detection.

```vim
" Parse diff output
let changes = genero_tools#svn#parser#parse_diff(diff_output)
" Returns: {added: [lines], modified: [lines], deleted: [lines]}

" Get summary statistics
let summary = genero_tools#svn#parser#get_summary(diff_output)
" Returns: {added_count, modified_count, deleted_count, total_changes}
```

**Modification Detection:**

The parser automatically detects modified lines by identifying consecutive deleted/added pairs in the unified diff. When a deleted line is immediately followed by an added line, the parser marks the **added line number** (new version) as modified. This ensures visual markers appear on the current line in the editor.

**Example:**
```
-old_value = 5      (deleted line - not marked)
+old_value = 10     (added line - marked as modified)
```

The added line number is marked as modified because:
1. It represents the current state of the code
2. Visual markers should appear on lines that exist in the working copy
3. Users can see the change at the line they're editing

### 4. Signs Module

Displays visual indicators in sign column.

```vim
" Initialize signs (called once at startup)
call genero_tools#svn#signs#init()

" Place signs for changes
call genero_tools#svn#signs#place(bufnr, changes)

" Clear all SVN signs
call genero_tools#svn#signs#clear(bufnr)
```

### 5. Cache Module

Optimizes performance with TTL-based caching.

```vim
" Get cached diff (if available and not expired)
let cached = genero_tools#svn#cache#get(file_path)

" Store diff in cache
call genero_tools#svn#cache#set(file_path, diff_result)

" Invalidate cache for file
call genero_tools#svn#cache#invalidate(file_path)

" Get cache statistics
let stats = genero_tools#svn#cache#stats()
```

### 6. Error Module

Provides comprehensive error handling.

```vim
" Format error messages
let msg = genero_tools#svn#error#format_not_available()

" Check conditions and show errors
if !genero_tools#svn#error#check_availability()
  return  " Error already shown to user
endif

" Handle operation results
if !genero_tools#svn#error#handle_diff_result(result)
  return  " Error already shown to user
endif
```

### 7. Commands Module

Implements user-facing commands.

```vim
" Refresh diff markers
:GeneroSVNRefresh

" Toggle markers on/off
:GeneroSVNToggle

" Show SVN status
:GeneroSVNStatus

" Cache management
:GeneroSVNCacheStats
:GeneroSVNCacheClear
```

## Data Flow

### Refresh Workflow

```
User runs :GeneroSVNRefresh
  ↓
check_file_open()
check_enabled()
check_availability()
check_in_working_copy()
  ↓
cache_invalidate(file_path)
  ↓
get_diff(file_path)
  ↓
cache_set(file_path, diff_result)
  ↓
parse_diff(diff_output)
  ↓
signs#place(bufnr, changes)
  ↓
Display success message
```

### Error Handling Flow

```
Operation fails
  ↓
format_error_message()
  ↓
show_error_to_user()
  ↓
log_error_for_debugging()
  ↓
Return error result
```

## Integration Points

### With Configuration System

```vim
" SVN options in config
let g:genero_tools_config = {
  \ 'svn_enabled': v:true,
  \ 'svn_show_added': v:true,
  \ 'svn_show_modified': v:true,
  \ 'svn_show_deleted': v:true,
  \ 'svn_cache_ttl': 300,
  \ 'svn_auto_update': v:true,
  \ }
```

### With Display System

```vim
" Uses genero_tools#display#echo() for messages
call genero_tools#display#echo('SVN markers refreshed: +5 ~3 -1')
```

### With Sign Column

```vim
" Uses separate sign group to avoid conflicts
" Compiler signs: group=genero_compiler
" SVN signs: group=genero_svn
```

## Extension Points

### Adding New SVN Commands

```vim
" In autoload/genero_tools/svn/commands.vim
function! genero_tools#svn#commands#my_command() abort
  " Check prerequisites
  if !genero_tools#svn#error#check_file_open()
    return
  endif
  
  " Perform operation
  let result = genero_tools#svn#diff#get_diff(expand('%'))
  
  " Handle result
  if !genero_tools#svn#error#handle_diff_result(result)
    return
  endif
  
  " Display result
  call genero_tools#display#echo('Success!')
endfunction

" Register command
command! GeneroSVNMyCommand call genero_tools#svn#commands#my_command()
```

### Adding New Error Scenarios

```vim
" In autoload/genero_tools/svn/error.vim
function! genero_tools#svn#error#format_my_error(context) abort
  return 'My error: ' . a:context
endfunction

function! genero_tools#svn#error#check_my_condition() abort
  if !my_condition_met()
    call genero_tools#svn#error#show(genero_tools#svn#error#format_my_error('details'))
    return 0
  endif
  return 1
endfunction
```

## Performance Considerations

### Cache Strategy

- **TTL:** 5 minutes (configurable)
- **Max Size:** Automatic LRU eviction
- **Hit Rate:** Typical 60-90% for normal workflows

### Optimization Tips

```vim
" For large files, increase cache TTL
let g:genero_tools_config.svn_cache_ttl = 600

" For frequently changing files, disable auto-update
let g:genero_tools_config.svn_auto_update = v:false

" Manually refresh when needed
:GeneroSVNRefresh
```

## Testing

### Unit Tests

```bash
# Test detection module
vim -u NONE -N -c "source test/test_svn_detection.vim | call Test_svn_detection_all()"

# Test diff module
vim -u NONE -N -c "source test/test_svn_diff.vim | call Test_svn_diff_all()"

# Test error handling
vim -u NONE -N -c "source test/test_svn_error_handling.vim | call Test_svn_error_handling_all()"
```

### Integration Tests

```bash
# Test command workflows
vim -u NONE -N -c "source test/test_svn_commands.vim | call Test_svn_commands_all()"

# Test error integration
vim -u NONE -N -c "source test/test_svn_error_integration.vim | call Test_svn_error_integration_all()"
```

## Debugging

### Enable Verbose Logging

```vim
" Set startup messages to verbose
let g:genero_tools_config.startup_messages = 'verbose'

" Errors will be logged with [SVN] prefix
```

### Check Cache Status

```vim
" View cache statistics
:GeneroSVNCacheStats

" Check if file is cached
let cached = genero_tools#svn#cache#get(expand('%'))
echo !empty(cached) ? 'Cached' : 'Not cached'
```

### Verify SVN Status

```vim
" Check if SVN is available
echo genero_tools#svn#detection#is_available()

" Check if file is in working copy
echo genero_tools#svn#detection#is_in_working_copy(expand('%'))
```

---

**For user documentation:** See `docs/SVN_DIFF_MARKERS_USER_GUIDE.md`

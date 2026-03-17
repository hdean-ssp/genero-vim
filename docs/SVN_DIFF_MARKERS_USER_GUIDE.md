# SVN Diff Markers - User Guide

## Quick Start

SVN diff markers automatically display visual indicators in the sign column showing which lines have been added, modified, or deleted compared to the SVN repository.

### Basic Usage

```vim
" Manually refresh diff markers
:GeneroSVNRefresh

" Toggle diff markers on/off for current buffer
:GeneroSVNToggle

" Show SVN status for current file
:GeneroSVNStatus
```

### Sign Column Display

```
  1  +  function new_function() {
  2  +    return 42
  3  +  }
  4  
  5  ~  function modified_function() {
  6  ~    return 100
  7  
  8  -  function deleted_function() {
  9     function another_function() {
```

- `+` (green) = Added lines
- `~` (yellow) = Modified lines
- `-` (red) = Deleted lines

## Configuration

### Enable/Disable SVN Markers

```vim
" Enable SVN diff markers (default: true)
let g:genero_tools_config.svn_enabled = v:true

" Disable SVN diff markers
let g:genero_tools_config.svn_enabled = v:false
```

### Show/Hide Specific Change Types

```vim
" Show added lines (default: true)
let g:genero_tools_config.svn_show_added = v:true

" Show modified lines (default: true)
let g:genero_tools_config.svn_show_modified = v:true

" Show deleted lines (default: true)
let g:genero_tools_config.svn_show_deleted = v:true
```

### Cache Configuration

```vim
" Cache TTL in seconds (default: 300 = 5 minutes)
let g:genero_tools_config.svn_cache_ttl = 300

" Disable caching (set to 0)
let g:genero_tools_config.svn_cache_ttl = 0

" Auto-update markers on file save (default: true)
let g:genero_tools_config.svn_auto_update = v:true
```

## Cache Management

### View Cache Statistics

```vim
:GeneroSVNCacheStats
```

Output shows:
- Cache hits/misses
- Hit rate percentage
- Memory usage
- Efficiency assessment

### Clear Cache

```vim
" Clear all cached diffs
:GeneroSVNCacheClear

" Clear cache for current file
call genero_tools#svn#cache_invalidate(expand('%'))
```

## Common Workflows

### Review Changes Before Commit

```vim
" Open file in SVN working copy
:e path/to/file.fgl

" View diff markers in sign column
" Markers show all changes at a glance

" Get detailed status
:GeneroSVNStatus

" Output shows:
" - File status (M = modified)
" - Added/modified/deleted line counts
" - Cache status
```

### Temporarily Hide Markers

```vim
" Toggle markers off for current buffer
:GeneroSVNToggle

" Work without visual clutter

" Toggle markers back on
:GeneroSVNToggle
```

### Refresh After External Changes

```vim
" If SVN status changed externally
:GeneroSVNRefresh

" Markers update to reflect current state
```

## Troubleshooting

### "SVN is not installed"

**Solution:** Install SVN
```bash
# macOS
brew install subversion

# Ubuntu/Debian
sudo apt-get install subversion

# CentOS/RHEL
sudo yum install subversion
```

### "File is not in an SVN working copy"

**Solution:** File must be in an SVN repository
```bash
# Check if directory is under SVN
svn status /path/to/file

# If not, initialize SVN or check out repository
svn checkout <repository-url> <local-path>
```

### "SVN authentication failed"

**Solution:** Check SVN credentials
```bash
# Test SVN access
svn status

# If prompted, enter credentials
# Credentials are cached by SVN
```

### Markers not updating

**Solution:** Manually refresh
```vim
:GeneroSVNRefresh
```

Or check if auto-update is enabled:
```vim
echo g:genero_tools_config.svn_auto_update
```

## Performance Tips

### For Large Files (1000+ lines)

```vim
" Increase cache TTL to reduce SVN calls
let g:genero_tools_config.svn_cache_ttl = 600  " 10 minutes

" Disable auto-update if file changes frequently
let g:genero_tools_config.svn_auto_update = v:false

" Manually refresh when needed
:GeneroSVNRefresh
```

### Monitor Cache Efficiency

```vim
" Check cache hit rate
:GeneroSVNCacheStats

" If hit rate < 50%, consider:
" - Increasing cache TTL
" - Disabling auto-update
" - Clearing cache periodically
```

## Integration with Compiler

SVN diff markers work alongside compiler error markers:
- SVN markers use separate sign group (no conflicts)
- Both can display simultaneously
- Each uses distinct visual indicators

```vim
" Both features active
" Compiler signs: ✕ (errors), ⚠ (warnings)
" SVN signs: + (added), ~ (modified), - (deleted)
```

## Keyboard Shortcuts

Add to your `init.vim` or `.vimrc`:

```vim
" Refresh SVN markers
nnoremap <leader>sr :GeneroSVNRefresh<CR>

" Toggle SVN markers
nnoremap <leader>st :GeneroSVNToggle<CR>

" Show SVN status
nnoremap <leader>ss :GeneroSVNStatus<CR>

" Show cache stats
nnoremap <leader>sc :GeneroSVNCacheStats<CR>
```

## Examples

### Example 1: Review Changes

```vim
" Open modified file
:e src/main.fgl

" See markers in sign column
" + lines = new code
" ~ lines = modified code
" - lines = deleted code

" Get summary
:GeneroSVNStatus

" Output:
" === SVN Status ===
" File: src/main.fgl
" Status: M
" Changes:
"   Added lines: 5
"   Modified lines: 3
"   Deleted lines: 1
"   Total changes: 9
" Cache: Cached (fresh)
```

### Example 2: Disable for Specific File

```vim
" Open file
:e src/config.fgl

" Disable markers for this buffer only
:GeneroSVNToggle

" Markers hidden, file shows without visual clutter

" Re-enable when needed
:GeneroSVNToggle
```

### Example 3: Cache Management

```vim
" Check cache efficiency
:GeneroSVNCacheStats

" Output shows hit rate and memory usage
" If hit rate is low, clear and rebuild cache
:GeneroSVNCacheClear

" Cache rebuilds on next refresh
:GeneroSVNRefresh
```

---

**For more information:** See `docs/SVN_DIFF_MARKERS_DEVELOPER.md` for architecture details.

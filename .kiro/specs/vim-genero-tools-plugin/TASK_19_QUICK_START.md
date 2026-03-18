# SVN Diff Markers - Quick Start Card

## Installation

The SVN Diff Markers feature is built into the genero-tools plugin. No additional installation needed.

## Basic Usage

### View Diff Markers

Open any file in an SVN working copy. Markers appear automatically in the sign column:

```
+ (green)   = Added lines
~ (yellow)  = Modified lines
- (red)     = Deleted lines
```

### Commands

```vim
:GeneroSVNRefresh      " Refresh markers
:GeneroSVNToggle       " Toggle on/off
:GeneroSVNStatus       " Show status
:GeneroSVNCacheStats   " View cache
:GeneroSVNCacheClear   " Clear cache
```

### Configuration

```vim
" Enable/disable
let g:genero_tools_config.svn_enabled = v:true

" Show specific types
let g:genero_tools_config.svn_show_added = v:true
let g:genero_tools_config.svn_show_modified = v:true
let g:genero_tools_config.svn_show_deleted = v:true

" Cache settings
let g:genero_tools_config.svn_cache_ttl = 300      " 5 minutes
let g:genero_tools_config.svn_auto_update = v:true " Update on save
```

### Keyboard Shortcuts

Add to your `init.vim`:

```vim
nnoremap <leader>sr :GeneroSVNRefresh<CR>
nnoremap <leader>st :GeneroSVNToggle<CR>
nnoremap <leader>ss :GeneroSVNStatus<CR>
```

## Common Tasks

### Review Changes

```vim
:e src/main.fgl
" See markers in sign column
:GeneroSVNStatus
" View detailed summary
```

### Hide Markers Temporarily

```vim
:GeneroSVNToggle
" Work without visual clutter
:GeneroSVNToggle
" Re-enable
```

### Refresh After External Changes

```vim
:GeneroSVNRefresh
```

### Check Cache Efficiency

```vim
:GeneroSVNCacheStats
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No markers appear | Check if file is in SVN: `svn status` |
| "SVN not installed" | Install SVN: `brew install subversion` |
| "Not in working copy" | File must be in SVN repository |
| "Auth failed" | Check SVN credentials |
| Markers not updating | Run `:GeneroSVNRefresh` |

## Performance Tips

### For Large Files

```vim
" Increase cache TTL
let g:genero_tools_config.svn_cache_ttl = 600

" Disable auto-update
let g:genero_tools_config.svn_auto_update = v:false

" Manually refresh when needed
:GeneroSVNRefresh
```

### Monitor Cache

```vim
:GeneroSVNCacheStats
" Check hit rate and memory usage
```

## Documentation

- **User Guide:** `docs/SVN_DIFF_MARKERS_USER_GUIDE.md`
- **Architecture:** `docs/SVN_DIFF_MARKERS_ARCHITECTURE.md`
- **Specification:** `docs/SVN_DIFF_MARKERS.md`

## Examples

### Example 1: Review Before Commit

```vim
:e src/main.fgl
" See all changes at a glance in sign column
:GeneroSVNStatus
" Get detailed summary
```

### Example 2: Disable for Specific File

```vim
:e src/config.fgl
:GeneroSVNToggle
" Markers hidden for this buffer
```

### Example 3: Cache Management

```vim
:GeneroSVNCacheStats
" Check efficiency
:GeneroSVNCacheClear
" Clear and rebuild
```

---

**For detailed information, see the full user guide: `docs/SVN_DIFF_MARKERS_USER_GUIDE.md`**

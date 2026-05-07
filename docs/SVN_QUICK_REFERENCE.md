# SVN Features Quick Reference

Quick reference for all SVN features in Genero-Tools.

## Commands

### Diff Markers
| Command | Description |
|---------|-------------|
| `:GeneroSVNRefresh` | Manually refresh diff markers |
| `:GeneroSVNToggle` | Toggle diff markers on/off |
| `:GeneroSVNStatus` | Show SVN status for current file |
| `:GeneroSVNCacheStats` | Show cache statistics |
| `:GeneroSVNCacheClear` | Clear SVN cache |

### Blame
| Command | Description |
|---------|-------------|
| `:GeneroSVNBlame` | Show blame for entire file |
| `:GeneroSVNBlameCurrentLine` | Show blame for current line |
| `:GeneroSVNBlameRange` | Show blame for range (use with visual selection) |

### Revert
| Command | Description |
|---------|-------------|
| `:GeneroSVNRevertLine` | Revert current line to base |
| `:GeneroSVNRevertRange` | Revert range to base (immediate) |
| `:GeneroSVNRevertRangeConfirm` | Revert range with preview and confirmation |
| `:GeneroSVNRevertAllChanges` | Revert all changes in file (with confirmation) |

## Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `<leader>sb` | Normal | Show blame for current line |
| `<leader>sb` | Visual | Show blame for selection |
| `<leader>sr` | Normal | Revert current line |
| `<leader>sr` | Visual | Revert selection (with confirmation) |
| `<leader>ss` | Normal | Show SVN status |
| `<leader>sR` | Normal | Refresh SVN markers |

**Note:** Default leader is `\` (backslash). Change with `let mapleader = ","`

## Configuration

```vim
" Enable/disable SVN integration
let g:genero_tools_config.svn_enabled = 1

" Show/hide specific change types
let g:genero_tools_config.svn_show_added = 1
let g:genero_tools_config.svn_show_modified = 1
let g:genero_tools_config.svn_show_deleted = 1

" Cache TTL in seconds (0 to disable)
let g:genero_tools_config.svn_cache_ttl = 300

" Auto-update on file save
let g:genero_tools_config.svn_auto_update = 1
```

## Sign Column Markers

| Sign | Meaning |
|------|---------|
| `+` (green) | Added line |
| `~` (yellow) | Modified line |
| `-` (red) | Deleted line |
| `E\|+` | Compiler error + SVN added |
| `W\|~` | Compiler warning + SVN modified |

## Common Workflows

### Check Line History
```vim
<leader>sb          " Show who last modified this line
```

### Revert Debug Code
```vim
V                   " Visual line mode
jjj                 " Select lines
<leader>sr          " Revert with confirmation
y                   " Confirm
```

### Review All Changes
```vim
:GeneroSVNStatus    " See summary
:GeneroSVNBlame     " See full blame
```

### Undo Experimental Changes
```vim
:10,50GeneroSVNRevertRangeConfirm    " Preview and revert lines 10-50
```

## Tips

1. **Use visual mode** for multi-line operations
2. **Blame is cached** - use `:GeneroSVNCacheClear` if stale
3. **Revert is undoable** - use `u` to undo a revert
4. **Preview before revert** - use `:GeneroSVNRevertRangeConfirm` for safety
5. **Check status first** - `:GeneroSVNStatus` shows what changed

## See Also

- [SVN Blame and Revert Guide](SVN_BLAME_AND_REVERT.md) - Detailed documentation
- [SVN Diff Markers](SVN_DIFF_MARKERS.md) - Diff marker features
- [Configuration](CONFIGURATION.md) - All configuration options

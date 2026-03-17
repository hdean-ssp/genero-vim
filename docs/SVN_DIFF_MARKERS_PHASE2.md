# SVN Diff Markers - Phase 2 Implementation Guide

## Overview

Phase 2 of the SVN Diff Markers feature implements visual indicators in the sign column showing which lines have been added, modified, or deleted compared to the SVN repository.

## Architecture

### Module Structure

```
autoload/genero_tools/svn/
├── detection.vim    (Phase 1) - SVN detection
├── diff.vim         (Phase 1) - SVN diff retrieval
├── parser.vim       (Phase 1) - Diff parsing
└── signs.vim        (Phase 2) - Sign placement
```

### Sign Groups

The implementation uses a separate sign group `genero_svn` to avoid conflicts with compiler signs:

- **Compiler signs**: `group=genero_compiler` (errors, warnings, info)
- **SVN signs**: `group=genero_svn` (added, modified, deleted)

This allows both sign types to coexist without interference.

## API Reference

### Initialization

```vim
" Initialize SVN signs (called automatically during module init)
call genero_tools#svn#signs#init()
```

This function:
- Defines highlight groups (GeneroSVNAdded, GeneroSVNModified, GeneroSVNDeleted)
- Creates sign definitions with appropriate symbols and colors
- Should be called once during plugin initialization

### Sign Placement

```vim
" Place signs for a buffer
call genero_tools#svn#signs#place(bufnr, changes)
```

Parameters:
- `bufnr`: Buffer number (use `bufnr('%')` for current buffer)
- `changes`: Dictionary with keys:
  - `added`: List of line numbers with added lines
  - `modified`: List of line numbers with modified lines
  - `deleted`: List of line numbers with deleted lines

Example:
```vim
let changes = {
  \ 'added': [1, 2, 3],
  \ 'modified': [5, 6],
  \ 'deleted': [10, 11]
  \ }
call genero_tools#svn#signs#place(bufnr('%'), changes)
```

### Sign Clearing

```vim
" Clear SVN signs for a specific buffer
call genero_tools#svn#signs#clear(bufnr)

" Clear all SVN signs globally
call genero_tools#svn#signs#clear_all()
```

### Main Module Integration

```vim
" Display SVN signs for current buffer
call genero_tools#svn#display_signs()

" Clear SVN signs for current buffer
call genero_tools#svn#clear_signs()
```

## Sign Symbols and Colors

| Change Type | Symbol | Color  | Highlight Group      |
|-------------|--------|--------|----------------------|
| Added       | `+`    | Green  | GeneroSVNAdded       |
| Modified    | `~`    | Yellow | GeneroSVNModified    |
| Deleted     | `-`    | Red    | GeneroSVNDeleted     |

## Implementation Details

### Deleted Line Handling

Deleted lines show a marker on the line **before** the deletion:
- If deletion is at line 5, marker appears on line 4
- If deletion is at line 1, marker appears on line 1 (special case)

This prevents markers from appearing on non-existent lines.

### Overlapping Changes

If a line appears in both `added` and `modified` lists:
- The line is treated as **modified** (modified takes precedence)
- Only one sign is placed (the modified sign)

### Buffer-Specific Signs

Signs are placed per-buffer using the `buffer=<bufnr>` parameter:
- Each buffer maintains its own set of signs
- Clearing signs in one buffer doesn't affect other buffers
- Multiple files can be edited simultaneously with independent signs

## Usage Example

```vim
" Get diff for current file
let diff_result = genero_tools#svn#diff#get_diff(expand('%'))

if diff_result.success
  " Parse the diff
  let changes = genero_tools#svn#parser#parse_diff(diff_result.diff)
  
  " Place signs in current buffer
  call genero_tools#svn#signs#place(bufnr('%'), changes)
endif
```

Or use the convenience function:

```vim
" Display signs for current buffer (handles all steps)
call genero_tools#svn#display_signs()
```

## Testing

### Unit Tests

Run unit tests for the signs module:
```vim
:source test/test_svn_signs.vim
:call Test_svn_signs_all()
```

### Integration Tests

Run integration tests:
```vim
:source test/test_svn_signs_integration.vim
:call Test_svn_signs_integration_all()
```

## Performance Considerations

1. **Sign Placement**: O(n) where n is the number of changes
2. **Sign Clearing**: O(1) - uses `sign unplace * group=genero_svn`
3. **Memory**: Minimal - only stores sign IDs and line numbers
4. **Vim Performance**: No noticeable impact even with 1000+ changes

## Compatibility

- **Vim**: 8.0+
- **Neovim**: 0.4+
- **Sign Groups**: Requires Vim 8.1.0+ or Neovim 0.4+

## Customization

### Custom Highlight Colors

Users can customize highlight colors in their vimrc:

```vim
highlight GeneroSVNAdded ctermfg=2 guifg=#00ff00
highlight GeneroSVNModified ctermfg=3 guifg=#ffff00
highlight GeneroSVNDeleted ctermfg=1 guifg=#ff0000
```

### Custom Sign Symbols

To customize sign symbols, modify the sign definitions:

```vim
sign define GeneroSVNAdded text=✚ texthl=GeneroSVNAdded
sign define GeneroSVNModified text=✎ texthl=GeneroSVNModified
sign define GeneroSVNDeleted text=✕ texthl=GeneroSVNDeleted
```

## Troubleshooting

### Signs Not Appearing

1. Verify SVN module is initialized: `call genero_tools#svn#init()`
2. Check file is in SVN working copy: `call genero_tools#svn#is_in_working_copy(expand('%'))`
3. Verify diff retrieval works: `echo genero_tools#svn#diff#get_diff(expand('%'))`
4. Check sign column is visible: `:set signcolumn=yes`

### Signs Conflicting with Compiler Signs

This shouldn't happen because:
- SVN signs use `group=genero_svn`
- Compiler signs use `group=genero_compiler`
- Sign groups are independent

If conflicts occur, verify sign group usage in both modules.

### Performance Issues

If sign placement is slow:
1. Check number of changes (should be < 1000 for good performance)
2. Verify diff retrieval isn't timing out
3. Consider caching diff results (Phase 4)

## Related Documentation

- [SVN Diff Markers Specification](../specs/vim-genero-tools-plugin/svn-diff-markers.md)
- [Compiler Signs Integration](COMPILER_INTEGRATION.md)
- [Sign Column Display](../specs/vim-genero-tools-plugin/svn-diff-markers.md#193-sign-column-display)

## Next Steps

Phase 3 has been implemented with:
- SVN Commands Module (`autoload/genero_tools/svn/commands.vim`)
- Configuration options for SVN feature
- Commands: `:GeneroSVNRefresh`, `:GeneroSVNToggle`, `:GeneroSVNStatus`
- Per-buffer toggle state management
- Internal helper function for sign display

See [SVN Diff Markers](SVN_DIFF_MARKERS.md) for command documentation.


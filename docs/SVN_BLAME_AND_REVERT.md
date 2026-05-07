# SVN Blame and Selective Revert

This document describes the SVN blame and selective revert features in Genero-Tools.

## Overview

The SVN integration has been enhanced with two powerful features:

1. **SVN Blame** - View authorship information for lines in your buffer
2. **Selective Revert** - Revert specific lines or sections to their SVN base version

These features work seamlessly with the existing SVN diff markers and provide fine-grained control over your version control workflow.

## SVN Blame

### What is SVN Blame?

SVN blame shows you who last modified each line in a file, along with the revision number and date. This is useful for:

- Understanding the history of code changes
- Finding out who to ask about specific code
- Tracking when a particular change was made
- Code review and auditing

### Commands

#### `:GeneroSVNBlame`
Show blame information for the entire file in a floating window.

**Usage:**
```vim
:GeneroSVNBlame
```

**Output:**
```
=== SVN Blame ===

Line 1: r1234 | john.doe | 2024-01-15 10:30
Line 2: r1234 | john.doe | 2024-01-15 10:30
Line 3: r1256 | jane.smith | 2024-01-20 14:45
...
```

#### `:GeneroSVNBlameCurrentLine`
Show blame information for the current line in the status line.

**Usage:**
```vim
:GeneroSVNBlameCurrentLine
```

**Output:**
```
Line 42: r1256 | jane.smith | 2024-01-20 14:45
```

**Keybinding:** `<leader>sb` (normal mode)

#### `:GeneroSVNBlameRange`
Show blame information for a range of lines (works with visual selection).

**Usage:**
```vim
" Select lines in visual mode, then:
:'<,'>GeneroSVNBlameRange

" Or specify a range:
:10,20GeneroSVNBlameRange
```

**Keybinding:** `<leader>sb` (visual mode)

### Blame Information Format

Each blame entry shows:
- **Line number** - The line in the current file
- **Revision** - The SVN revision that last modified this line (e.g., r1234)
- **Author** - The username who made the change
- **Date** - When the change was made (YYYY-MM-DD HH:MM format)

## Selective Revert

### What is Selective Revert?

Selective revert allows you to revert specific lines or sections of a file to their SVN base version without reverting the entire file. This is useful for:

- Undoing specific changes while keeping others
- Reverting experimental code sections
- Cleaning up debugging code
- Fixing mistakes in specific areas

### Commands

#### `:GeneroSVNRevertLine`
Revert the current line to its base version.

**Usage:**
```vim
:GeneroSVNRevertLine
```

**Keybinding:** `<leader>sr` (normal mode)

**Example:**
```
Before:  let x = 42  " Modified line
After:   let x = 10  " Reverted to base
```

#### `:GeneroSVNRevertRange`
Revert a range of lines to their base version (works with visual selection).

**Usage:**
```vim
" Select lines in visual mode, then:
:'<,'>GeneroSVNRevertRange

" Or specify a range:
:10,20GeneroSVNRevertRange
```

**Note:** This command reverts immediately without confirmation. Use `:GeneroSVNRevertRangeConfirm` for a safer option.

#### `:GeneroSVNRevertRangeConfirm`
Revert a range of lines with a preview and confirmation prompt.

**Usage:**
```vim
" Select lines in visual mode, then:
:'<,'>GeneroSVNRevertRangeConfirm

" Or specify a range:
:10,20GeneroSVNRevertRangeConfirm
```

**Keybinding:** `<leader>sr` (visual mode)

**Preview:**
```
=== Revert Preview ===
Lines 10-12

Line 10:
  Current: let x = 42
  Base:    let x = 10

Line 11:
  Current: let y = 100
  Base:    let y = 50

Revert these lines? (y/n):
```

#### `:GeneroSVNRevertAllChanges`
Revert all changes in the current buffer to the base version.

**Usage:**
```vim
:GeneroSVNRevertAllChanges
```

**Note:** This command asks for confirmation before reverting.

### How Revert Works

1. **Fetches base content** - Gets the original file content from SVN using `svn cat`
2. **Identifies changes** - Compares current buffer with base version
3. **Applies revert** - Replaces modified lines with their base versions
4. **Handles additions** - Deletes lines that were added (not in base)
5. **Updates markers** - Refreshes SVN diff markers after revert

### Revert Behavior

- **Modified lines** - Replaced with base version
- **Added lines** - Deleted (they don't exist in base)
- **Deleted lines** - Cannot be reverted individually (use full file revert)
- **Newly added files** - Cannot be reverted (no base version exists)

## Keybindings

All keybindings use the `<leader>s` prefix (s for SVN):

| Keybinding | Mode | Command | Description |
|------------|------|---------|-------------|
| `<leader>sb` | Normal | `:GeneroSVNBlameCurrentLine` | Show blame for current line |
| `<leader>sb` | Visual | `:GeneroSVNBlameRange` | Show blame for selection |
| `<leader>sr` | Normal | `:GeneroSVNRevertLine` | Revert current line |
| `<leader>sr` | Visual | `:GeneroSVNRevertRangeConfirm` | Revert selection (with confirmation) |
| `<leader>ss` | Normal | `:GeneroSVNStatus` | Show SVN status |
| `<leader>sR` | Normal | `:GeneroSVNRefresh` | Refresh SVN markers |

**Note:** By default, `<leader>` is the backslash key (`\`), but you can change it in your `.vimrc`:
```vim
let mapleader = ","  " Use comma as leader key
```

## Configuration

The blame and revert features respect the existing SVN configuration options:

```vim
" Enable/disable SVN integration
let g:genero_tools_config.svn_enabled = 1

" Cache TTL for SVN operations (in seconds)
let g:genero_tools_config.svn_cache_ttl = 300

" Auto-update SVN markers on file save
let g:genero_tools_config.svn_auto_update = 1
```

## Workflow Examples

### Example 1: Review and Revert Debugging Code

```vim
" 1. You added some debug print statements
" 2. Check who last modified the surrounding code
<leader>sb          " Show blame for current line

" 3. Select the debug lines in visual mode
V                   " Enter visual line mode
jjj                 " Select 3 lines

" 4. Revert the debug lines
<leader>sr          " Revert with confirmation
y                   " Confirm revert
```

### Example 2: Investigate a Bug

```vim
" 1. Find a suspicious line
" 2. Check when it was changed
<leader>sb          " Show blame: r1256 | jane.smith | 2024-01-20

" 3. Check the full file history
:GeneroSVNBlame     " See all changes in floating window

" 4. Revert the suspicious change to test
:GeneroSVNRevertLine

" 5. Test if bug is fixed
" 6. If not, undo the revert
u                   " Vim undo
```

### Example 3: Clean Up Experimental Changes

```vim
" 1. You tried several approaches in a function
" 2. Want to keep some changes, revert others

" 3. Check what changed
:GeneroSVNStatus    " See summary of changes

" 4. Select the lines to revert
V                   " Visual line mode
/end of experiment  " Search for marker
<leader>sr          " Revert with preview
y                   " Confirm

" 5. Verify the result
:GeneroSVNRefresh   " Update diff markers
```

## Integration with Existing Features

### SVN Diff Markers

After reverting lines, the SVN diff markers in the sign column are automatically updated to reflect the new state:

- **Green (+)** - Added lines
- **Yellow (~)** - Modified lines  
- **Red (-)** - Deleted lines

### Undo/Redo

All revert operations are integrated with Vim's undo system:

```vim
:GeneroSVNRevertLine    " Revert a line
u                       " Undo the revert
<C-r>                   " Redo the revert
```

### Visual Mode

Both blame and revert work seamlessly with visual selections:

```vim
V           " Visual line mode
5j          " Select 5 lines
<leader>sb  " Show blame for selection
<leader>sr  " Revert selection
```

## Error Handling

The features handle various error conditions gracefully:

- **File not in SVN** - Clear error message
- **SVN not available** - Suggests installing SVN
- **Binary files** - Cannot blame/revert binary files
- **Newly added files** - No base version to revert to
- **Authentication errors** - Prompts for credentials
- **Permission errors** - Clear error message

## Performance

### Caching

Blame results are not cached by default (they're typically one-time queries). However, the base file content for revert operations uses the existing SVN cache system:

- **Cache TTL:** 300 seconds (5 minutes) by default
- **Cache invalidation:** Automatic on file save
- **Manual refresh:** `:GeneroSVNCacheClear`

### Large Files

For large files:
- Blame operations may take a few seconds
- Consider using `:GeneroSVNBlameCurrentLine` instead of full file blame
- Revert operations are fast (local buffer operations)

## Troubleshooting

### Blame shows "unknown" author

**Cause:** SVN repository doesn't have author information for that revision.

**Solution:** This is normal for some SVN configurations. The revision number is still accurate.

### Revert doesn't work for newly added file

**Cause:** File has no base version in SVN.

**Solution:** Use `:GeneroSVNStatus` to check if file is newly added. Use regular undo (`u`) or delete the file.

### Blame is slow

**Cause:** Large file or slow SVN server.

**Solution:** 
- Use `:GeneroSVNBlameCurrentLine` for single lines
- Use `:GeneroSVNBlameRange` for specific sections
- Check network connection to SVN server

### Revert confirmation window doesn't appear

**Cause:** Floating windows not available (Vim 8.1 or older).

**Solution:** Confirmation will appear in the command line instead. Upgrade to Neovim or Vim 8.2+ for floating windows.

## See Also

- [SVN Integration Documentation](SVN_INTEGRATION.md) - Main SVN features
- [Configuration Guide](CONFIGURATION.md) - All configuration options
- [Keybindings Reference](KEYBINDINGS.md) - All available keybindings

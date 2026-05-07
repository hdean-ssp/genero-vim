# SVN Features Architecture

## Overview

This document describes the architecture of the SVN integration features in Genero-Tools.

## Module Structure

```
autoload/genero_tools/svn/
├── blame.vim           # SVN blame functionality
├── cache.vim           # Caching system
├── commands.vim        # User-facing commands
├── detection.vim       # SVN detection and availability
├── diff.vim            # Diff retrieval
├── error.vim           # Error handling
├── parser.vim          # Diff parsing
├── revert.vim          # Selective revert functionality
└── signs.vim           # Sign column markers
```

## Feature Flow Diagrams

### SVN Blame Flow

```
User Action
    │
    ├─ <leader>sb (normal mode)
    │   └─> GeneroSVNBlameCurrentLine
    │       └─> genero_tools#svn#blame#get_line_blame()
    │           ├─> genero_tools#svn#blame#get_blame()
    │           │   ├─> Check SVN availability
    │           │   ├─> Execute: svn blame --xml <file>
    │           │   └─> genero_tools#svn#blame#parse_blame()
    │           │       └─> Parse XML output
    │           └─> Format and display result
    │
    ├─ <leader>sb (visual mode)
    │   └─> GeneroSVNBlameRange
    │       └─> genero_tools#svn#blame#get_range_blame()
    │           └─> Filter blame data by line range
    │               └─> genero_tools#svn#blame#show_blame_window()
    │                   └─> Display in floating window
    │
    └─ :GeneroSVNBlame
        └─> genero_tools#svn#blame#get_blame()
            └─> Show full file blame
```

### SVN Revert Flow

```
User Action
    │
    ├─ <leader>sr (normal mode)
    │   └─> GeneroSVNRevertLine
    │       └─> genero_tools#svn#revert#revert_current_line()
    │           ├─> genero_tools#svn#revert#get_base_content()
    │           │   ├─> Check SVN availability
    │           │   ├─> Execute: svn cat <file>
    │           │   └─> Return base file content
    │           ├─> genero_tools#svn#revert#revert_lines()
    │           │   ├─> Sort lines (descending)
    │           │   ├─> Replace with base content
    │           │   └─> Update buffer
    │           └─> Refresh SVN markers
    │
    ├─ <leader>sr (visual mode)
    │   └─> GeneroSVNRevertRangeConfirm
    │       └─> genero_tools#svn#revert#revert_with_confirmation()
    │           ├─> genero_tools#svn#revert#preview_revert()
    │           │   ├─> Compare current vs base
    │           │   └─> Generate preview
    │           ├─> Display preview (floating window)
    │           ├─> Ask for confirmation
    │           └─> If confirmed:
    │               └─> genero_tools#svn#revert#revert_range()
    │                   └─> Update buffer
    │
    └─ :GeneroSVNRevertAllChanges
        └─> genero_tools#svn#revert#revert_all_changes()
            ├─> Get diff to find changed lines
            ├─> Collect all changed line numbers
            └─> Revert all lines
```

## Data Flow

### Blame Data Structure

```vim
" Blame result from get_blame()
{
  'success': 1,
  'error': '',
  'blame': [
    {
      'line_num': 1,
      'revision': '1234',
      'author': 'john.doe',
      'date': '2024-01-15 10:30'
    },
    {
      'line_num': 2,
      'revision': '1256',
      'author': 'jane.smith',
      'date': '2024-01-20 14:45'
    }
  ]
}
```

### Revert Data Structure

```vim
" Base content result from get_base_content()
{
  'success': 1,
  'error': '',
  'content': [
    'line 1 content',
    'line 2 content',
    'line 3 content'
  ]
}

" Revert result from revert_lines()
{
  'success': 1,
  'error': '',
  'reverted_count': 5
}
```

## Integration Points

### With Existing SVN Features

```
SVN Module (svn.vim)
    │
    ├─> Detection (detection.vim)
    │   └─> Used by blame and revert
    │
    ├─> Cache (cache.vim)
    │   └─> Caches blame and base content
    │
    ├─> Error Handling (error.vim)
    │   └─> Consistent error messages
    │
    ├─> Diff (diff.vim)
    │   └─> Used by revert to find changes
    │
    └─> Signs (signs.vim)
        └─> Refreshed after revert
```

### With Vim Features

```
Vim Integration
    │
    ├─> Visual Mode
    │   └─> Range selection for blame/revert
    │
    ├─> Undo System
    │   └─> All reverts are undoable
    │
    ├─> Command System
    │   └─> Range commands (:10,20GeneroSVNRevertRange)
    │
    ├─> Floating Windows (Neovim)
    │   └─> Blame and preview display
    │
    └─> Buffer Operations
        └─> setline(), getline() for revert
```

## Command Registration

```
plugin/genero_tools.vim
    │
    └─> genero_tools#svn#init()
        └─> genero_tools#svn#commands#register()
            ├─> Register blame commands
            │   ├─> :GeneroSVNBlame
            │   ├─> :GeneroSVNBlameCurrentLine
            │   └─> :GeneroSVNBlameRange
            │
            └─> Register revert commands
                ├─> :GeneroSVNRevertLine
                ├─> :GeneroSVNRevertRange
                ├─> :GeneroSVNRevertRangeConfirm
                └─> :GeneroSVNRevertAllChanges
```

## Keybinding Registration

```
plugin/genero_tools.vim
    │
    └─> genero_tools#keybindings#register()
        └─> Register SVN keybindings
            ├─> <leader>sb (normal) -> BlameCurrentLine
            ├─> <leader>sb (visual) -> BlameRange
            ├─> <leader>sr (normal) -> RevertLine
            └─> <leader>sr (visual) -> RevertRangeConfirm
```

## Error Handling Flow

```
Operation Start
    │
    ├─> Check file open
    │   └─> genero_tools#svn#error#check_file_open()
    │
    ├─> Check SVN enabled
    │   └─> genero_tools#svn#error#check_enabled()
    │
    ├─> Check SVN available
    │   └─> genero_tools#svn#error#check_availability()
    │
    ├─> Check in working copy
    │   └─> genero_tools#svn#error#check_in_working_copy()
    │
    └─> Execute operation
        ├─> Success -> Return result
        └─> Failure -> Format error message
            ├─> Binary file error
            ├─> Authentication error
            ├─> Permission error
            └─> Generic SVN error
```

## Caching Strategy

```
Cache System
    │
    ├─> Blame Results
    │   ├─> Key: 'svn_blame:<file_path>'
    │   ├─> TTL: svn_cache_ttl (default 300s)
    │   └─> Invalidation: On file save
    │
    └─> Base Content
        ├─> Key: 'svn_base:<file_path>'
        ├─> TTL: svn_cache_ttl (default 300s)
        └─> Invalidation: On file save

Cache Operations
    │
    ├─> Get
    │   ├─> Check if exists
    │   ├─> Check if expired
    │   └─> Return cached or miss
    │
    ├─> Set
    │   ├─> Store with timestamp
    │   └─> Evict old entries if needed
    │
    └─> Invalidate
        ├─> Remove specific entry
        └─> Clear all entries
```

## Performance Considerations

### Blame Operations
- **First call**: Executes `svn blame --xml` (network operation)
- **Subsequent calls**: Uses cache (fast)
- **Large files**: May take several seconds
- **Optimization**: Use line/range blame instead of full file

### Revert Operations
- **Base content fetch**: Executes `svn cat` (network operation)
- **Line replacement**: Local buffer operation (fast)
- **Multiple lines**: Processed in descending order (efficient)
- **Optimization**: Batch operations when possible

## Security Considerations

### Input Validation
- File paths are validated
- Line numbers are range-checked
- SVN commands use `shellescape()`
- No user input directly in shell commands

### Error Handling
- Authentication errors reported
- Permission errors reported
- Binary files rejected
- Invalid operations prevented

## Testing Strategy

```
Test Suite (test_svn_blame_revert.vim)
    │
    ├─> Unit Tests
    │   ├─> XML parsing
    │   ├─> Date formatting
    │   ├─> Line sorting
    │   └─> Error handling
    │
    ├─> Integration Tests
    │   ├─> Command registration
    │   ├─> Keybinding registration
    │   └─> Module interaction
    │
    └─> Mock Tests
        ├─> SVN command simulation
        ├─> Buffer operations
        └─> Cache operations
```

## Extension Points

### Future Enhancements

1. **Blame Annotations**
   ```
   Sign Column Integration
       │
       └─> Show author/revision in sign column
           └─> Color-code by author
   ```

2. **Revert to Specific Revision**
   ```
   Enhanced Revert
       │
       └─> svn cat -r <revision> <file>
           └─> Revert to any revision, not just base
   ```

3. **Telescope Integration**
   ```
   Telescope Picker
       │
       └─> Browse blame history
           └─> Interactive revert selection
   ```

4. **Conflict Resolution**
   ```
   Merge Support
       │
       └─> Detect conflicts
           └─> Interactive resolution
   ```

## Dependencies

### External
- **SVN 1.7+** - For XML blame output
- **Shell** - For executing SVN commands

### Internal
- **genero_tools#svn#detection** - SVN availability
- **genero_tools#svn#cache** - Caching system
- **genero_tools#svn#error** - Error handling
- **genero_tools#display** - Output display
- **genero_tools#compat** - Compatibility layer

## Configuration

```vim
" SVN configuration (existing)
let g:genero_tools_config = {
  \ 'svn_enabled': 1,           " Enable SVN features
  \ 'svn_cache_ttl': 300,       " Cache TTL in seconds
  \ 'svn_auto_update': 1,       " Auto-update on save
  \ 'svn_show_added': 1,        " Show added lines
  \ 'svn_show_modified': 1,     " Show modified lines
  \ 'svn_show_deleted': 1       " Show deleted lines
  \ }

" No new configuration needed for blame/revert
" They use the existing SVN settings
```

## Summary

The SVN blame and revert features are:
- **Modular** - Separate modules for blame and revert
- **Integrated** - Work with existing SVN features
- **Cached** - Use existing cache system
- **Safe** - Comprehensive error handling
- **Tested** - Full test coverage
- **Documented** - Extensive documentation
- **Extensible** - Clear extension points

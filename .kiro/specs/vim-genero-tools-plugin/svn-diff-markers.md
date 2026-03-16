# SVN Diff Markers Feature Specification

## Overview

This specification describes the SVN diff markers feature for the vim-genero-tools plugin. The feature automatically detects when a file is under SVN version control and displays visual indicators in the sign column to show which lines have been added, modified, or deleted compared to the SVN repository.

## Feature Description

### Purpose

Provide developers with immediate visual feedback about code changes in their working copy compared to the SVN repository. This helps developers:
- Quickly identify what they've changed in the current file
- Review changes before committing
- Understand the scope of modifications
- Spot accidental changes

### Scope

This feature applies to:
- Files in SVN-controlled directories
- Any file type (Genero, Python, etc.)
- Both Vim and Neovim
- Works alongside existing compiler integration

## Requirements

### 19.1 SVN Detection
- Detect if current file is in an SVN working copy
- Check for `.svn` directory in file's parent directories
- Cache SVN status to avoid repeated filesystem checks
- Support nested SVN repositories

### 19.2 Diff Retrieval
- Execute `svn diff` command to get file changes
- Parse unified diff format output
- Extract line numbers for added/modified/deleted lines
- Handle binary files gracefully (skip diff markers)
- Support SVN authentication (prompt if needed)

### 19.3 Sign Column Display
- Display signs for changed lines in sign column
- Use distinct signs for different change types:
  - `+` (green) for added lines
  - `~` (yellow) for modified lines
  - `-` (red) for deleted lines (show on line before deletion)
- Integrate with existing compiler signs (no conflicts)
- Update signs when file is saved

### 19.4 Configuration
- Add `svn_enabled` configuration option (default: true)
- Add `svn_show_added` option (default: true)
- Add `svn_show_modified` option (default: true)
- Add `svn_show_deleted` option (default: true)
- Add `svn_cache_ttl` option (default: 300 seconds)
- Add `svn_auto_update` option (default: true - update on save)

### 19.5 Performance
- Cache SVN diff results to avoid repeated executions
- Invalidate cache when file is modified
- Lazy-load SVN detection (only check when needed)
- Handle large diffs efficiently (1000+ lines)
- Timeout SVN commands after 5 seconds

### 19.6 User Interaction
- Provide command to manually refresh diff markers: `:GeneroSVNRefresh`
- Provide command to toggle diff markers: `:GeneroSVNToggle`
- Provide command to show SVN status: `:GeneroSVNStatus`
- Display status in status line (optional)

### 19.7 Error Handling
- Handle SVN not installed gracefully (disable feature)
- Handle authentication failures (prompt user)
- Handle permission errors (display message)
- Handle network errors (display message)
- Handle corrupted SVN metadata (display warning)

### 19.8 Integration
- Work alongside compiler signs (different sign groups)
- Work with other sign-based plugins
- Respect user's sign column width settings
- Support custom highlight colors

## Implementation Tasks

### Phase 1: Core SVN Detection and Diff Retrieval

- [ ] 19.1 Create SVN detection module
  - Implement `genero_tools#svn#is_available()` to check if SVN is installed
  - Implement `genero_tools#svn#is_in_working_copy()` to detect SVN directory
  - Implement `genero_tools#svn#get_working_copy_root()` to find repository root
  - Cache detection results with TTL
  - _Requirements: 19.1_

- [ ] 19.2 Create SVN diff retrieval module
  - Implement `genero_tools#svn#get_diff()` to execute `svn diff` command
  - Parse unified diff format output
  - Extract line numbers for changes
  - Handle binary files (skip diff markers)
  - Implement timeout handling (5 seconds)
  - _Requirements: 19.2_

- [ ] 19.3 Create diff parser
  - Implement `genero_tools#svn#parse_diff()` to parse unified diff
  - Extract added lines (lines starting with `+`)
  - Extract modified lines (context lines with changes)
  - Extract deleted lines (lines starting with `-`)
  - Return structured result with line numbers and change types
  - _Requirements: 19.2_

### Phase 2: Sign Column Display

- [ ] 19.4 Create SVN sign module
  - Implement `genero_tools#svn#signs#init()` to define signs
  - Define signs for added (`+` green), modified (`~` yellow), deleted (`-` red)
  - Use different sign group to avoid conflicts with compiler signs
  - _Requirements: 19.3_

- [ ] 19.5 Implement sign placement
  - Implement `genero_tools#svn#signs#place()` to place signs
  - Place signs for added lines
  - Place signs for modified lines
  - Place signs for deleted lines (on line before deletion)
  - Handle overlapping changes
  - _Requirements: 19.3_

- [ ] 19.6 Implement sign clearing
  - Implement `genero_tools#svn#signs#clear()` to remove all SVN signs
  - Clear only SVN sign group (preserve compiler signs)
  - _Requirements: 19.3_

### Phase 3: Configuration and Commands

- [ ] 19.7 Create SVN configuration
  - Add SVN options to `genero_tools#config#init()`
  - Add `svn_enabled`, `svn_show_added`, `svn_show_modified`, `svn_show_deleted`
  - Add `svn_cache_ttl`, `svn_auto_update`
  - _Requirements: 19.4_

- [ ] 19.8 Create SVN commands
  - Implement `GeneroSVNRefresh` command to manually refresh diff markers
  - Implement `GeneroSVNToggle` command to toggle diff markers on/off
  - Implement `GeneroSVNStatus` command to show SVN status
  - _Requirements: 19.6_

- [ ] 19.9 Implement autocommand for file save
  - Add autocommand to update diff markers on `BufWritePost`
  - Only update if `svn_auto_update` is enabled
  - Invalidate cache on file modification
  - _Requirements: 19.5, 19.6_

### Phase 4: Caching and Performance

- [ ] 19.10 Create SVN cache module
  - Implement `genero_tools#svn#cache#get()` to retrieve cached diff
  - Implement `genero_tools#svn#cache#set()` to store diff in cache
  - Implement `genero_tools#svn#cache#invalidate()` to clear cache for file
  - Use file path and modification time as cache key
  - Implement TTL-based expiration
  - _Requirements: 19.5_

- [ ] 19.11 Implement cache invalidation
  - Invalidate cache when file is modified
  - Invalidate cache when user runs `:GeneroSVNRefresh`
  - Invalidate cache on file save (if auto_update enabled)
  - _Requirements: 19.5_

### Phase 5: Error Handling and Integration

- [ ] 19.12 Implement error handling
  - Handle SVN not installed (disable feature gracefully)
  - Handle authentication failures (prompt user)
  - Handle permission errors (display message)
  - Handle network errors (display message)
  - Handle corrupted SVN metadata (display warning)
  - _Requirements: 19.7_

- [ ] 19.13 Implement sign group isolation
  - Use separate sign group for SVN signs
  - Ensure no conflicts with compiler signs
  - Support multiple sign-based plugins
  - _Requirements: 19.8_

- [ ] 19.14 Create integration tests
  - Test SVN detection with real SVN repository
  - Test diff retrieval and parsing
  - Test sign placement and clearing
  - Test cache behavior
  - Test error scenarios
  - Test with compiler signs enabled
  - _Requirements: 19.1, 19.2, 19.3, 19.5, 19.8_

### Phase 6: Documentation and Examples

- [ ] 19.15 Create user documentation
  - Document SVN diff markers feature
  - Document configuration options
  - Document commands
  - Provide examples
  - Document troubleshooting
  - _Requirements: 19.4, 19.6_

- [ ] 19.16 Create development documentation
  - Document SVN module architecture
  - Document diff parsing algorithm
  - Document cache strategy
  - Document sign group isolation
  - _Requirements: 19.1, 19.2, 19.3, 19.5_

## Configuration Example

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

## Sign Display Example

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

## Commands Reference

```vim
:GeneroSVNRefresh      " Manually refresh diff markers
:GeneroSVNToggle       " Toggle diff markers on/off
:GeneroSVNStatus       " Show SVN status for current file
```

## Implementation Notes

- SVN detection should be lazy (only check when needed)
- Cache results to avoid repeated filesystem checks
- Use separate sign group to avoid conflicts with compiler signs
- Timeout SVN commands to prevent hanging
- Handle authentication gracefully (prompt user if needed)
- Support nested SVN repositories
- Work alongside existing compiler integration
- Support both Vim and Neovim

## Future Enhancements

- Git diff markers (similar feature for Git repositories)
- Mercurial diff markers (similar feature for Hg repositories)
- Blame information (show who changed each line)
- Commit message integration (show commit message on hover)
- Diff navigation (jump to next/previous change)
- Diff staging (stage/unstage changes from editor)
- Conflict resolution helpers (for merge conflicts)

## Related Features

- Compiler integration (error/warning signs)
- Sign column display
- Cache system
- Configuration management
- Error handling

## Testing Strategy

### Unit Tests
- SVN detection with various directory structures
- Diff parsing with various diff formats
- Cache behavior with TTL expiration
- Sign placement with overlapping changes
- Error handling for various failure scenarios

### Integration Tests
- End-to-end workflow with real SVN repository
- Sign display with compiler signs enabled
- Cache invalidation on file save
- Command execution and display
- Error scenarios (SVN not installed, auth failures, etc.)

### Performance Tests
- Diff retrieval time with large files (1000+ lines)
- Cache performance with many files
- Sign placement performance with many changes
- Timeout handling under load

## Acceptance Criteria

- [ ] SVN detection works correctly
- [ ] Diff retrieval and parsing is accurate
- [ ] Signs display correctly in sign column
- [ ] Cache works and improves performance
- [ ] Commands work as expected
- [ ] Error handling is graceful
- [ ] No conflicts with compiler signs
- [ ] Works with both Vim and Neovim
- [ ] All tests pass
- [ ] Documentation is complete

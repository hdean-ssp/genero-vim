# Task 27: Debug File Streaming Feature - Summary

## What Was Added

A new HIGH priority task has been added to the spec as **Task 27: Debug File Streaming Feature**.

This feature enables developers to monitor live debug output from files in a dedicated split window while coding, addressing the need for real-time debugging when the compiler lacks proper debug support.

## Feature Overview

### Problem Solved
- Genero compiler has no proper debug support
- Developers output debug info to files in a debug directory
- Currently requires manual file opening and refreshing
- Interrupts coding workflow

### Solution
- Open a 1/3 width split window
- Select which debug file to monitor
- Automatically stream file changes in real-time
- Auto-scroll to show latest output
- Convenient keybindings and commands

## User Experience

### Basic Workflow
1. Press `<leader>gd` to open debug stream
2. Debug window opens on right side (1/3 width)
3. File picker shows available debug files
4. Select a file to stream
5. Window auto-updates as file changes

### Commands
- `:GeneroDebugStreamOpen` - Open debug stream
- `:GeneroDebugStreamClose` - Close debug stream
- `:GeneroDebugStreamToggle` - Toggle on/off
- `:GeneroDebugStreamSelect` - Select different file
- `:GeneroDebugStreamClear` - Clear output
- `:GeneroDebugStreamStatus` - Show status

### Keybindings
- `<leader>gd` - Toggle debug stream
- `<leader>gds` - Select debug file
- `<leader>gdc` - Clear debug output

## Configuration Options

```vim
let g:genero_tools_config = {
  \ 'debug_stream_enabled': v:true,           " Enable feature
  \ 'debug_stream_directory': './debug',      " Debug file directory
  \ 'debug_stream_width': 33,                 " Window width (%)
  \ 'debug_stream_auto_scroll': v:true,       " Auto-scroll to end
  \ 'debug_stream_max_lines': 1000,           " Max lines to display
  \ 'debug_stream_refresh_interval': 500,     " Refresh interval (ms)
  \ 'debug_stream_file_pattern': '*'          " File pattern filter
  \ }
```

## Architecture

### Module Structure
```
autoload/genero_tools/debug_stream.vim          # Main module
autoload/genero_tools/debug_stream/
├── watcher.vim                                 # File change detection
├── ui.vim                                      # Window management
└── selector.vim                                # File selection
```

### Key Components
1. **File Watcher** - Detects file changes using modification time
2. **UI Manager** - Creates and manages split window
3. **File Selector** - Presents file picker UI
4. **Main Module** - Coordinates components and manages state

## Implementation Details

### Window Management
- Vertical split window (1/3 width by default)
- Read-only display buffer
- Line numbers enabled
- Auto-scroll to end on update

### File Change Detection
- Monitor file modification time
- Check periodically (configurable interval)
- Append new lines to display
- Maintain max line limit

### Auto-Refresh
- Timer-based refresh (default: 500ms)
- Configurable refresh interval
- Proper timer cleanup on close

### Error Handling
- Missing debug directory
- File permission errors
- File encoding issues
- File deletion
- Window close events

## Task Details

| Aspect | Details |
|--------|---------|
| **Task Number** | 27 |
| **Priority** | HIGH |
| **Complexity** | MEDIUM |
| **Estimated Effort** | 4-6 hours |
| **Status** | Specification Complete |
| **Dependencies** | Tasks 1-5, 13 |
| **Files to Create** | 4 new files |
| **Configuration Options** | 7 new options |
| **Commands** | 6 new commands |
| **Keybindings** | 3 new keybindings |

## Integration Points

### Existing Features Used
- Configuration System (Task 2) - For config options
- Display Modes (Task 5) - For window patterns
- Keybindings (Task 13) - For keybinding infrastructure

### No Impact On
- Core plugin functionality
- Compiler integration
- Code navigation
- Caching system
- Existing commands

## Success Criteria

- ✓ Debug window opens with correct width
- ✓ File selection works
- ✓ Content streams in real-time
- ✓ Auto-scroll works
- ✓ Max line limit enforced
- ✓ Window closes cleanly
- ✓ Timer properly cleaned up
- ✓ Error scenarios handled
- ✓ Performance acceptable
- ✓ No impact on existing features

## Future Enhancements

1. Multiple debug windows
2. Search/filter within output
3. Syntax highlighting for patterns
4. Export debug output
5. Bookmarks for interesting lines
6. Diff view between runs
7. Remote debug file streaming
8. Auto-open on compilation

## Documentation

Comprehensive specification available at:
- `.kiro/specs/vim-genero-tools-plugin/DEBUG_STREAM_FEATURE.md`

## Next Steps

1. Review the feature specification
2. Implement Task 27 when ready
3. Continue with remaining enhancement tasks (22, 23, 20, 25, 26)
4. Complete core validation tasks (16-18)

## Task Ordering

Current task sequence (Option 1 - Enhancement Focus):
1. ✓ Task 21 (E1.2) - Reduce startup noise - COMPLETE
2. ✓ Task 24 (E2.3) - Fix statusline bug - COMPLETE
3. → Task 22 (E2.1) - Add error highlighting - NEXT
4. Task 23 (E2.2) - Fix sign column
5. Task 20 (E1.1) - Modernize config
6. Task 25 (E3.1) - which-key integration
7. Task 26 (E3.2) - which-key docs
8. **Task 27 (NEW)** - Debug file streaming - HIGH PRIORITY
9. Task 16 (Checkpoint) - Validate core
10. Task 17 (Integration Testing)
11. Task 18 (Final Checkpoint)

---

**Status:** Task 27 specification complete and added to spec
**Date:** March 17, 2026
**Ready for:** Implementation or continued with Task 22

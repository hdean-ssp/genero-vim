# Debug File Streaming Feature Specification

## Overview

The Debug File Streaming feature enables developers to monitor live debug output from files in a dedicated split window while coding. This addresses the need for real-time debugging when the compiler lacks proper debug support and developers output debug information to files in a designated directory.

## Problem Statement

- Genero compiler has no proper debug support
- Developers output debug information to files in a debug directory
- Currently, developers must manually open and refresh debug files to see output
- This interrupts the coding workflow and reduces productivity

## Solution

Implement a debug file streaming feature that:
1. Opens a 1/3 width split window
2. Allows users to select which debug file to monitor
3. Automatically streams file changes in real-time
4. Maintains auto-scroll to show latest output
5. Provides convenient keybindings and commands

## User Workflow

### Basic Usage
1. User presses keybinding (e.g., `<leader>gd`) to open debug stream
2. Debug window opens on the right side (1/3 width)
3. File picker shows available debug files in the debug directory
4. User selects a file to stream
5. Debug window displays file content and auto-updates as file changes
6. User can switch files, pause/resume, or close the window

### Advanced Usage
- User can configure debug directory path
- User can customize window width
- User can enable/disable auto-scroll
- User can set max lines to display
- User can adjust refresh interval for performance

## Architecture

### Module Structure
```
autoload/genero_tools/
├── debug_stream.vim           # Main module entry point
├── debug_stream/
│   ├── watcher.vim            # File change detection
│   ├── ui.vim                 # Window and display management
│   └── selector.vim           # File selection UI
```

### Key Components

#### 1. Configuration (`autoload/genero_tools/config.vim`)
New configuration options:
- `debug_stream_enabled`: Enable/disable feature (default: false)
- `debug_stream_directory`: Path to debug directory (default: './debug')
- `debug_stream_width`: Window width as percentage (default: 33)
- `debug_stream_auto_scroll`: Auto-scroll to end (default: true)
- `debug_stream_max_lines`: Maximum lines to display (default: 1000)
- `debug_stream_refresh_interval`: Refresh interval in ms (default: 500)
- `debug_stream_file_pattern`: File pattern to filter (default: '*')

#### 2. File Watcher (`autoload/genero_tools/debug_stream/watcher.vim`)
Responsibilities:
- Monitor debug directory for file changes
- Detect file modifications using file modification time
- Track currently selected file
- Detect new files and deletions
- Provide change notifications

Key Functions:
- `genero_tools#debug_stream#watcher#start(file_path)` - Start watching file
- `genero_tools#debug_stream#watcher#stop()` - Stop watching
- `genero_tools#debug_stream#watcher#has_changes()` - Check for changes
- `genero_tools#debug_stream#watcher#get_new_content()` - Get updated content

#### 3. UI Management (`autoload/genero_tools/debug_stream/ui.vim`)
Responsibilities:
- Create and manage split window
- Display file content
- Handle auto-scroll
- Manage window title and status
- Handle window close events

Key Functions:
- `genero_tools#debug_stream#ui#open(file_path)` - Open debug window
- `genero_tools#debug_stream#ui#close()` - Close debug window
- `genero_tools#debug_stream#ui#update(content)` - Update display
- `genero_tools#debug_stream#ui#is_open()` - Check if window is open
- `genero_tools#debug_stream#ui#get_window_id()` - Get window ID

#### 4. File Selector (`autoload/genero_tools/debug_stream/selector.vim`)
Responsibilities:
- List files in debug directory
- Present file selection UI
- Filter files by pattern
- Remember last selected file

Key Functions:
- `genero_tools#debug_stream#selector#choose_file()` - Show file picker
- `genero_tools#debug_stream#selector#list_files()` - List available files
- `genero_tools#debug_stream#selector#get_last_file()` - Get previously selected file

#### 5. Main Module (`autoload/genero_tools/debug_stream.vim`)
Responsibilities:
- Coordinate all components
- Manage timer for auto-refresh
- Handle commands and keybindings
- Manage state (open/closed, current file, etc.)

Key Functions:
- `genero_tools#debug_stream#open()` - Open debug stream
- `genero_tools#debug_stream#close()` - Close debug stream
- `genero_tools#debug_stream#toggle()` - Toggle on/off
- `genero_tools#debug_stream#select_file()` - Select different file
- `genero_tools#debug_stream#clear()` - Clear display
- `genero_tools#debug_stream#status()` - Show status
- `genero_tools#debug_stream#update()` - Internal update function

## Implementation Details

### Window Management
- Create split window with `vertical split` command
- Set window width to configured percentage (default: 33%)
- Set buffer options:
  - `buftype=nofile` - Not a real file
  - `bufhidden=hide` - Hide when not displayed
  - `noswapfile` - No swap file
  - `nomodifiable` - Read-only display
- Set window options:
  - `number=true` - Show line numbers
  - `wrap=true` - Wrap long lines
  - `cursorline=false` - Don't highlight cursor line

### File Change Detection
- Store file modification time on start
- Check modification time periodically (configurable interval)
- When changed, read new content
- Append new lines to display buffer
- Maintain max line limit by removing oldest lines

### Auto-Scroll Implementation
- After updating content, move cursor to end of buffer
- Use `normal! G` to go to last line
- Scroll window to show cursor

### Content Management
- Store content in a special buffer (not a real file)
- Use buffer operations to append/update content
- Maintain line count limit to prevent memory issues
- Clear old lines when max limit reached

### Timer Management
- Create timer on window open
- Timer calls update function periodically
- Stop timer on window close
- Handle timer cleanup on plugin unload

### Error Handling
- Handle missing debug directory (create or show error)
- Handle file permission errors (show message)
- Handle file encoding issues (use default encoding)
- Handle file deletion (show message, offer to select new file)
- Handle window close (stop timer, clean up)

## Commands

### User-Facing Commands
- `:GeneroDebugStreamOpen` - Open debug stream window
- `:GeneroDebugStreamClose` - Close debug stream window
- `:GeneroDebugStreamToggle` - Toggle debug stream on/off
- `:GeneroDebugStreamSelect` - Select different debug file
- `:GeneroDebugStreamClear` - Clear debug output display
- `:GeneroDebugStreamStatus` - Show debug stream status

### Default Keybindings
- `<leader>gd` - Toggle debug stream (configurable)
- `<leader>gds` - Select debug file (configurable)
- `<leader>gdc` - Clear debug output (configurable)

## Configuration Examples

### Basic Setup
```vim
let g:genero_tools_config = {
  \ 'debug_stream_enabled': v:true,
  \ 'debug_stream_directory': './debug'
  \ }
```

### Advanced Setup
```vim
let g:genero_tools_config = {
  \ 'debug_stream_enabled': v:true,
  \ 'debug_stream_directory': expand('~/.genero/debug'),
  \ 'debug_stream_width': 25,
  \ 'debug_stream_auto_scroll': v:true,
  \ 'debug_stream_max_lines': 2000,
  \ 'debug_stream_refresh_interval': 250,
  \ 'debug_stream_file_pattern': '*.log'
  \ }
```

## Testing Strategy

### Unit Tests
- Test file watcher change detection
- Test file selector with various directory structures
- Test UI window creation and management
- Test content update logic
- Test error handling scenarios

### Integration Tests
- Test full workflow: open → select file → stream updates
- Test switching between files
- Test window close and cleanup
- Test with various file sizes
- Test with rapid file updates
- Test with missing/deleted files

### Performance Tests
- Test with large files (10MB+)
- Test with rapid updates (100+ lines/sec)
- Test memory usage with max line limit
- Test CPU usage with various refresh intervals

## Backward Compatibility

- Feature is disabled by default (`debug_stream_enabled: false`)
- No impact on existing functionality
- Can be enabled per-user configuration
- No breaking changes to existing API

## Future Enhancements

1. **Multiple Debug Windows** - Monitor multiple files simultaneously
2. **Search/Filter** - Search within debug output
3. **Syntax Highlighting** - Highlight specific patterns in output
4. **Export** - Export debug output to file
5. **Bookmarks** - Mark interesting lines in debug output
6. **Diff View** - Compare debug output between runs
7. **Remote Debugging** - Stream debug files from remote servers
8. **Integration with Compiler** - Auto-open debug stream on compilation

## Related Features

- Compiler Integration (Task 15) - Provides compilation feedback
- Display Modes (Task 5) - Provides window management patterns
- Configuration System (Task 2) - Provides configuration framework
- Keybindings (Task 13) - Provides keybinding infrastructure

## Success Criteria

- ✓ Debug window opens with correct width (1/3 by default)
- ✓ File selection works with file picker
- ✓ Content streams and updates in real-time
- ✓ Auto-scroll works correctly
- ✓ Max line limit is enforced
- ✓ Window closes cleanly without errors
- ✓ Timer is properly cleaned up
- ✓ Error scenarios handled gracefully
- ✓ Performance acceptable with large files
- ✓ No impact on existing functionality

---

**Priority:** HIGH
**Complexity:** MEDIUM
**Estimated Effort:** 4-6 hours
**Dependencies:** Tasks 1-5, 13 (core infrastructure)
**Status:** Specification Complete - Ready for Implementation

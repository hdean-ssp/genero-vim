# Debug Streaming

Debug streaming allows you to monitor debug output files in real-time within Neovim. This is useful for tracking application logs, debug traces, or any file that gets updated during development.

**Note**: Debug streaming is only available in Neovim.

## Overview

Debug streaming opens a split window that automatically updates as new content is written to a debug file. The window displays the latest output with configurable line limits and auto-scrolling.

## Commands

```vim
:GeneroDebugStreamToggle                " Toggle debug stream window on/off (shows file selection menu)
:GeneroDebugStreamToggle {file}         " Toggle debug stream for a specific file
:GeneroDebugStreamSelect                " Select and open a debug file from the debug directory
:GeneroDebugStreamOpen {file}           " Open debug stream for a specific file
:GeneroDebugStreamClose                 " Close the debug stream window
:GeneroDebugStreamClear                 " Clear all debug output from the window
```

## Configuration

Add these settings to your Neovim config to customize debug streaming behavior:

```lua
-- init.lua
vim.g.genero_tools_config = {
  debug_stream_enabled = true,           -- Enable debug streaming (default: false)
  debug_stream_width = 33,               -- Width of debug window in columns (default: 33)
  debug_stream_max_lines = 1000,         -- Maximum lines to keep in buffer (default: 1000)
  debug_stream_auto_scroll = true,       -- Auto-scroll to latest output (default: true)
  debug_stream_directory = './debug',    -- Default directory for debug files (default: './debug')
}
```

Or in Vim script:

```vim
" init.vim or .vimrc
let g:genero_tools_config = {
  \ 'debug_stream_enabled': 1,
  \ 'debug_stream_width': 33,
  \ 'debug_stream_max_lines': 1000,
  \ 'debug_stream_auto_scroll': 1,
  \ 'debug_stream_directory': './debug',
  \ }
```

## Usage

### Basic Usage

Open a debug stream for a file:

```vim
:GeneroDebugStreamOpen /path/to/debug.log
```

The debug window will open in a vertical split on the right side and automatically update as new content is appended to the file.

### Select and Open Debug File

Show an interactive floating window to select a debug file from the configured debug directory:

```vim
:GeneroDebugStreamSelect
```

This displays a floating window with files from the debug directory, sorted by modification time (most recent first). Use arrow keys or `j`/`k` to navigate, then press `Enter` to open the selected file. Press `Esc` or `q` to close the selector without opening a file.

### Toggle Debug Stream

Use the keybinding to quickly toggle the debug stream:

```vim
<space>gd    " Toggle debug stream (if keybindings enabled)
```

Or use the command with optional file path:

```vim
:GeneroDebugStreamToggle                " Shows file selection menu
:GeneroDebugStreamToggle /path/to/file  " Opens specific file
```

### Clear Output

Clear all accumulated debug output:

```vim
:GeneroDebugStreamClear
```

This resets the buffer but keeps the stream active and monitoring the file.

### Close Debug Stream

Close the debug window:

```vim
:GeneroDebugStreamClose
```

## Features

- **Real-time Updates**: File changes are detected every 500ms and displayed immediately
- **Auto-scroll**: Automatically scrolls to the latest output (configurable)
- **Line Limiting**: Keeps only the most recent N lines to prevent memory issues
- **Read-only Buffer**: Debug output is read-only to prevent accidental edits
- **Line Numbers**: Line numbers are displayed for reference
- **Word Wrap**: Long lines are wrapped for better readability

## Behavior

- The debug stream monitors the file continuously while active
- New lines are appended to the buffer as they appear in the file
- When the buffer exceeds `debug_stream_max_lines`, oldest lines are removed
- If the debug file is truncated or rewritten (file size decreases), the stream automatically resets and displays all content from the beginning
- The window remains open until explicitly closed or toggled off
- Closing Neovim automatically stops the debug stream
- Buffer names are automatically made unique if a conflict occurs (timestamp appended)

## Troubleshooting

**Debug stream not updating**: Ensure the file path is correct and the file is being written to. Check that `debug_stream_enabled` is set to `true` in your configuration.

**Window too narrow/wide**: Adjust `debug_stream_width` in your configuration to change the split window size.

**Too many lines in buffer**: Reduce `debug_stream_max_lines` to limit memory usage for very active debug files.

**Auto-scroll not working**: Set `debug_stream_auto_scroll` to `true` in your configuration.

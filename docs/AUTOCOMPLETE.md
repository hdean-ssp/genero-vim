# Autocomplete

Autocomplete provides intelligent code completion for Genero functions and modules. The plugin supports both manual completion (Ctrl+Space) and automatic completion on pause.

**Note**: Autocomplete is available in both Vim and Neovim.

## Overview

Autocomplete searches your codebase for functions and modules matching what you're typing. Results include function signatures and module information for quick reference.

## Commands

```vim
:GeneroCompleteEnable              " Enable completion for current buffer
:GeneroCompleteDisable             " Disable completion for current buffer
```

## Configuration

Add these settings to your Vim/Neovim config to customize autocomplete behavior.

```vim
" init.vim or .vimrc
let g:genero_tools_config = {
  \ 'autocomplete_on_pause': 1,     " Auto-trigger on pause (default: 1)
  \ 'autocomplete_delay': 500,      " Delay in ms before triggering (default: 500)
  \ }
```

Or in Lua (Neovim):

```lua
-- init.lua
vim.g.genero_tools_config = {
  autocomplete_on_pause = true,      -- Auto-trigger on pause (default: true)
  autocomplete_delay = 500,          -- Delay in ms before triggering (default: 500)
}
```

## Usage

### Manual Completion

Trigger completion manually with Ctrl+Space in insert mode:

```vim
<C-Space>    " Trigger code completion
```

In the completion menu:
- Use arrow keys or `j`/`k` to navigate suggestions
- Press `Enter` to accept a suggestion
- Press `Esc` to close the menu

### Automatic Completion on Pause

When `autocomplete_on_pause` is enabled (default), completion automatically triggers after you pause typing for the configured delay (default: 500ms).

This works while typing identifiers (letters, numbers, underscores, dots):

```genero
FUNCTION myFunc()
  LET x = myVar.  " Completion triggers after 500ms pause
END FUNCTION
```

The completion menu appears automatically, showing matching functions and modules. You can:
- Accept a suggestion with `Enter`
- Dismiss with `Esc`
- Continue typing to filter results

### Disable Auto-Completion

To disable automatic completion while keeping manual completion available:

```vim
let g:genero_tools_config.autocomplete_on_pause = 0
```

Or adjust the delay to trigger less frequently:

```vim
let g:genero_tools_config.autocomplete_delay = 1000  " 1 second instead of 500ms
```

## Features

- **Function Matching**: Searches for functions by name or pattern
- **Module Matching**: Finds modules matching your input
- **Signature Display**: Shows function signatures in completion menu
- **Smart Triggering**: Only triggers when typing identifiers
- **Configurable Delay**: Adjust pause duration before auto-trigger
- **Manual Trigger**: Always available with Ctrl+Space

## Completion Menu

The completion menu displays:

- **word**: The function or module name
- **menu**: Type indicator (Function or Module)
- **info**: Function signature or module description
- **kind**: Icon indicator (f for function, m for module)

## Behavior

- Completion searches your entire codebase
- Results are cached for performance
- Auto-completion only triggers when typing identifier characters
- Cursor position must not change for auto-completion to trigger
- Manual completion (Ctrl+Space) works anywhere in insert mode

## Troubleshooting

**Completion not showing results**: Ensure the genero-tools query tool is properly configured and your codebase is indexed.

**Auto-completion triggering too frequently**: Increase `autocomplete_delay` to a higher value (e.g., 1000ms).

**Auto-completion not triggering**: Verify `autocomplete_on_pause` is set to `1` (or `true` in Lua).

**Completion menu closes immediately**: This is normal if you continue typing. The menu will reappear after the configured delay.


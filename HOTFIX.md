# Hotfix for Runtime Error

## Issue
After the performance optimization update, you may see this error:
```
E117: Unknown function: genero_tools#hints#get_hints
```

## Cause
Neovim has the old version of the hints module loaded in memory. The `get_hints` function exists in the updated file but Neovim hasn't reloaded it yet.

## Solution

### Option 1: Restart Neovim (Recommended)
Simply close and reopen Neovim. This will load all the updated files.

### Option 2: Reload the Module
Run these commands in Neovim:
```vim
:unlet g:genero_tools_hints_state
:runtime! autoload/genero_tools/hints.vim
:call genero_tools#hints#init()
```

### Option 3: Source the Plugin
```vim
:source ~/.vim/plugged/genero-vim/plugin/genero-tools.vim
```
(Adjust path based on your plugin manager)

## Verification
After reloading, the error should disappear. You can verify by:
1. Opening a .4gl file
2. Moving the cursor around
3. No errors should appear

## Why This Happened
The performance optimizations modified the hints.vim file structure. During development, we ensured the `get_hints` function was preserved, but Neovim needs to reload the file to see the changes.

## Prevention
This is a one-time issue. After restarting Neovim once, the updated code will be loaded and the error won't recur.

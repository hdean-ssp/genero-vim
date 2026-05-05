# Hotfix for Runtime Error

## Issue
After the performance optimization update, you may see this error:
```
E117: Unknown function: genero_tools#hints#get_hints
```

## Status
✅ **FIXED** in commit `4a5b02b`

## Cause
There was orphaned code (a `let` statement outside any function) that prevented the rest of the hints.vim file from loading properly. This has been removed.

## Solution

### Update to Latest Version
```bash
cd ~/.vim/plugged/genero-vim  # or your plugin directory
git pull origin main
```

Then restart Neovim. The error is now fixed.

## Verification
After reloading, the error should disappear. You can verify by:
1. Opening a .4gl file
2. Moving the cursor around
3. No errors should appear

## What Was Fixed
The orphaned `let bufnr = a:bufnr > 0 ? a:bufnr : bufnr('%')` statement on line 140 was removed. This line was outside any function and caused Vim to stop parsing the file, preventing the `get_hints` function from being defined.

## Prevention
This was a one-time issue caused by sed-based text replacement during development. The fix has been tested and verified.

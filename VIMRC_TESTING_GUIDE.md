# Vim Configuration Testing Guide

To identify which setting breaks arrow keys, test these vimrcs in order:

## Test Sequence

1. **`.vimrc.test1-minimal`** - Absolute minimal (just `set nocompatible`)
   - Arrow keys should work ✓

2. **`.vimrc.test2-basic-settings`** - Add basic UI/search/performance settings
   - Arrow keys should work ✓

3. **`.vimrc.test3-with-plugins`** - Add vim-plug initialization
   - Arrow keys should work ✓

4. **`.vimrc.test4-with-config`** - Add Genero Tools config
   - Arrow keys should work ✓

5. **`.vimrc.test5-with-keybindings`** - Add keybindings
   - Arrow keys should work ✓

6. **`.vimrc.test6-with-autocmds`** - Add autocmds
   - Arrow keys should work ✓

7. **`.vimrc.test7-full`** - Full config with Neovim-specific sections
   - Arrow keys may break here ✗

## How to Test

For each test file:

```bash
cp .vimrc.testN-description ~/.vimrc
vim addonshub4.4gl
# Test arrow keys in normal mode
# Report: WORKS or BROKEN
```

## Report Format

Please tell me which test(s) work and which break:
- Test 1: WORKS/BROKEN
- Test 2: WORKS/BROKEN
- Test 3: WORKS/BROKEN
- Test 4: WORKS/BROKEN
- Test 5: WORKS/BROKEN
- Test 6: WORKS/BROKEN
- Test 7: WORKS/BROKEN

This will help identify exactly which feature breaks arrow key detection.

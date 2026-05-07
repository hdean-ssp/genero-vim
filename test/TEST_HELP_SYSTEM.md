# Help System Test Suite

## Overview

This test suite verifies the functionality of the Genero Tools help system.

## Test File

`test/test_help_system.lua` - Comprehensive test suite for help system

## Running Tests

### From Neovim

```vim
" Load and run all tests
:lua require('test.test_help_system').run_all_tests()

" Run individual tests
:lua require('test.test_help_system').test_module_loads()
:lua require('test.test_help_system').test_help_window_opens()
```

### From Command Line

```bash
# Run tests with Neovim
nvim --headless -c "lua require('test.test_help_system').run_all_tests()" -c "qa"
```

## Test Cases

### Test 1: Module Loads Successfully
Verifies that the help module can be loaded without errors.

**Expected**: Module loads and returns a table

### Test 2: Module Has Required Functions
Verifies that the help module exports the required functions.

**Expected**: `show()`, `toggle()`, and `close()` functions exist

### Test 3: Commands Are Registered
Verifies that the help commands are registered in Neovim.

**Expected**: `:GeneroHelp`, `:GeneroHelpToggle`, and `:GeneroHelpClose` commands exist

### Test 4: Help Window Can Be Opened
Verifies that the help window can be opened successfully.

**Expected**: Help window is created with correct filetype

### Test 5: Help Window Can Be Closed
Verifies that the help window can be closed successfully.

**Expected**: Help window is removed after close

### Test 6: Help Window Can Be Toggled
Verifies that the help window can be toggled on and off.

**Expected**: Window opens on first toggle, closes on second toggle

### Test 7: Help Content Is Not Empty
Verifies that the help window contains content.

**Expected**: Buffer has substantial content (>50 lines)

### Test 8: Help Content Has Expected Categories
Verifies that the help content includes expected categories.

**Expected**: Content includes COMPILATION, NAVIGATION, GENERO TOOLS, etc.

## Expected Output

```
=== Running Help System Tests ===

✓ Test 1 passed: Module loads successfully
✓ Test 2 passed: Module has required functions
✓ Test 3 passed: Commands are registered
✓ Test 4 passed: Help window can be opened
✓ Test 5 passed: Help window can be closed
✓ Test 6 passed: Help window can be toggled
✓ Test 7 passed: Help content is not empty
✓ Test 8 passed: Help content has expected categories

=== Test Results ===
Passed: 8
Failed: 0
Total:  8

✓ All tests passed!
```

## Troubleshooting

### Module Not Found
If you get "module not found" errors:

1. Ensure `lua/genero_tools/help.lua` exists
2. Check that Neovim's runtimepath includes the plugin directory
3. Verify the plugin is properly installed

### Commands Not Registered
If commands are not found:

1. Ensure `init.lua.example` changes are applied to your config
2. Restart Neovim after config changes
3. Check for errors with `:messages`

### Window Tests Fail
If window tests fail:

1. Ensure you're running Neovim (not Vim)
2. Check Neovim version (0.9.5+ recommended)
3. Verify no conflicting plugins

## Manual Testing

In addition to automated tests, manually verify:

1. **Visual Appearance**
   - Window is centered and properly sized
   - Border is rounded with title
   - Syntax highlighting is applied

2. **Navigation**
   - j/k scrolls line by line
   - Ctrl+d/u pages down/up
   - G/gg jumps to end/beginning
   - / starts search
   - n/N navigates search results

3. **Keybindings**
   - `<Space>gh` toggles window
   - q closes window
   - Esc closes window

4. **Content**
   - All categories are present
   - Keybindings are accurate
   - Commands are correct
   - Descriptions are clear

## Integration Testing

Test help system with other features:

1. **With which-key**
   - Press `<Space>` to see which-key menu
   - Verify `gh` is listed under Genero-Tools
   - Press `gh` to toggle help

2. **With Telescope**
   - Open help window
   - Switch to another window
   - Use Telescope pickers
   - Return to help window

3. **With Terminal**
   - Open help window
   - Open terminal with `Ctrl+\`
   - Verify help window persists
   - Close terminal and return to help

4. **On Startup**
   - Start Neovim with no files
   - Verify help displays automatically
   - Close help and reopen with `<Space>gh`

## Performance Testing

Verify performance characteristics:

1. **Open Speed**
   - Help window should open instantly (<100ms)
   - No noticeable lag

2. **Navigation Speed**
   - Scrolling should be smooth
   - Search should be fast

3. **Memory Usage**
   - Help window should not leak memory
   - Closing should free resources

## Regression Testing

After making changes, verify:

1. All automated tests still pass
2. Manual tests still work
3. No new errors in `:messages`
4. Help content is still accurate
5. Window behavior is unchanged

## See Also

- [HELP_SYSTEM.md](../docs/HELP_SYSTEM.md) - Help system documentation
- [HELP_SYSTEM_UPDATE.md](../docs/HELP_SYSTEM_UPDATE.md) - Implementation details
- [README.md](README.md) - Main test documentation

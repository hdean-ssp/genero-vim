# Help System Architecture

## Overview

This document describes the architecture and design of the Genero Tools help system.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Keybinding: <Space>gh                                         │
│  Commands: :GeneroHelp, :GeneroHelpToggle, :GeneroHelpClose    │
│                                                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Command Layer (Vim)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  vim.api.nvim_create_user_command("GeneroHelp", ...)          │
│  vim.api.nvim_create_user_command("GeneroHelpToggle", ...)    │
│  vim.api.nvim_create_user_command("GeneroHelpClose", ...)     │
│                                                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Help Module (Lua)                              │
│                  lua/genero_tools/help.lua                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  help_content (table)                                   │  │
│  │  ├── category: "COMPILATION"                            │  │
│  │  │   └── items: [{key, cmd, desc}, ...]                │  │
│  │  ├── category: "NAVIGATION"                             │  │
│  │  │   └── items: [{key, cmd, desc}, ...]                │  │
│  │  └── ... (16 categories total)                          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Functions                                              │  │
│  │  ├── format_help_lines()  - Format content to lines    │  │
│  │  ├── M.show()             - Open help window           │  │
│  │  ├── M.toggle()           - Toggle help window         │  │
│  │  └── M.close()            - Close help window          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  State                                                  │  │
│  │  ├── help_buf  - Buffer ID                             │  │
│  │  └── help_win  - Window ID                             │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Neovim API Layer                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  vim.api.nvim_create_buf()      - Create buffer               │
│  vim.api.nvim_buf_set_lines()   - Set buffer content          │
│  vim.api.nvim_open_win()        - Create floating window      │
│  vim.api.nvim_win_close()       - Close window                │
│  vim.keymap.set()               - Set keybindings             │
│                                                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Display Layer                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╔══════════════════════════════════════════════════════════╗  │
│  ║         Genero Tools - Comprehensive Help              ║  │
│  ╚══════════════════════════════════════════════════════════╝  │
│                                                                 │
│  COMPILATION:                                                  │
│  ────────────────────────────────────────────────────────────  │
│    F5                :GeneroCompile         Compile file       │
│    <Space>ca         :GeneroAutocompile...  Enable autocompile │
│    ...                                                         │
│                                                                 │
│  ╔══════════════════════════════════════════════════════════╗  │
│  ║  Navigation: j/k • q/Esc to close • / to search        ║  │
│  ╚══════════════════════════════════════════════════════════╝  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Opening Help Window

```
User Action
    │
    ├─ Press <Space>gh
    │  OR
    └─ Run :GeneroHelp
         │
         ▼
    Command Layer
         │
         ├─ Parse command
         └─ Call Lua function
              │
              ▼
         Help Module
              │
              ├─ Check if window exists
              ├─ Create buffer
              ├─ Format help content
              ├─ Set buffer lines
              ├─ Calculate window size
              ├─ Create floating window
              ├─ Set window options
              ├─ Set keybindings
              └─ Apply syntax highlighting
                   │
                   ▼
              Neovim API
                   │
                   ├─ nvim_create_buf()
                   ├─ nvim_buf_set_lines()
                   ├─ nvim_open_win()
                   └─ nvim_win_set_option()
                        │
                        ▼
                   Display Layer
                        │
                        └─ Show floating window
```

### Closing Help Window

```
User Action
    │
    ├─ Press q or Esc
    │  OR
    ├─ Press <Space>gh (toggle)
    │  OR
    └─ Run :GeneroHelpClose
         │
         ▼
    Help Module
         │
         ├─ Check if window exists
         ├─ Close window
         └─ Clear state
              │
              ▼
         Neovim API
              │
              └─ nvim_win_close()
                   │
                   ▼
              Display Layer
                   │
                   └─ Remove floating window
```

---

## Component Details

### 1. Help Content Structure

```lua
help_content = {
  {
    category = "CATEGORY_NAME",
    items = {
      {
        key = "keybinding",    -- e.g., "<Space>gl"
        cmd = ":Command",      -- e.g., ":GeneroLookup"
        desc = "Description"   -- e.g., "Lookup function"
      },
      -- More items...
    }
  },
  -- More categories...
}
```

### 2. Window Configuration

```lua
window_opts = {
  relative = 'editor',           -- Relative to editor
  width = columns * 0.85,        -- 85% of screen width
  height = lines * 0.85,         -- 85% of screen height
  row = (lines - height) / 2,    -- Centered vertically
  col = (columns - width) / 2,   -- Centered horizontally
  style = 'minimal',             -- Minimal UI
  border = 'rounded',            -- Rounded border
  title = ' Genero Tools Help ', -- Window title
  title_pos = 'center',          -- Centered title
}
```

### 3. Buffer Configuration

```lua
buffer_opts = {
  bufhidden = 'wipe',           -- Wipe buffer when hidden
  filetype = 'genero-help',     -- Custom filetype
  modifiable = false,           -- Read-only
}
```

### 4. Keybinding Configuration

```lua
keybindings = {
  { 'n', 'q',        close_window },
  { 'n', '<Esc>',    close_window },
  { 'n', 'j',        scroll_down },
  { 'n', 'k',        scroll_up },
  { 'n', 'G',        jump_to_end },
  { 'n', 'gg',       jump_to_beginning },
  { 'n', '<C-d>',    page_down },
  { 'n', '<C-u>',    page_up },
  { 'n', '/',        search },
  { 'n', 'n',        next_search },
  { 'n', 'N',        prev_search },
}
```

---

## State Management

### Window State

```lua
-- Module-level state
local help_buf = nil  -- Buffer ID (number or nil)
local help_win = nil  -- Window ID (number or nil)

-- State transitions
nil → number  -- Window opened
number → nil  -- Window closed
```

### State Diagram

```
┌─────────┐
│ Closed  │ ◄─────────────────────┐
│ (nil)   │                       │
└────┬────┘                       │
     │                            │
     │ show() or toggle()         │
     │                            │
     ▼                            │
┌─────────┐                       │
│  Open   │                       │
│(number) │                       │
└────┬────┘                       │
     │                            │
     │ close() or toggle()        │
     │                            │
     └────────────────────────────┘
```

---

## Integration Points

### 1. which-key Integration

```lua
-- Neovim 0.10+ (which-key v3+)
wk.add({
  { "<leader>gh", ":GeneroHelpToggle<CR>", desc = "Toggle help window" },
})

-- Neovim 0.9.x (which-key v1.x)
wk.register({
  g = {
    h = { ":GeneroHelpToggle<CR>", "Toggle help window" },
  },
}, { prefix = "<leader>" })
```

### 2. Command Registration

```lua
vim.api.nvim_create_user_command("GeneroHelp", function()
  require('genero_tools.help').show()
end, {})

vim.api.nvim_create_user_command("GeneroHelpToggle", function()
  require('genero_tools.help').toggle()
end, {})

vim.api.nvim_create_user_command("GeneroHelpClose", function()
  require('genero_tools.help').close()
end, {})
```

### 3. Startup Integration

```lua
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("GeneroHelp")
    end
  end,
})
```

---

## Syntax Highlighting

### Highlight Groups

```vim
syntax match GeneroHelpHeader /^╔.*╗$/
syntax match GeneroHelpHeader /^║.*║$/
syntax match GeneroHelpHeader /^╚.*╝$/
syntax match GeneroHelpCategory /^[A-Z][A-Z &/(),:]*:$/
syntax match GeneroHelpSeparator /^─\+$/
syntax match GeneroHelpKey /^\s\s\S\+\s\+/
syntax match GeneroHelpCommand /:\w\+/
syntax match GeneroHelpBullet /^\s\s•/

highlight link GeneroHelpHeader Title
highlight link GeneroHelpCategory Function
highlight link GeneroHelpSeparator Comment
highlight link GeneroHelpKey Identifier
highlight link GeneroHelpCommand Keyword
highlight link GeneroHelpBullet Special
```

### Color Scheme

```
Headers (╔═╗ ║ ╚═╝)  → Title      (bright/bold)
Categories (TEXT:)    → Function   (cyan/blue)
Separators (────)     → Comment    (gray)
Keybindings (<key>)   → Identifier (yellow/orange)
Commands (:Command)   → Keyword    (purple/magenta)
Bullets (•)           → Special    (red/orange)
```

---

## Performance Characteristics

### Time Complexity

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Open window | O(n) | n = number of help lines (~200) |
| Close window | O(1) | Constant time |
| Toggle window | O(n) or O(1) | Depends on current state |
| Format content | O(n) | n = number of help items (~100) |
| Search | O(n) | Built-in Vim search |

### Space Complexity

| Component | Size | Notes |
|-----------|------|-------|
| Help content | ~10 KB | Structured data |
| Formatted lines | ~20 KB | Text lines |
| Buffer | ~20 KB | In-memory buffer |
| Window | ~1 KB | Window metadata |
| Total | ~51 KB | Minimal memory footprint |

### Optimization Strategies

1. **Lazy Loading**: Module loaded only when needed
2. **Single Instance**: Only one help window at a time
3. **Efficient Formatting**: Content formatted once per open
4. **Minimal State**: Only buffer and window IDs stored
5. **Clean Cleanup**: Resources freed on close

---

## Error Handling

### Error Scenarios

```lua
-- Scenario 1: Module load failure
local ok, help = pcall(require, 'genero_tools.help')
if not ok then
  vim.notify("Help module failed to load", vim.log.levels.ERROR)
  return
end

-- Scenario 2: Window creation failure
local ok, win = pcall(vim.api.nvim_open_win, buf, true, opts)
if not ok then
  vim.notify("Failed to create help window", vim.log.levels.ERROR)
  return
end

-- Scenario 3: Invalid window ID
if help_win and not vim.api.nvim_win_is_valid(help_win) then
  help_win = nil  -- Reset state
end
```

### Recovery Strategies

1. **Graceful Degradation**: Fall back to echo-based help
2. **State Reset**: Clear invalid state
3. **User Notification**: Inform user of errors
4. **Retry Logic**: Allow user to retry operation

---

## Testing Strategy

### Unit Tests

```lua
-- Test module loading
test_module_loads()

-- Test function existence
test_module_functions()

-- Test command registration
test_commands_registered()
```

### Integration Tests

```lua
-- Test window operations
test_help_window_opens()
test_help_window_closes()
test_help_window_toggles()
```

### Content Tests

```lua
-- Test content validity
test_help_content_not_empty()
test_help_content_categories()
```

---

## Extension Points

### Adding New Categories

```lua
-- In lua/genero_tools/help.lua
table.insert(help_content, {
  category = "NEW CATEGORY",
  items = {
    { key = "keybinding", cmd = ":Command", desc = "Description" },
  }
})
```

### Customizing Window Appearance

```lua
-- Modify window options
local opts = {
  relative = 'editor',
  width = custom_width,
  height = custom_height,
  border = 'double',  -- Change border style
  title = 'Custom Title',
}
```

### Adding Custom Keybindings

```lua
-- Add custom keybindings in help window
vim.keymap.set('n', 'custom_key', function()
  -- Custom action
end, { buffer = help_buf })
```

---

## Future Architecture Considerations

### Potential Enhancements

1. **Plugin System**: Allow plugins to add help sections
2. **Dynamic Content**: Load help content from external files
3. **Localization**: Support multiple languages
4. **Themes**: Customizable color schemes
5. **Export**: Generate help in different formats (HTML, PDF)

### Scalability

- Current design supports 100+ help items efficiently
- Can scale to 1000+ items with minimal performance impact
- Modular structure allows easy extension

---

## See Also

- [HELP_SYSTEM.md](HELP_SYSTEM.md) - User documentation
- [HELP_SYSTEM_UPDATE.md](HELP_SYSTEM_UPDATE.md) - Implementation details
- [HELP_SYSTEM_IMPLEMENTATION.md](../HELP_SYSTEM_IMPLEMENTATION.md) - Complete summary
- [lua/genero_tools/help.lua](../lua/genero_tools/help.lua) - Source code

# Configuration Examples Updated

## Summary

All example configuration files have been updated to include the new Configurable Code Hints feature that was implemented in Phase 1.

## Files Updated

### 1. README.md
**Changes:**
- Added comprehensive hints configuration section with all 26 configuration options
- Added hints feature description in the Features section
- Added Code Hints Commands section with 7 new commands
- Updated configuration example to include all hints options
- Added hints documentation reference

**New Sections:**
- Code Hints Configuration (with all individual checks and thresholds)
- Code Hints Commands (GeneroNextHint, GeneroPrevHint, GeneroListHints, etc.)

### 2. init.lua.example
**Changes:**
- Added complete hints configuration block with all options
- Added hints keybindings (Space+hn, Space+hp, Space+hl, Space+hd, Space+hf)
- Updated which-key descriptions to include hints group
- Updated help text to include hints commands
- Added hints to the keybindings documentation

**New Configuration Options:**
- hints_enabled, hints_display, hints_severity
- hints_realtime, hints_cache_enabled, hints_cache_ttl, hints_delay
- auto_fix_enabled
- All 14 individual hint checks (trailing_whitespace, mixed_indentation, etc.)
- Threshold options (max_line_length, max_nesting_depth, max_blank_lines, naming_convention_style)

**New Keybindings:**
- `<leader>hn` - Next hint
- `<leader>hp` - Previous hint
- `<leader>hl` - List hints
- `<leader>hd` - Hint details
- `<leader>hf` - Auto-fix hint

### 3. docs/NEOVIM_SETUP.md
**Changes:**
- Added hints keybindings to the keybindings table
- Added Code Hints Commands section
- Added Code Hints feature description in Features section
- Updated help text to include hints commands

**New Keybindings:**
- `Space+hn` - Jump to next hint
- `Space+hp` - Jump to previous hint
- `Space+hl` - List all hints
- `Space+hd` - Show hint details
- `Space+hf` - Apply auto-fix for hint

## Configuration Options Reference

### System-Level Options
- `hints_enabled` - Enable/disable all hints (default: 1)
- `hints_display` - Display mode: 'signs', 'virtual_text', 'both' (default: 'signs')
- `hints_severity` - Severity level: 'info', 'warning', 'style' (default: 'warning')
- `hints_realtime` - Enable real-time detection (default: 1)
- `hints_cache_enabled` - Enable hint caching (default: 1)
- `hints_cache_ttl` - Cache TTL in seconds (default: 300)
- `auto_fix_enabled` - Enable auto-fix suggestions (default: 1)
- `hints_delay` - Debounce delay in milliseconds (default: 500)

### Individual Hint Checks (14 total)
- `trailing_whitespace` (default: 1)
- `mixed_indentation` (default: 1)
- `indentation_consistency` (default: 1)
- `multiple_blank_lines` (default: 1)
- `lowercase_keywords` (default: 1)
- `lowercase_functions` (default: 1)
- `keyword_consistency` (default: 1)
- `naming_convention` (default: 0)
- `unclosed_blocks` (default: 1)
- `nesting_depth` (default: 1)
- `line_length` (default: 1)
- `missing_comments` (default: 0)
- `missing_error_handling` (default: 0)
- `deprecated_functions` (default: 1)

### Threshold Options
- `max_line_length` (default: 100)
- `max_nesting_depth` (default: 5)
- `max_blank_lines` (default: 2)
- `naming_convention_style` (default: 'camelCase')

## Commands Added

### Hint Navigation
- `:GeneroNextHint` - Jump to next hint in file
- `:GeneroPrevHint` - Jump to previous hint in file
- `:GeneroListHints` - Display all hints in current file

### Hint Details & Actions
- `:GeneroHintDetails` - Show details for hint at cursor
- `:GeneroHintAutofix` - Apply auto-fix for hint at cursor
- `:GeneroClearHintCache` - Clear all cached hints
- `:GeneroHintHelp [hint_name]` - Show help for a specific hint

## Keybindings Added

### Vim/Neovim (init.lua.example)
- `<leader>hn` - Next hint
- `<leader>hp` - Previous hint
- `<leader>hl` - List hints
- `<leader>hd` - Hint details
- `<leader>hf` - Auto-fix hint

### Neovim Setup (docs/NEOVIM_SETUP.md)
- `Space+hn` - Jump to next hint
- `Space+hp` - Jump to previous hint
- `Space+hl` - List all hints
- `Space+hd` - Show hint details
- `Space+hf` - Apply auto-fix for hint

## Which-Key Integration

Added new hints group to which-key descriptions:
```lua
h = {
  name = "+Hints",
  n = { ":GeneroNextHint<CR>", "Next hint" },
  p = { ":GeneroPrevHint<CR>", "Previous hint" },
  l = { ":GeneroListHints<CR>", "List all hints" },
  d = { ":GeneroHintDetails<CR>", "Hint details" },
  f = { ":GeneroHintAutofix<CR>", "Apply auto-fix" },
},
```

## Documentation References

All example files now reference the Code Hints documentation:
- README.md: "See [Code Hints Documentation](docs/HINTS.md) for complete details"
- NEOVIM_SETUP.md: Updated features section with hints description

## Backward Compatibility

All updates are backward compatible:
- Existing configurations continue to work
- New hints options have sensible defaults
- Hints can be disabled by setting `hints_enabled = 0`
- All existing keybindings remain unchanged

## Next Steps

1. Users can now copy the updated example files to their configurations
2. Hints will work out-of-the-box with default settings
3. Users can customize hints by modifying the configuration options
4. Per-file configuration can be set via `.genero-hints` file in project root

## Verification

All example files have been verified to:
- ✅ Include all hints configuration options
- ✅ Include all hints commands
- ✅ Include all hints keybindings
- ✅ Have proper documentation references
- ✅ Maintain backward compatibility
- ✅ Follow existing code style and conventions

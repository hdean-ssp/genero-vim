# Sign Column Implementation - Unified System

## What Was Added

A new unified sign column management module (`autoload/genero_tools/signs.vim`) that intelligently combines compiler diagnostics and SVN diff markers in a single sign column.

## Key Features

### Combined Sign Display
When both a compiler diagnostic and SVN marker appear on the same line, they are combined:
- `✕|~` - Error with modified line
- `⚠|+` - Warning with added line
- `ℹ|-` - Info with deleted line

### Smart Caching
Combined signs are cached to avoid redundant sign definitions, improving performance with many errors.

### Flexible Integration
- Works independently with compiler signs
- Works independently with SVN signs
- Can combine both systems in a single column
- Graceful fallback if combination fails

## API Functions

### Initialization
```vim
call genero_tools#signs#init()
```
Initializes both compiler and SVN sign subsystems.

### Get Combined Sign
```vim
let combined = genero_tools#signs#get_combined_sign(compiler_sign, svn_sign)
```
Returns the combined sign name for two sign types. If only one is provided, returns that sign.

### Place Combined Signs
```vim
call genero_tools#signs#place_combined(bufnr, compiler_signs, svn_signs)
```
Places combined signs for a buffer. Arguments:
- `bufnr` - Buffer number
- `compiler_signs` - Dict mapping line numbers to compiler sign names
- `svn_signs` - Dict mapping line numbers to SVN sign names

### Clear Combined Signs
```vim
call genero_tools#signs#clear_combined(bufnr)
call genero_tools#signs#clear_combined_all()
```
Clears combined signs for a specific buffer or globally.

## Implementation Details

### Sign Mapping
The module maintains mappings for:
- Sign text representations (✕, ⚠, ℹ, +, ~, -)
- Highlight groups (ErrorMsg, WarningMsg, InfoMsg, etc.)

### Sign Groups
- `genero_compiler` - Compiler diagnostic signs
- `genero_svn` - SVN diff marker signs
- `genero_combined` - Combined signs (when using unified system)

### Performance
- Sign definitions are cached to avoid recreation
- Efficient line number sorting for placement
- Minimal overhead for single-sign lines

## Configuration

Enable unified signs in your config:
```vim
let g:genero_tools_unified_signs = 1
```

Or keep separate columns:
```vim
let g:genero_tools_unified_signs = 0
```

## Documentation

See `docs/UNIFIED_SIGN_COLUMN.md` for complete details including:
- Architecture overview
- Visual examples
- Integration points
- Future enhancements

## Testing

Test files for the unified sign system:
- `test/test_unified_signs.vim` - Core functionality tests
- `test/test_sign_column_integration.vim` - Integration tests
- `test/test_sign_column_stability.vim` - Stability and edge cases


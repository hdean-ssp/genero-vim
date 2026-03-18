# Unified Sign Column System

## Overview

The unified sign column system allows both compiler diagnostics and SVN diff markers to be displayed simultaneously in the sign column, with intelligent combination when both signs appear on the same line.

## Architecture

### Sign Types

**Compiler Diagnostics:**
- `✕` - Error (red)
- `⚠` - Warning (yellow)
- `ℹ` - Info (blue)

**SVN Diff Markers:**
- `+` - Added line (green)
- `~` - Modified line (yellow)
- `-` - Deleted line (red)

### Combined Signs

When both a compiler diagnostic and SVN marker appear on the same line, they are combined using a pipe separator:

```
✕|~  - Error with modified line
⚠|+  - Warning with added line
ℹ|-  - Info with deleted line
```

This approach:
- Reduces screen real estate compared to separate columns
- Maintains visual clarity with distinct symbols
- Prioritizes compiler errors (shown first)
- Uses color from the compiler diagnostic (higher priority)

## Implementation

### Core Module: `autoload/genero_tools/signs.vim`

**Key Functions:**

- `genero_tools#signs#init()` - Initialize both compiler and SVN sign systems
- `genero_tools#signs#get_combined_sign(compiler_sign, svn_sign)` - Get combined sign name
- `genero_tools#signs#place_combined(bufnr, compiler_signs, svn_signs)` - Place combined signs
- `genero_tools#signs#clear_combined(bufnr)` - Clear combined signs for a buffer

### Sign Caching

Combined signs are cached to avoid recreating the same combinations repeatedly:

```vim
let s:sign_cache = {}  " Maps 'compiler_sign|svn_sign' -> 'GeneroCombo_N'
```

### Integration Points

**Compiler Module** (`autoload/genero_tools/compiler/signs.vim`):
- Continues to place signs in `genero_compiler` group
- Can be used independently or with unified system

**SVN Module** (`autoload/genero_tools/svn/signs.vim`):
- Continues to place signs in `genero_svn` group
- Can be used independently or with unified system

**Unified System** (`autoload/genero_tools/signs.vim`):
- Reads signs from both groups
- Creates combined signs in `genero_combined` group
- Manages sign lifecycle

## Usage

### Option 1: Separate Sign Columns (Current)

Keep compiler and SVN signs in separate columns:

```vim
" Compiler signs in column 1
sign place 1 group=genero_compiler line=5 name=GeneroCompilerError buffer=1

" SVN signs in column 2
sign place 2 group=genero_svn line=5 name=GeneroSVNModified buffer=1
```

Result: Two columns with independent signs

### Option 2: Combined Sign Column (Recommended)

Use unified system for space efficiency:

```vim
" Collect signs from both systems
let compiler_signs = { 5: 'GeneroCompilerError' }
let svn_signs = { 5: 'GeneroSVNModified' }

" Place combined signs
call genero_tools#signs#place_combined(bufnr, compiler_signs, svn_signs)
```

Result: Single column with combined signs like `✕|~`

## Configuration

Add to your config to enable unified signs:

```vim
" Enable unified sign column
let g:genero_tools_unified_signs = 1

" Or keep separate columns
let g:genero_tools_unified_signs = 0
```

## Visual Examples

### Separate Columns
```
Line  Col1  Col2  Code
  1   ✕           function foo()
  2        +      let x = 1
  3   ⚠     ~     let y = x + 2
  4             return y
```

### Combined Column
```
Line  Col1      Code
  1   ✕         function foo()
  2   +         let x = 1
  3   ⚠|~       let y = x + 2
  4             return y
```

## Performance Considerations

- Sign caching prevents redundant sign definitions
- Combined signs are only created when needed
- Minimal overhead for single-sign lines
- Efficient line number sorting for placement

## Future Enhancements

1. **Configurable Separators**: Allow users to choose between `|`, `:`, `/`, etc.
2. **Priority Ordering**: Configurable which sign type takes precedence
3. **Compact Mode**: Use single character combinations (e.g., `E` for error+modified)
4. **Hover Information**: Show both sign details on hover in Neovim
5. **Sign Stacking**: Support more than 2 simultaneous signs per line

## Compatibility

- Vim 7.4.2201+ (for `signcolumn=yes`)
- Neovim 0.3.0+
- Graceful fallback to single signs if combination fails

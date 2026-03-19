# Code Hints System

The Code Hints feature provides non-fatal code quality warnings that help maintain consistent code style and catch potential issues in Genero code. Unlike compiler errors which block compilation, hints are suggestions that improve code quality.

## Overview

Hints detect four categories of issues:

1. **Whitespace & Formatting** - Trailing whitespace, mixed indentation, excessive blank lines
2. **Keyword & Naming** - Lowercase keywords, inconsistent casing, naming convention violations
3. **Code Structure** - Unclosed blocks, excessive nesting, long lines, missing comments
4. **Genero-Specific** - Missing error handling, deprecated functions

## Quick Start

Hints are enabled by default. They appear as signs in the sign column (◆ symbol) and can be configured extensively.

```vim
" View current hint configuration
:GeneroConfigShow

" Navigate hints
:GeneroNextHint
:GeneroPrevHint
:GeneroListHints

" Clear hints for current buffer
:GeneroClearHints

" Apply auto-fix for hint at cursor
:GeneroHintAutofix
```

## Configuration

All hint settings are stored in `g:genero_tools_config`:

```vim
" Enable/disable all hints
let g:genero_tools_config.hints_enabled = 1

" Display method: 'signs', 'virtual_text', or 'both'
let g:genero_tools_config.hints_display = 'signs'

" Severity level: 'info', 'warning', or 'style'
let g:genero_tools_config.hints_severity = 'warning'

" Real-time detection (as you type)
let g:genero_tools_config.hints_realtime = 1

" Delay before analyzing (milliseconds)
let g:genero_tools_config.hints_delay = 500

" Enable caching for performance
let g:genero_tools_config.hints_cache_enabled = 1

" Cache time-to-live (seconds)
let g:genero_tools_config.hints_cache_ttl = 300

" Enable auto-fix suggestions
let g:genero_tools_config.auto_fix_enabled = 1
```

### Individual Hint Checks

Enable or disable specific hint checks:

```vim
" Whitespace checks
let g:genero_tools_config.trailing_whitespace = 1
let g:genero_tools_config.mixed_indentation = 1
let g:genero_tools_config.indentation_consistency = 1
let g:genero_tools_config.multiple_blank_lines = 1

" Keyword & naming checks
let g:genero_tools_config.lowercase_keywords = 1
let g:genero_tools_config.lowercase_functions = 1
let g:genero_tools_config.keyword_consistency = 1
let g:genero_tools_config.naming_convention = 0  " Disabled by default

" Code structure checks
let g:genero_tools_config.unclosed_blocks = 1
let g:genero_tools_config.nesting_depth = 1
let g:genero_tools_config.line_length = 1
let g:genero_tools_config.missing_comments = 0  " Disabled by default

" Genero-specific checks
let g:genero_tools_config.missing_error_handling = 0  " Disabled by default
let g:genero_tools_config.deprecated_functions = 1
```

### Thresholds

Configure numeric limits for hint detection:

```vim
" Maximum line length (default: 100)
let g:genero_tools_config.max_line_length = 100

" Maximum nesting depth (default: 5)
let g:genero_tools_config.max_nesting_depth = 5

" Maximum consecutive blank lines (default: 2)
let g:genero_tools_config.max_blank_lines = 2

" Naming convention style: 'camelCase' or 'snake_case'
let g:genero_tools_config.naming_convention_style = 'camelCase'
```

## Display Modes

### Signs (Default)

Hints display as signs in the sign column:

```
42 | ◆ FUNCTION myFunc()
```

The sign appears at the line with the issue. Click on the sign to see details.

### Virtual Text (Neovim only)

Hints display as inline text at the end of the line:

```
42 | FUNCTION myFunc()              ◆ Lowercase keyword detected
```

Enable with:

```vim
let g:genero_tools_config.hints_display = 'virtual_text'
```

### Both

Display both signs and virtual text:

```vim
let g:genero_tools_config.hints_display = 'both'
```

## Commands

### Navigation

```vim
:GeneroNextHint              " Jump to next hint
:GeneroPrevHint              " Jump to previous hint
:GeneroListHints             " Display all hints in current file
:GeneroHintDetails           " Show details for hint at cursor
```

### Management

```vim
:GeneroClearHints            " Clear all hints for current buffer
:GeneroClearHintCache        " Clear hint cache
:GeneroHintHelp [name]       " Show help for specific hint
```

### Auto-fix

```vim
:GeneroHintAutofix           " Apply auto-fix for hint at cursor
```

## Hint Details

When you navigate to a hint or view details, you see:

- **Message** - Description of the issue
- **Severity** - info, warning, or style
- **Category** - whitespace, keyword, structure, or genero
- **Line/Column** - Exact location of the issue
- **Auto-fix** - Suggested fix (if available)
- **Explanation** - Why this hint was triggered

## Auto-fix Suggestions

Many hints have automatic fixes available:

- **Trailing whitespace** - Remove trailing spaces
- **Mixed indentation** - Convert to consistent indentation
- **Lowercase keywords** - Convert to uppercase
- **Lowercase functions** - Convert to uppercase
- **Excessive blank lines** - Remove extra blank lines

Apply auto-fix with:

```vim
:GeneroHintAutofix
```

Or configure to apply automatically:

```vim
let g:genero_tools_config.auto_fix_enabled = 1
```

## Real-time Detection

Hints are detected in real-time as you type (with configurable delay):

```vim
" Enable real-time detection
let g:genero_tools_config.hints_realtime = 1

" Delay before analyzing (default: 500ms)
let g:genero_tools_config.hints_delay = 500
```

Disable real-time detection to only check on file save:

```vim
let g:genero_tools_config.hints_realtime = 0
```

## Per-File Configuration

Create a `.genero-hints` file in your project root to configure hints per-file:

```json
{
  "rules": [
    {
      "pattern": "**/*.4gl",
      "config": {
        "max_line_length": 120,
        "lowercase_keywords": 0
      }
    },
    {
      "pattern": "legacy/**/*.4gl",
      "config": {
        "hints_enabled": 0
      }
    }
  ]
}
```

## Performance

Hints are optimized for performance:

- **Caching** - Results cached with TTL to avoid re-analysis
- **Debouncing** - Real-time analysis debounced to prevent excessive checks
- **Selective Analysis** - Only affected lines re-analyzed on changes
- **Background Analysis** - Other files analyzed when editor is idle

For large files or slow systems, adjust:

```vim
" Increase cache TTL
let g:genero_tools_config.hints_cache_ttl = 600

" Increase debounce delay
let g:genero_tools_config.hints_delay = 1000

" Disable real-time detection
let g:genero_tools_config.hints_realtime = 0
```

## Vim/Neovim Compatibility

- **Vim 8+** - Full support with signs and basic display
- **Neovim 0.3.2+** - Full support including virtual text and floating windows
- **Vim 7** - Signs only (virtual text not supported)

Virtual text automatically falls back to signs in Vim.

## Integration with Compiler

Hints integrate seamlessly with compiler errors:

- **Separate signs** - Hints use ◆ symbol, errors use ✕ symbol
- **Unified sign column** - Both display in the same column without conflicts
- **Different colors** - Hints use different highlight groups than errors
- **Independent control** - Enable/disable hints without affecting compiler

## Troubleshooting

**Hints not showing:**
```vim
:echo genero_tools#hints#config#get('hints_enabled')
```

**Hints not updating:**
```vim
:GeneroClearHintCache
```

**Too many hints:**
Disable specific checks or increase thresholds:
```vim
let g:genero_tools_config.line_length = 0
let g:genero_tools_config.max_line_length = 150
```

**Performance issues:**
Disable real-time detection or increase delay:
```vim
let g:genero_tools_config.hints_realtime = 0
let g:genero_tools_config.hints_delay = 2000
```

## See Also

- [Configuration Guide](../docs/DEVELOPER_QUICK_REFERENCE.md) - All configuration options
- [Error Handling](ERROR_HANDLING.md) - Error message formatting
- [Compiler Integration](COMPILER_INTEGRATION.md) - Compiler error handling


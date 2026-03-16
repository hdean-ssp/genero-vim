# Compiler Integration Guide

## Overview

The genero-tools plugin provides comprehensive compiler integration for Genero/4GL development in Vim/Neovim. It automatically compiles files on save, displays errors/warnings, and highlights issues in real-time.

## Quick Start

### Enable Compiler Integration

```vim
" In your vimrc
let g:genero_tools_config.compiler_enabled = v:true
let g:genero_tools_config.compiler_autocompile = v:true

" Enable autocompile when opening Genero files
autocmd FileType genero,fgl call genero_tools#compiler#autocompile#enable()
```

### Or Use Commands

```vim
:let g:genero_tools_config.compiler_enabled = v:true
:let g:genero_tools_config.compiler_autocompile = v:true
:GeneroAutocompileEnable
```

## Features

### 1. Automatic Compilation on Save

When enabled, files are automatically compiled when saved with the command:
```bash
fglcomp -M -W all <file>
```

**Compiler Flags:**
- `-M` - Generate machine code (required for compilation)
- `-W all` - Enable all warnings (recommended for code quality)

**Commands:**
```vim
:GeneroAutocompileEnable   " Enable for current buffer
:GeneroAutocompileDisable  " Disable for current buffer
:GeneroAutocompileStatus   " Show current status
```

### 2. Error and Warning Display

Compiler output is displayed in multiple ways:

#### Quickfix List
Navigate errors/warnings with standard Vim commands:
```vim
:copen          " Open quickfix window
:cnext          " Go to next error
:cprevious      " Go to previous error
:cclose         " Close quickfix window
```

#### Sign Column
Visual indicators in the left margin:
- `✕` = Error (red)
- `⚠` = Warning (yellow)
- `ℹ` = Info (blue)

#### Inline Highlighting
- Unused variables highlighted in yellow background
- All occurrences of unused variables highlighted

### 3. Unused Variable Detection

Automatically detects and highlights unused variables (code -6615):

```vim
" Configuration
let g:genero_tools_config.compiler_highlight_unused = v:true
```

When enabled:
- Unused variables are highlighted in yellow
- Variable names are extracted from compiler warnings
- All occurrences in the file are highlighted

Example:
```
con01_G.4gl:1811:9:1811:21:warning:(-6615) The symbol 'l_description' is unused.
```

The variable `l_description` will be highlighted throughout the file.

## Configuration

### Default Settings

```vim
let g:genero_tools_config = {
  \ 'compiler_enabled': v:false,
  \ 'compiler_command': 'fglcomp -M -W all',
  \ 'compiler_source_dir': '.',
  \ 'compiler_version': 'auto',
  \ 'compiler_show_warnings': v:true,
  \ 'compiler_show_errors': v:true,
  \ 'compiler_highlight_unused': v:true,
  \ 'compiler_sign_column': v:true,
  \ 'compiler_autocompile': v:false,
  \ 'compiler_autocompile_delay': 1000,
  \ }
```

**Compiler Command Flags:**
- `-M` - Generate machine code (required for compilation)
- `-W all` - Enable all warnings (recommended for code quality)

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `compiler_enabled` | bool | `false` | Enable compiler integration |
| `compiler_command` | string | `'fglcomp -M -W all'` | Compiler command with flags |
| `compiler_source_dir` | string | `'.'` | Source directory for compilation |
| `compiler_version` | string | `'auto'` | Compiler version ('auto', '3.10', '3.20') |
| `compiler_show_warnings` | bool | `true` | Show warnings in quickfix |
| `compiler_show_errors` | bool | `true` | Show errors in quickfix |
| `compiler_highlight_unused` | bool | `true` | Highlight unused variables |
| `compiler_sign_column` | bool | `true` | Show signs in sign column |
| `compiler_autocompile` | bool | `false` | Compile on save |
| `compiler_autocompile_delay` | number | `1000` | Delay before autocompile (ms) |

## Compiler Output Format

The plugin supports fglcomp 3.10+ output format:

```
filename:line:col:end_line:end_col:severity:(-code) message
```

Example:
```
con01_G.4gl:1811:9:1811:21:warning:(-6615) The symbol 'l_description' is unused.
con01_G.4gl:258:44:258:52:warning:(-8059) SQL statement or language instruction with vendor proprietary SQL syntax.
```

### Severity Levels

- `error` - Compilation error (prevents compilation)
- `warning` - Compiler warning (compilation succeeds)
- `info` - Informational message

### Common Error Codes

| Code | Type | Description |
|------|------|-------------|
| -4369 | Error | Undefined variable/symbol |
| -6615 | Warning | Unused variable/symbol |
| -8059 | Warning | Vendor proprietary SQL syntax |

## Workflow

### Typical Development Workflow

1. **Enable autocompile** (once per session):
   ```vim
   :GeneroAutocompileEnable
   ```

2. **Edit your file** - Compilation happens automatically on save

3. **View errors** - Use quickfix to navigate:
   ```vim
   :copen          " Open error list
   :cnext          " Jump to next error
   ```

4. **Fix issues** - Errors/warnings update automatically

5. **Verify** - When all errors are fixed, quickfix clears

### Manual Compilation

To compile without autocompile:

```vim
:GeneroCompile %              " Compile current file
:GeneroCompile path/to/file   " Compile specific file
```

## Troubleshooting

### Compiler Not Found

If you get "compiler command not found":

```vim
" Set correct compiler path
let g:genero_tools_config.compiler_command = '/path/to/fglcomp'
```

### No Errors Showing

Check configuration:

```vim
" Verify compiler is enabled
echo g:genero_tools_config.compiler_enabled

" Verify autocompile is enabled
echo g:genero_tools_config.compiler_autocompile

" Check compiler version detection
echo genero_tools#compiler#get_version()
```

### Highlighting Not Working

```vim
" Verify highlighting is enabled
let g:genero_tools_config.compiler_highlight_unused = v:true

" Re-enable autocompile to refresh
:GeneroAutocompileEnable
```

## Advanced Usage

### Custom Error Filtering

Filter quickfix by severity:

```vim
" Show only errors
call genero_tools#compiler#quickfix#populate(result, 'errors')

" Show only warnings
call genero_tools#compiler#quickfix#populate(result, 'warnings')

" Show all
call genero_tools#compiler#quickfix#populate(result, 'all')
```

### Programmatic Access

Access compiler results directly:

```vim
" Compile and get results
let result = genero_tools#compiler#execute('myfile.4gl')

" Check results
if result.success
  echo "Errors: " . len(result.errors)
  echo "Warnings: " . len(result.warnings)
endif

" Access individual entries
for error in result.errors
  echo error.file . ":" . error.line . ":" . error.message
endfor
```

### Custom Highlighting

Define custom highlight colors:

```vim
" Override unused variable highlight
highlight GeneroUnusedVariable ctermbg=226 ctermfg=0 guibg=#ffff00 guifg=#000000
```

## Performance Considerations

### Autocompile Delay

The `compiler_autocompile_delay` option prevents excessive compilation:

```vim
" Increase delay for large files (default 500ms)
let g:genero_tools_config.compiler_autocompile_delay = 1000
```

### Disable for Large Files

For very large files, disable autocompile:

```vim
:GeneroAutocompileDisable
```

Then compile manually when needed:

```vim
:GeneroCompile %
```

## Integration with Other Tools

### With Quickfix Plugins

The compiler integrates with standard Vim quickfix, so it works with:
- vim-unimpaired (]q, [q for navigation)
- vim-qf (enhanced quickfix)
- fzf.vim (fuzzy quickfix search)

### With LSP

For LSP integration, see [NEOVIM.md](NEOVIM.md).

## Examples

### Example 1: Basic Setup

```vim
" In your vimrc
let g:genero_tools_config = {
  \ 'compiler_enabled': v:true,
  \ 'compiler_autocompile': v:true,
  \ 'compiler_highlight_unused': v:true,
  \ }

" Enable autocompile when opening Genero files
autocmd FileType genero,fgl call genero_tools#compiler#autocompile#enable()
```

### Example 2: Strict Mode

```vim
" Show all warnings and errors
let g:genero_tools_config = {
  \ 'compiler_enabled': v:true,
  \ 'compiler_show_warnings': v:true,
  \ 'compiler_show_errors': v:true,
  \ 'compiler_highlight_unused': v:true,
  \ 'compiler_sign_column': v:true,
  \ }
```

### Example 3: Minimal Mode

```vim
" Only show errors, no highlighting
let g:genero_tools_config = {
  \ 'compiler_enabled': v:true,
  \ 'compiler_show_warnings': v:false,
  \ 'compiler_show_errors': v:true,
  \ 'compiler_highlight_unused': v:false,
  \ 'compiler_sign_column': v:false,
  \ }
```

## See Also

- [QUICK_START.md](QUICK_START.md) - Getting started guide
- [NEOVIM.md](NEOVIM.md) - Neovim-specific features
- [API_INTEGRATION.md](API_INTEGRATION.md) - Using genero-tools API

# Unified Sign Column Configuration Guide

## Quick Start

To enable unified signs that combine compiler diagnostics and SVN markers:

```vim
" In your init.vim or .vimrc
let g:genero_tools_unified_signs = 1
```

## Configuration Options

### Enable/Disable Unified Signs

```vim
" Enable unified signs (default: 0)
let g:genero_tools_unified_signs = 1

" Disable unified signs (use separate columns)
let g:genero_tools_unified_signs = 0
```

### Sign Column Visibility

```vim
" Always show sign column (even when no signs)
let g:genero_tools_compiler_sign_column_always_visible = 1

" Show sign column only when signs are present
let g:genero_tools_compiler_sign_column_always_visible = 0
```

### Individual Sign System Control

```vim
" Enable compiler diagnostics signs
let g:genero_tools_compiler_signs_enabled = 1

" Enable SVN diff signs
let g:genero_tools_svn_signs_enabled = 1

" Auto-update SVN signs on file save
let g:genero_tools_svn_auto_update = 1
```

## Usage Scenarios

### Scenario 1: Development with Compiler Feedback

Focus on compiler errors while tracking SVN changes:

```vim
let g:genero_tools_unified_signs = 1
let g:genero_tools_compiler_signs_enabled = 1
let g:genero_tools_svn_signs_enabled = 1
let g:genero_tools_compiler_sign_column_always_visible = 1
```

Result: Single sign column showing combined signs like `✕|~`

### Scenario 2: Code Review Mode

Emphasize SVN changes with compiler info:

```vim
let g:genero_tools_unified_signs = 1
let g:genero_tools_compiler_signs_enabled = 1
let g:genero_tools_svn_signs_enabled = 1
let g:genero_tools_compiler_sign_column_always_visible = 0
```

Result: Sign column appears only when there are changes

### Scenario 3: Separate Columns (Legacy)

Keep compiler and SVN signs in separate columns:

```vim
let g:genero_tools_unified_signs = 0
let g:genero_tools_compiler_signs_enabled = 1
let g:genero_tools_svn_signs_enabled = 1
```

Result: Two sign columns (more screen space used)

### Scenario 4: Compiler Only

Focus on compilation errors only:

```vim
let g:genero_tools_unified_signs = 1
let g:genero_tools_compiler_signs_enabled = 1
let g:genero_tools_svn_signs_enabled = 0
```

Result: Single sign column with compiler signs only

### Scenario 5: SVN Only

Track version control changes only:

```vim
let g:genero_tools_unified_signs = 1
let g:genero_tools_compiler_signs_enabled = 0
let g:genero_tools_svn_signs_enabled = 1
```

Result: Single sign column with SVN signs only

## Sign Meanings

### Compiler Diagnostics

| Sign | Meaning | Color |
|------|---------|-------|
| `✕` | Compilation error | Red |
| `⚠` | Compilation warning | Yellow |
| `ℹ` | Compilation info | Blue |

### SVN Diff Markers

| Sign | Meaning | Color |
|------|---------|-------|
| `+` | Line added | Green |
| `~` | Line modified | Yellow |
| `-` | Line deleted | Red |

### Combined Signs

When both signs appear on the same line:

| Combined | Meaning |
|----------|---------|
| `✕\|+` | Error on added line |
| `✕\|~` | Error on modified line |
| `✕\|-` | Error on deleted line |
| `⚠\|+` | Warning on added line |
| `⚠\|~` | Warning on modified line |
| `⚠\|-` | Warning on deleted line |
| `ℹ\|+` | Info on added line |
| `ℹ\|~` | Info on modified line |
| `ℹ\|-` | Info on deleted line |

## Keybindings for Sign Navigation

Add these to your config to navigate between signs:

```vim
" Jump to next error
nnoremap <leader>en :sign jump group=genero_compiler<CR>

" Jump to next SVN change
nnoremap <leader>sn :sign jump group=genero_svn<CR>

" Jump to next combined sign
nnoremap <leader>cn :sign jump group=genero_combined<CR>

" List all signs in current buffer
nnoremap <leader>sl :sign place buffer=<C-R>=bufnr('%')<CR><CR>
```

## Troubleshooting

### Signs Not Appearing

1. Check if signs are enabled:
   ```vim
   :echo g:genero_tools_compiler_signs_enabled
   :echo g:genero_tools_svn_signs_enabled
   ```

2. Verify sign column is visible:
   ```vim
   :set signcolumn?
   ```

3. Check if Vim version supports signs:
   ```vim
   :echo has('signs')
   ```

### Too Many Signs

If the sign column is crowded, consider:

1. Disable one sign system:
   ```vim
   let g:genero_tools_svn_signs_enabled = 0
   ```

2. Use separate columns instead:
   ```vim
   let g:genero_tools_unified_signs = 0
   ```

3. Increase sign column width:
   ```vim
   :set signcolumn=yes:2
   ```

### Signs Not Updating

1. For compiler signs, recompile:
   ```vim
   :GeneroCompile
   ```

2. For SVN signs, save the file:
   ```vim
   :w
   ```

3. Manually refresh:
   ```vim
   :call genero_tools#signs#clear_combined_all()
   ```

## Performance Tips

- Unified signs are more efficient than separate columns
- Sign caching prevents redundant definitions
- Minimal overhead for files with few signs
- Consider disabling SVN signs for very large files

## Integration with Other Plugins

### With vim-signify or similar

If using another plugin that manages signs, disable genero-tools signs:

```vim
let g:genero_tools_compiler_signs_enabled = 0
let g:genero_tools_svn_signs_enabled = 0
```

### With ALE or similar linters

Genero-tools signs work alongside ALE:

```vim
" Both can coexist
let g:genero_tools_compiler_signs_enabled = 1
let g:ale_sign_column_always_visible = 1
```

Note: They will use separate sign groups and may appear in different columns.

## Advanced: Custom Sign Definitions

To customize sign appearance, modify the highlight groups:

```vim
" Custom error sign color
highlight GeneroCompilerError ctermfg=9 guifg=#ff0000 ctermbg=NONE guibg=NONE

" Custom SVN modified color
highlight GeneroSVNModified ctermfg=11 guifg=#ffff00 ctermbg=NONE guibg=NONE
```

Then reload signs:

```vim
:call genero_tools#signs#clear_combined_all()
:call genero_tools#signs#init()
```

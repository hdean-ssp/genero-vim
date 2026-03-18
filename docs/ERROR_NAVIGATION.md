# Error Navigation Guide

## Commands

### Navigate Errors

```vim
:GeneroNextError      " Jump to next error
:GeneroPrevError      " Jump to previous error
:GeneroFirstError     " Jump to first error
:GeneroLastError      " Jump to last error
```

### Compile and View

```vim
:GeneroCompile        " Compile current file and populate error list
:GeneroClearErrors    " Clear all errors and warnings
```

## Quick Setup

### Keybindings

Add to your config for quick navigation:

```vim
" Navigate errors
nnoremap <leader>en :GeneroNextError<CR>
nnoremap <leader>ep :GeneroPrevError<CR>
nnoremap <leader>ef :GeneroFirstError<CR>
nnoremap <leader>el :GeneroLastError<CR>

" Compile and clear
nnoremap <leader>ec :GeneroCompile<CR>
nnoremap <leader>ex :GeneroClearErrors<CR>
```

## Usage Workflow

### 1. Compile Your Code

```vim
:GeneroCompile
```

This will:
- Compile the current file
- Populate the quickfix list with errors/warnings
- Display results in quickfix window or floating window
- Place error signs in the sign column

### 2. Navigate to Errors

```vim
" Jump to first error
:GeneroFirstError

" Jump to next error
:GeneroNextError

" Jump to previous error
:GeneroPrevError

" Jump to last error
:GeneroLastError
```

### 3. Fix and Recompile

After fixing errors:

```vim
:GeneroCompile
```

The error list will be updated automatically.

## Error Display

### Quickfix Window

When you compile, errors appear in the quickfix window:

```
test.fgl|5 col 10| Syntax error: unexpected token
test.fgl|12 col 5| Undefined variable: x
test.fgl|18 col 1| Missing return statement
```

### Sign Column

Errors also appear as signs in the sign column:

```
Line  Col1  Code
  5   ✕     let x = y + z
 12   ✕     let result = undefined_var
 18   ✕     function foo()
```

### Error Messages

When navigating, you'll see feedback:

```
Error 1 of 3    " First error
Error 2 of 3    " Second error
Error 3 of 3    " Third error
```

## Troubleshooting

### "No errors to navigate"

This means the quickfix list is empty. You need to compile first:

```vim
:GeneroCompile
```

### Navigation Not Working

1. Check if compilation succeeded:
   ```vim
   :GeneroCompile
   ```

2. Verify quickfix list has items:
   ```vim
   :copen
   ```

3. Check if you're at the end of the list:
   ```vim
   :GeneroLastError
   ```

### Quickfix Window Not Opening

The quickfix window should open automatically after compilation. If not:

```vim
:copen
```

To close it:

```vim
:cclose
```

## Advanced Usage

### Jump to Specific Error

You can click on an error in the quickfix window to jump to it, or use:

```vim
:cc 2    " Jump to error 2
```

### Filter Errors

Show only errors (not warnings):

```vim
:cfilter! W
```

Show only warnings:

```vim
:cfilter! E
```

Clear filter:

```vim
:cfilter
```

### Quickfix History

Vim maintains a history of quickfix lists. Navigate between them:

```vim
:colder    " Go to previous quickfix list
:cnewer    " Go to next quickfix list
```

## Integration with Other Tools

### With Compiler Autocompile

Enable autocompile to automatically compile on save:

```vim
:GeneroAutocompileEnable
```

Then errors will be updated automatically as you edit.

### With Error Highlighting

Errors are highlighted in the editor:

```vim
" Error lines are highlighted in red
" Warning lines are highlighted in yellow
```

### With SVN Signs

When unified signs are enabled, you can see both compiler errors and SVN changes:

```vim
:GeneroUnifiedSignsEnable
```

Then navigate errors while seeing version control changes.

## Performance Tips

1. **Use keybindings** for fastest navigation
2. **Compile only when needed** - don't enable autocompile for large projects
3. **Clear errors** when done to free memory:
   ```vim
   :GeneroClearErrors
   ```

## See Also

- `COMPILER_INTEGRATION.md` - Compiler setup and configuration
- `UNIFIED_SIGN_COLUMN.md` - Sign column management
- `UNIFIED_SIGNS_QUICK_REFERENCE.md` - Quick sign commands
